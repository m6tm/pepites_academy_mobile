import '../../application/services/sync_service.dart';
import '../../domain/entities/encadreur.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/encadreur_repository.dart';
import '../datasources/encadreur_local_datasource.dart';

/// Implémentation concrète de [EncadreurRepository] utilisant le stockage local.
class EncadreurRepositoryImpl implements EncadreurRepository {
  final EncadreurLocalDatasource _datasource;
  SyncService? _syncService;

  EncadreurRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<Encadreur?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Encadreur>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<Encadreur> create(Encadreur encadreur) async {
    final created = await _datasource.add(encadreur);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.encadreur,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Encadreur> update(Encadreur encadreur) async {
    final updated = await _datasource.update(encadreur);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.encadreur,
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
      entityType: SyncEntityType.encadreur,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<Encadreur?> getByQrCode(String qrCode) async {
    return _datasource.getByQrCode(qrCode);
  }

  @override
  Future<List<Encadreur>> search(String query) async {
    final all = _datasource.getAll();
    final lowerQuery = query.toLowerCase();
    return all.where((e) {
      return e.nom.toLowerCase().contains(lowerQuery) ||
          e.prenom.toLowerCase().contains(lowerQuery) ||
          e.specialite.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
