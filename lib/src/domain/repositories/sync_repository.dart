import '../entities/sync_operation.dart';

/// Contrat pour la gestion de la file d'attente de synchronisation.
/// Permet d'empiler les operations locales et de les depiler
/// lors de la synchronisation avec le backend.
abstract class SyncRepository {
  /// Ajoute une operation a la file d'attente.
  Future<void> enqueue(SyncOperation operation);

  /// Recupere toutes les operations en attente, triees par date de creation.
  Future<List<SyncOperation>> getPendingOperations();

  /// Met a jour le statut d'une operation.
  Future<void> updateStatus(
    String operationId,
    SyncOperationStatus status, {
    String? errorMessage,
  });

  /// Marque une operation comme terminee et la supprime de la file.
  Future<void> markCompleted(String operationId);

  /// Incremente le compteur de tentatives d'une operation.
  Future<void> incrementRetryCount(String operationId);

  /// Recupere le nombre d'operations en attente.
  Future<int> getPendingCount();

  /// Supprime toutes les operations terminees.
  Future<void> clearCompleted();

  /// Supprime toutes les operations de la file.
  Future<void> clearAll();
}
