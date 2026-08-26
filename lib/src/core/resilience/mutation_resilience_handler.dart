import 'dart:convert';
import '../../application/services/sync_service.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/sync_operation.dart';
import '../../infrastructure/datasources/api_sync_datasource.dart';
import 'resilience_result.dart';

/// Handler de résilience pour les mutations dont l'entité cible est introuvable
/// localement. Il tente de reconstruire le payload depuis la file de sync ou un
/// fallback (cache), puis d'exécuter la requête ou de la remettre en file d'attente.
class MutationResilienceHandler {
  final SyncService _syncService;
  final ApiSyncDatasource _apiSyncDatasource;
  final ConnectivityGuard _connectivityGuard;

  MutationResilienceHandler({
    required SyncService syncService,
    required ApiSyncDatasource apiSyncDatasource,
    required ConnectivityGuard connectivityGuard,
  })  : _syncService = syncService,
        _apiSyncDatasource = apiSyncDatasource,
        _connectivityGuard = connectivityGuard;

  /// Tente de récupérer et d'exécuter une mutation pour une entité introuvable.
  ///
  /// [fallbackPayload] est typiquement fourni par le repository depuis son cache
  /// mémoire (valeur stale). S'il est absent, seule la file d'attente de sync est
  /// utilisée.
  ///
  /// Retourne :
  /// - [ResilienceSuccess] avec la réponse serveur si la requête a réussi.
  /// - [ResilienceEnqueued] si l'appareil est hors ligne et l'opération a été
  ///   remise en file d'attente.
  /// - [ResilienceFailure] si aucune donnée source n'a été trouvée ou si le
  ///   serveur a rejeté la requête.
  Future<ResilienceResult<Map<String, dynamic>>> recover({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    Map<String, dynamic>? fallbackPayload,
  }) async {
    final payload = await _resolvePayload(
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      fallbackPayload: fallbackPayload,
    );

    if (payload == null) {
      return const ResilienceFailure(
        'Aucune donnée source trouvée pour reconstruire la requête',
      );
    }

    final online = await _connectivityGuard.isOnline;
    if (!online) {
      await _syncService.enqueueOperation(
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        data: payload,
      );
      return const ResilienceEnqueued();
    }

    final operation = SyncOperation(
      id: '${DateTime.now().millisecondsSinceEpoch}_resilience',
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payload: json.encode(payload),
      createdAt: DateTime.now(),
    );

    final result = await _apiSyncDatasource.pushOperationWithPayload(
      operation,
      payload,
    );

    if (result.success) {
      return ResilienceSuccess(
        result.serverResponse ?? {},
        wasRebuilt: true,
      );
    }

    // Si l'entité est toujours introuvable côté serveur, on abandonne.
    if (result.isNotFound) {
      return ResilienceFailure(
        result.errorMessage ?? 'Entité introuvable sur le serveur',
      );
    }

    // Pour les autres erreurs serveur, on remet en file d'attente pour retenter
    // plus tard (comportement offline standard).
    await _syncService.enqueueOperation(
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      data: payload,
    );
    return const ResilienceEnqueued();
  }

  /// Résout le payload à utiliser pour la requête de résilience.
  Future<Map<String, dynamic>?> _resolvePayload({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    Map<String, dynamic>? fallbackPayload,
  }) async {
    // 1. Priorité à la file d'attente de sync : c'est la donnée la plus fraîche.
    final rebuilt = await _syncService.rebuildPayload(entityType, entityId);
    if (rebuilt != null) {
      return _preparePayload(
        operationType: operationType,
        entityId: entityId,
        payload: rebuilt,
      );
    }

    // 2. Sinon, utiliser le fallback (cache stale) s'il est fourni.
    if (fallbackPayload != null) {
      return _preparePayload(
        operationType: operationType,
        entityId: entityId,
        payload: fallbackPayload,
      );
    }

    // 3. Pour une suppression, on peut toujours reconstruire un payload minimal.
    if (operationType == SyncOperationType.delete) {
      return {'id': entityId};
    }

    return null;
  }

  /// Adapte le payload selon le type d'opération.
  Map<String, dynamic> _preparePayload({
    required SyncOperationType operationType,
    required String entityId,
    required Map<String, dynamic> payload,
  }) {
    final prepared = Map<String, dynamic>.from(payload);

    switch (operationType) {
      case SyncOperationType.create:
        // Le backend génère l'UUID ; l'ID local ne doit pas être envoyé.
        prepared.remove('id');
      case SyncOperationType.update:
        // S'assurer que l'ID serveur est présent dans le payload.
        prepared['id'] = entityId;
      case SyncOperationType.delete:
        prepared['id'] = entityId;
      case SyncOperationType.reorder:
      // Conserver le payload tel quel (il contient déjà l'ordre).
    }

    return prepared;
  }
}
