import '../../application/services/sync_service.dart';
import '../../domain/entities/atelier.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/atelier_repository.dart';
import '../datasources/atelier_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository d'ateliers.
/// Delegue les operations au datasource local.
class AtelierRepositoryImpl implements AtelierRepository {
  final AtelierLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;

  AtelierRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Injecte le client HTTP.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  @override
  Future<List<Atelier>> getBySeanceId(String seanceId) async {
    return _datasource.getBySeance(seanceId);
  }

  @override
  Future<Atelier?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<Atelier> create(Atelier atelier) async {
    final created = await _datasource.add(atelier);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.atelier,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Atelier> update(Atelier atelier) async {
    final updated = await _datasource.update(atelier);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.atelier,
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
      entityType: SyncEntityType.atelier,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<void> reorder(String seanceId, List<String> atelierIds) async {
    // reorder retourne les ateliers avec leurs nouveaux ordres
    await _datasource.reorder(seanceId, atelierIds);

    // Appel direct a l'API de reorder pour une mise a jour atomique
    if (_dioClient != null) {
      final result = await _dioClient!.post(
        ApiEndpoints.ateliersReorder,
        data: {'seance_id': seanceId, 'atelier_ids': atelierIds},
      );

      result.fold(
        (failure) {
          // ignore: avoid_print
          print('[AtelierRepository] Erreur reorder API: ${failure.message}');
        },
        (response) {
          // ignore: avoid_print
          print('[AtelierRepository] Reorder API succes');
        },
      );
    }
  }

  /// Met a jour le cache local avec les ateliers provenant de l'API.
  /// N'enqueue pas d'operation de sync (donnees deja sur le serveur).
  Future<void> upsertAllFromRemote(List<Atelier> ateliers) async {
    await _datasource.upsertAll(ateliers);
  }
}
