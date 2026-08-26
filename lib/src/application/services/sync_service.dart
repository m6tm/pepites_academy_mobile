import 'dart:async';
import 'dart:convert';
import '../../../l10n/app_localizations.dart';
import '../../core/resilience/mutation_resilience_handler.dart';
import '../../core/resilience/resilience_result.dart';
import '../../domain/entities/connectivity_status.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/entities/conflict_resolution.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../infrastructure/datasources/api_sync_datasource.dart';
import 'connectivity_service.dart';

/// Resultat global d'un cycle de synchronisation.
class SyncCycleResult {
  final int totalOperations;
  final int successCount;
  final int failureCount;
  final List<String> errors;

  SyncCycleResult({
    required this.totalOperations,
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });
}

/// Service applicatif pour la synchronisation des donnees hors-ligne.
/// Gere la file d'attente, la synchronisation automatique en arriere-plan,
/// et la resolution des conflits.
class SyncService {
  final SyncRepository _syncRepository;
  final ApiSyncDatasource _apiDatasource;
  final ConnectivityService _connectivityService;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  bool _isSyncing = false;
  Timer? _retryTimer;

  /// Nombre maximum de tentatives avant abandon d'une operation.
  static const int maxRetryCount = 5;

  /// Delai entre les tentatives de synchronisation (en secondes).
  static const int retryDelaySeconds = 30;

  /// Strategie de resolution de conflits configurable.
  ConflictResolutionStrategy conflictStrategy =
      ConflictResolutionStrategy.lastWriteWins;

  /// Callback notifie apres chaque cycle de synchronisation.
  void Function(SyncCycleResult)? onSyncCompleted;

  /// Callback notifie quand le nombre d'operations en attente change.
  void Function(int)? onPendingCountChanged;

  /// Callback notifie quand une operation echoue avec un conflit (409).
  /// Permet aux repositories de supprimer l'enregistrement local.
  /// [entityId] = l'ID local qui a cause le conflit
  /// [serverBlockedId] = l'ID de la ressource bloqueante sur le serveur (ex: seance ouverte)
  Future<void> Function(SyncEntityType entityType, String entityId, String? serverBlockedId)?
  onConflictError;

  /// Callback notifie quand le serveur a assigne un UUID a une entite creee offline.
  /// Permet aux repositories de migrer l'entite locale (ID timestamp → UUID serveur).
  /// [entityType] = type d'entite, [localId] = ID timestamp local, [serverId] = UUID serveur
  Future<void> Function(SyncEntityType entityType, String localId, String serverId)?
  onServerIdAssigned;

  MutationResilienceHandler? _resilienceHandler;

  AppLocalizations? _l10n;

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Injecte le handler de résilience utilisé lorsqu'une opération échoue
  /// parce que l'entité est introuvable côté serveur.
  void setMutationResilienceHandler(MutationResilienceHandler handler) {
    _resilienceHandler = handler;
  }

  SyncService({
    required SyncRepository syncRepository,
    required ApiSyncDatasource apiDatasource,
    required ConnectivityService connectivityService,
  }) : _syncRepository = syncRepository,
       _apiDatasource = apiDatasource,
       _connectivityService = connectivityService;

  /// Demarre l'ecoute de la connectivite pour synchroniser automatiquement.
  void startAutoSync() {
    _connectivitySubscription = _connectivityService.statusStream.listen((
      status,
    ) {
      if (status == ConnectivityStatus.connected) {
        syncPendingOperations();
      }
    });
  }

  /// Ajoute une operation a la file d'attente de synchronisation.
  /// Appelee automatiquement par les repositories lors d'une modification locale.
  Future<void> enqueueOperation({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    required Map<String, dynamic> data,
  }) async {
    final operation = SyncOperation(
      id: _generateId(),
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payload: json.encode(data),
      createdAt: DateTime.now(),
    );

    await _syncRepository.enqueue(operation);
    _notifyPendingCountChanged();

    // Tente une synchronisation immediate si connecte.
    final isConnected = await _connectivityService.isConnected();
    if (isConnected) {
      syncPendingOperations();
    }
  }

  /// Annule toutes les operations en attente pour une entite donnee.
  /// Utilise quand une mutation locale echoue parce que l'entite n'existe
  /// plus (ex. suppression d'un ID local jamais synchronise).
  Future<void> cancelOperationsForEntity(
    SyncEntityType entityType,
    String entityId,
  ) async {
    final pending = await _syncRepository.getPendingOperations();
    var cancelled = 0;
    for (final operation in pending) {
      if (operation.entityType == entityType && operation.entityId == entityId) {
        await _syncRepository.markCompleted(operation.id);
        cancelled++;
      }
    }
    if (cancelled > 0) {
      _notifyPendingCountChanged();
    }
  }

