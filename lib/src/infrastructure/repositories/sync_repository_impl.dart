import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/sync_queue_local_datasource.dart';

/// Implementation locale du repository de synchronisation.
/// Delegue les operations au datasource SQLite.
class SyncRepositoryImpl implements SyncRepository {
  final SyncQueueLocalDatasource _datasource;

  SyncRepositoryImpl(this._datasource);

  @override
  Future<void> enqueue(SyncOperation operation) async {
    await _datasource.insert(operation);
  }

  @override
  Future<List<SyncOperation>> getPendingOperations() async {
    return _datasource.getPending();
  }

  @override
  Future<void> updateStatus(
    String operationId,
    SyncOperationStatus status, {
    String? errorMessage,
  }) async {
    await _datasource.updateStatus(operationId, status,
        errorMessage: errorMessage);
  }

  @override
  Future<void> markCompleted(String operationId) async {
    await _datasource.delete(operationId);
  }

  @override
  Future<void> incrementRetryCount(String operationId) async {
    await _datasource.incrementRetryCount(operationId);
  }

  @override
  Future<int> getPendingCount() async {
    return _datasource.getPendingCount();
  }

  @override
  Future<void> clearCompleted() async {
    await _datasource.clearCompleted();
  }

  @override
  Future<void> clearAll() async {
    await _datasource.clearAll();
  }
}
