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
    final local = _datasource.getBySeance(seanceId);
    if (local.isEmpty && _dioClient != null) {
      // Stratégie cache-first : si vide, on tente de synchroniser
      await syncFromApi();
      return _datasource.getBySeance(seanceId);
    }
    return local;
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
    await _datasource.reorder(seanceId, atelierIds);

    // Enregistre l'opération de réordonnancement pour synchronisation
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.atelier,
      entityId: seanceId, // On utilise l'ID de la séance comme référence
      operationType: SyncOperationType.reorder,
      data: {'seance_id': seanceId, 'atelier_ids': atelierIds},
    );
  }

  /// Synchronise les ateliers depuis le backend.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.ateliers);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[AtelierRepo] Erreur sync: ${failure.message}');
          return false;
        },
        (data) async {
          final List<dynamic> rawList;
          if (data is List) {
            rawList = data;
          } else if (data is Map<String, dynamic>) {
            rawList = data.values.whereType<List>().expand((e) => e).toList();
          } else {
            return false;
          }

          final ateliers = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => Atelier.fromJson(map))
              .where((a) => a.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(ateliers);
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AtelierRepo] Exception sync: $e');
      return false;
    }
  }

  /// Met à jour le cache local avec les ateliers provenant de l'API.
  Future<void> upsertAllFromRemote(List<Atelier> ateliers) async {
    await _datasource.upsertAll(ateliers);
  }
}
