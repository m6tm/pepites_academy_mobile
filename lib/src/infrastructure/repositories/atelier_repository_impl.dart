import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
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
  final _cache = RepositoryCache<List<Atelier>>();
  SyncService? _syncService;
  DioClient? _dioClient;

  AtelierRepositoryImpl(this._datasource);

  void _invalidateCache() {
    _cache.invalidateByTag('ateliers');
  }

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setDioClient(DioClient client) {
    _dioClient = client;
  }

@override
  Future<List<Atelier>> getBySeanceId(String seanceId) async {
    final key = 'seance_$seanceId';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    return _cache.getOrFetch(key, () async {
      var local = _datasource.getBySeance(seanceId);
      if (local.isEmpty && _dioClient != null) {
        await syncFromApi();
        local = _datasource.getBySeance(seanceId);
      }
      _cache.set(
        key,
        local,
        ttl: CacheTtl.ateliers,
        tags: {'ateliers', key},
      );
      return local;
    });
  }

  @override
  Future<Atelier?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<Atelier> create(Atelier atelier) async {
    final created = await _datasource.add(atelier);
    _invalidateCache();
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
    _invalidateCache();
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
    _invalidateCache();
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
    _invalidateCache();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.atelier,
      entityId: seanceId,
      operationType: SyncOperationType.reorder,
      data: {'order': atelierIds},
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