  /// Synchronise toutes les operations en attente vers le backend.
  Future<SyncCycleResult?> syncPendingOperations() async {
    if (_isSyncing) return null;
    _isSyncing = true;

    SyncCycleResult? cycleResult;

    try {
      final pending = await _syncRepository.getPendingOperations();
      if (pending.isEmpty) {
        cycleResult = SyncCycleResult(
          totalOperations: 0,
          successCount: 0,
          failureCount: 0,
          errors: [],
        );
        onSyncCompleted?.call(cycleResult);
        return cycleResult;
      }

      int successCount = 0;
      int failureCount = 0;
      final errors = <String>[];

      for (final operation in pending) {
        if (operation.retryCount >= maxRetryCount) {
          final maxRetriesMsg =
              _l10n?.serviceSyncMaxRetries ??
              'Nombre maximum de tentatives atteint';
          await _syncRepository.updateStatus(
            operation.id,
            SyncOperationStatus.failed,
            errorMessage: maxRetriesMsg,
          );
          failureCount++;
          errors.add(
            '${operation.entityType.name}/${operation.entityId}: '
            '$maxRetriesMsg',
          );
          continue;
        }

        try {
          await _syncRepository.updateStatus(
            operation.id,
            SyncOperationStatus.inProgress,
          );

          final result = await _apiDatasource.pushOperation(operation);

          if (result.success) {
            await _syncRepository.markCompleted(operation.id);
            successCount++;
            // Si le serveur a attribue un UUID different de l'ID local (creation offline),
            // notifier le repository pour migrer l'entite locale.
            if (operation.operationType == SyncOperationType.create) {
              final serverId = _extractServerId(result.serverResponse);
              if (serverId != null && serverId != operation.entityId) {
                await onServerIdAssigned?.call(
                  operation.entityType,
                  operation.entityId,
                  serverId,
                );
              }
            }
          } else if (result.isConflict) {
            // Conflit (409): email/telephone deja existant
            // Supprimer l'operation de la queue et l'enregistrement local
            await _syncRepository.markCompleted(operation.id);
            if (onConflictError != null) {
              await onConflictError!(
                operation.entityType,
                operation.entityId,
                result.blockedSeanceId,
              );
            }
            failureCount++;
            const conflictMsg = 'Donnee deja existante sur le serveur';
            errors.add(
              '${operation.entityType.name}/${operation.entityId}: '
              '$conflictMsg - ${result.errorMessage}',
            );
          } else if (result.isNotFound) {
            // 404: l'entite n'existe pas sur le backend. Avant d'abandonner,
            // tenter de reconstruire le payload depuis le cache/file d'attente.
            final recovered = await _resilienceHandler?.recover(
              entityType: operation.entityType,
              entityId: operation.entityId,
              operationType: operation.operationType,
            );

            if (recovered is ResilienceSuccess<Map<String, dynamic>>) {
              await _syncRepository.markCompleted(operation.id);
              successCount++;
              if (operation.operationType == SyncOperationType.create) {
                final serverId = _extractServerId(recovered.data);
                if (serverId != null && serverId != operation.entityId) {
                  await onServerIdAssigned?.call(
                    operation.entityType,
                    operation.entityId,
                    serverId,
                  );
                }
              }
            } else if (recovered is ResilienceEnqueued<Map<String, dynamic>>) {
              // L'opération a été clonée et remise en file ; on peut purger
              // l'ancienne opération qui a échoué.
              await _syncRepository.markCompleted(operation.id);
            } else {
              // Echec permanent : aucune donnée source ou serveur insiste sur 404.
              await _syncRepository.markCompleted(operation.id);
              failureCount++;
              errors.add(
                '${operation.entityType.name}/${operation.entityId}: '
                'Entite introuvable sur le serveur (404) — operation abandonnee',
              );
            }
          } else {
            await _syncRepository.incrementRetryCount(operation.id);
            await _syncRepository.updateStatus(
              operation.id,
              SyncOperationStatus.pending,
              errorMessage: result.errorMessage,
            );
            failureCount++;
            if (result.errorMessage != null) {
              errors.add(
                '${operation.entityType.name}/${operation.entityId}: '
                '${result.errorMessage}',
              );
            }
          }
        } catch (e) {
          await _syncRepository.incrementRetryCount(operation.id);
          await _syncRepository.updateStatus(
            operation.id,
            SyncOperationStatus.pending,
            errorMessage: e.toString(),
          );
          failureCount++;
          errors.add('${operation.entityType.name}/${operation.entityId}: $e');
        }
      }

      cycleResult = SyncCycleResult(
        totalOperations: pending.length,
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );

      onSyncCompleted?.call(cycleResult);

      // Programme une nouvelle tentative si des operations ont echoue.
      if (failureCount > 0) {
        _scheduleRetry();
      }

      return cycleResult;
    } catch (e) {
      cycleResult = SyncCycleResult(
        totalOperations: 0,
        successCount: 0,
        failureCount: 0,
        errors: [e.toString()],
      );
      onSyncCompleted?.call(cycleResult);
      rethrow;
    } finally {
      _isSyncing = false;
      _notifyPendingCountChanged();
    }
  }

