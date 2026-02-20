import '../../application/services/sync_service.dart';
import '../../domain/entities/poste_football.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/poste_football_repository.dart';
import '../datasources/poste_football_local_datasource.dart';
import '../datasources/academicien_local_datasource.dart';

/// Implementation concrete de [PosteFootballRepository] utilisant le stockage local.
class PosteFootballRepositoryImpl implements PosteFootballRepository {
  final PosteFootballLocalDatasource _datasource;
  final AcademicienLocalDatasource _academicienDatasource;
  SyncService? _syncService;

  PosteFootballRepositoryImpl(this._datasource, this._academicienDatasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<List<PosteFootball>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<PosteFootball?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<PosteFootball> create(PosteFootball poste) async {
    final created = await _datasource.add(poste);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.posteFootball,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<PosteFootball> update(PosteFootball poste) async {
    final updated = await _datasource.update(poste);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.posteFootball,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.posteFootball,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<int> countAcademiciens(String posteId) async {
    final academiciens = await _academicienDatasource.getAll();
    return academiciens.where((a) => a.posteFootballId == posteId).length;
  }
}
