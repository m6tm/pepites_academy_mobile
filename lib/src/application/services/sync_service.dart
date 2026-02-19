import 'dart:async';
import 'dart:convert';
import '../../../l10n/app_localizations.dart';
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

  AppLocalizations? _l10n;

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
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

  /// Synchronise toutes les operations en attente vers le backend.
  Future<SyncCycleResult?> syncPendingOperations() async {
    if (_isSyncing) return null;
    _isSyncing = true;

    final pending = await _syncRepository.getPendingOperations();
    if (pending.isEmpty) {
      _isSyncing = false;
      return SyncCycleResult(
        totalOperations: 0,
        successCount: 0,
        failureCount: 0,
        errors: [],
      );
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

    _isSyncing = false;
    _notifyPendingCountChanged();

    final cycleResult = SyncCycleResult(
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

  /// Libere les ressources.
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
  }
}
