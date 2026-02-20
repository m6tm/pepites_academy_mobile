import '../../application/services/sync_service.dart';
import '../../domain/entities/bulletin.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/bulletin_repository.dart';
import '../datasources/bulletin_local_datasource.dart';

/// Implementation locale du repository de bulletins de formation.
/// Delegue les operations au datasource local.
class BulletinRepositoryImpl implements BulletinRepository {
  final BulletinLocalDatasource _datasource;
  SyncService? _syncService;

  BulletinRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<Bulletin> create(Bulletin bulletin) async {
    final created = await _datasource.add(bulletin);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Bulletin> update(Bulletin bulletin) async {
    final updated = await _datasource.update(bulletin);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<Bulletin?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Bulletin>> getByAcademicien(String academicienId) async {
    return _datasource.getByAcademicien(academicienId);
  }

  @override
  Future<List<Bulletin>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }
}
