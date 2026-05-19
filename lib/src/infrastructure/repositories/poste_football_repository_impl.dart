import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/events/referentiel_events.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/poste_football.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/poste_football_repository.dart';
import '../datasources/poste_football_local_datasource.dart';
import '../datasources/academicien_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation concrete de [PosteFootballRepository] utilisant le stockage local.
class PosteFootballRepositoryImpl implements PosteFootballRepository {
  final PosteFootballLocalDatasource _datasource;
  final AcademicienLocalDatasource _academicienDatasource;
  DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  final _cache = RepositoryCache<List<PosteFootball>>();
  final _detailCache = RepositoryCache<PosteFootball>();

  PosteFootballRepositoryImpl(this._datasource, this._academicienDatasource);

  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  @override
  Future<List<PosteFootball>> getAll() async {
    const key = 'all';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getAll();
    _cache.set(key, result, ttl: CacheTtl.referentiel, tags: {'referentiel', 'postes'});
    return result;
  }

  @override
  Future<PosteFootball?> getById(String id) async {
    final cached = _detailCache.get(id);
    if (cached != null) return cached;

    final result = _datasource.getById(id);
    if (result != null) {
      _detailCache.set(id, result, ttl: CacheTtl.referentiel, tags: {'referentiel', 'poste_$id'});
    }
    return result;
  }

  @override
  Future<PosteFootball> create(PosteFootball poste) async {
    final created = await _datasource.add(poste);
    _cache.invalidateByTag('referentiel');
    _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
    _eventBus?.emit(const ReferentielUpdatedEvent());
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
    _cache.invalidateByTag('referentiel');
    _detailCache.invalidateKey(poste.id);
    _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
    _eventBus?.emit(const ReferentielUpdatedEvent());
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
    _cache.invalidateByTag('referentiel');
    _detailCache.invalidateKey(id);
    _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
    _eventBus?.emit(const ReferentielUpdatedEvent());
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

  Future<bool> syncFromApi() async {
    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return false;
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.postesFootball);

      return await result.fold(
        (failure) {
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

          final postes = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => _parsePosteFootball(map))
              .where((p) => p.id.isNotEmpty)
              .toList();

          await _datasource.saveAll(postes);
          _cache.invalidateByTag('referentiel');
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  PosteFootball _parsePosteFootball(Map<String, dynamic> map) {
    return PosteFootball(
      id: (map['id']?.toString() ?? ''),
      nom: (map['nom'] as String?) ?? '',
      description: map['description'] as String?,
      iconeCodePoint: map['icone_code_point'] as String?,
      createdAt:
          DateTime.tryParse(
            (map['created_at'] as String?) ??
                (map['createdAt'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(
            (map['updated_at'] as String?) ??
                (map['updatedAt'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
    );
  }

  void clearCache() {
    _cache.clear();
    _detailCache.clear();
  }
}
