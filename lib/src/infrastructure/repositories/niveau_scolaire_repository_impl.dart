import '../../application/services/sync_service.dart';
import '../../domain/entities/niveau_scolaire.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/niveau_scolaire_repository.dart';
import '../datasources/niveau_scolaire_local_datasource.dart';
import '../datasources/academicien_local_datasource.dart';

/// Implementation concrete de [NiveauScolaireRepository] utilisant le stockage local.
class NiveauScolaireRepositoryImpl implements NiveauScolaireRepository {
  final NiveauScolaireLocalDatasource _datasource;
  final AcademicienLocalDatasource _academicienDatasource;
  SyncService? _syncService;

  NiveauScolaireRepositoryImpl(this._datasource, this._academicienDatasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<List<NiveauScolaire>> getAll() async {
    final niveaux = _datasource.getAll();
    niveaux.sort((a, b) => a.ordre.compareTo(b.ordre));
    return niveaux;
  }

  @override
  Future<NiveauScolaire?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<NiveauScolaire> create(NiveauScolaire niveau) async {
    final created = await _datasource.add(niveau);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.niveauScolaire,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<NiveauScolaire> update(NiveauScolaire niveau) async {
    final updated = await _datasource.update(niveau);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.niveauScolaire,
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
      entityType: SyncEntityType.niveauScolaire,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<int> countAcademiciens(String niveauId) async {
    final academiciens = await _academicienDatasource.getAll();
    return academiciens.where((a) => a.niveauScolaireId == niveauId).length;
  }
}
