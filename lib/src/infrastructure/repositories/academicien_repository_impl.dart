import '../../application/services/sync_service.dart';
import '../../domain/entities/academicien.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/academicien_repository.dart';
import '../datasources/academicien_local_datasource.dart';

/// Implementation locale du repository academicien.
/// Delegue les operations au datasource local.
class AcademicienRepositoryImpl implements AcademicienRepository {
  final AcademicienLocalDatasource _datasource;
  SyncService? _syncService;

  AcademicienRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<Academicien?> getById(String id) => _datasource.getById(id);

  @override
  Future<List<Academicien>> getAll() => _datasource.getAll();

  @override
  Future<Academicien> create(Academicien academicien) async {
    final created = await _datasource.create(academicien);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Academicien> update(Academicien academicien) async {
    final updated = await _datasource.update(academicien);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<Academicien?> getByQrCode(String qrCode) =>
      _datasource.getByQrCode(qrCode);

  @override
  Future<List<Academicien>> search(String query) => _datasource.search(query);

  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }
}