  /// Recupere le nombre d'operations en attente.
  Future<int> getPendingCount() {
    return _syncRepository.getPendingCount();
  }

  /// Recupere toutes les operations en attente.
  Future<List<SyncOperation>> getPendingOperations() {
    return _syncRepository.getPendingOperations();
  }

  /// Supprime toutes les operations de la file.
  Future<void> clearAll() async {
    await _syncRepository.clearAll();
    _notifyPendingCountChanged();
  }

  /// Indique si une synchronisation est en cours.
  bool get isSyncing => _isSyncing;

  /// Indique si l'appareil est actuellement connecte a Internet.
  Future<bool> isConnected() => _connectivityService.isConnected();

  /// Synchronise les operations en attente en attendant la fin d'une
  /// eventuelle synchronisation deja en cours.
  Future<SyncCycleResult?> syncPendingOperationsAndWait() async {
    while (_isSyncing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return syncPendingOperations();
  }

  /// Retourne les operations en attente pour une entite donnee.
  Future<List<SyncOperation>> getPendingOperationsForEntity(
    SyncEntityType entityType,
    String entityId,
  ) async {
    final pending = await _syncRepository.getPendingOperations();
    return pending
        .where(
          (op) => op.entityType == entityType && op.entityId == entityId,
        )
        .toList();
  }

  /// Reconstruit le payload le plus a jour possible pour une entite a partir
  /// de ses operations de sync en attente.
  ///
  /// Par exemple, si la file contient create(A) puis update(A+B), le payload
  /// resultat sera A+B. Si un delete est present, retourne null (l'entite est
  /// deja marquee pour suppression).
  Future<Map<String, dynamic>?> rebuildPayload(
    SyncEntityType entityType,
    String entityId,
  ) async {
    final operations = await getPendingOperationsForEntity(entityType, entityId);
    if (operations.isEmpty) return null;

    final sorted = operations.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Si la derniere operation est une suppression, il n'y a rien a reconstruire.
    if (sorted.last.operationType == SyncOperationType.delete) {
      return null;
    }

    Map<String, dynamic>? merged;
    for (final op in sorted) {
      final payload = json.decode(op.payload) as Map<String, dynamic>;
      switch (op.operationType) {
        case SyncOperationType.create:
        case SyncOperationType.update:
          merged = {...?merged, ...payload};
        case SyncOperationType.reorder:
          merged ??= {};
          merged['order'] = payload['order'];
        case SyncOperationType.delete:
          // Un delete intermediaire annule tout ce qui precede.
          merged = null;
      }
    }
    return merged;
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: retryDelaySeconds), () async {
      final isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        syncPendingOperations();
      }
    });
  }

  void _notifyPendingCountChanged() async {
    final count = await _syncRepository.getPendingCount();
    onPendingCountChanged?.call(count);
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_'
        '${DateTime.now().microsecond}';
  }

  /// Extrait l'UUID serveur depuis la reponse d'un POST de creation.
  /// Gere les formats : {"id": "uuid"} et {"seance": {"id": "uuid"}, ...}
  String? _extractServerId(Map<String, dynamic>? response) {
    if (response == null) return null;
    if (response['id'] is String) return response['id'] as String;
    for (final value in response.values) {
      if (value is Map<String, dynamic> && value['id'] is String) {
        return value['id'] as String;
      }
    }
    return null;
  }

  /// Libere les ressources.
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
  }
}
