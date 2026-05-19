import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/exercice_events.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/exercice.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/exercice_repository.dart';
import '../datasources/exercice_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository d'exercices.
/// Delegue les operations au datasource local et gere la synchronisation.
class ExerciceRepositoryImpl implements ExerciceRepository {
  final ExerciceLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  final _cache = RepositoryCache<List<Exercice>>();
  final _detailCache = RepositoryCache<Exercice>();

  ExerciceRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Migre un exercice local (ID timestamp) vers l'UUID assigne par le serveur.
  Future<void> migrateLocalId(String localId, String serverId) async {
    final local = _datasource.getById(localId);
    if (local == null) return;
    final migrated = local.copyWith(id: serverId);
    await _datasource.add(migrated);
    await _datasource.delete(localId);
  }

  /// Injecte le client HTTP.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Injecte le bus d'evenements.
  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  /// Injecte le registre d'invalidation.
  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

  /// Injecte le gardien de connectivite.
  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  @override
  Future<List<Exercice>> getByAtelierId(
    String atelierId, {
    bool forceRefresh = false,
  }) async {
    final key = 'atelier_$atelierId';
    if (!forceRefresh) {
      final cached = _cache.get(key);
      if (cached != null) return cached;
    }

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      final stale = _cache.getStale(key);
      if (stale != null) return stale;
      return _datasource.getByAtelier(atelierId);
    }

    return _cache.getOrFetch(key, () async {
      final local = _datasource.getByAtelier(atelierId);
      if (local.isEmpty && _dioClient != null) {
        await syncFromApi();
      }
      final result = _datasource.getByAtelier(atelierId);
      _cache.set(key, result, ttl: CacheTtl.exercices, tags: {'exercices', 'atelier_$atelierId'});
      return result;
    });
  }

  /// Variante SWR : emet d'abord les donnees stale puis les fraiches.
  Stream<List<Exercice>> getByAtelierIdSwr(String atelierId) async* {
    final key = 'atelier_$atelierId';
    final stale = _cache.getStale(key) ?? _datasource.getByAtelier(atelierId);
    if (stale.isNotEmpty) yield stale;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return;

    final fresh = await _cache.getOrFetch(key, () async {
      if (_dioClient != null) await syncFromApi();
      return _datasource.getByAtelier(atelierId);
    });
    _cache.set(key, fresh, ttl: CacheTtl.exercices, tags: {'exercices', 'atelier_$atelierId'});
    yield fresh;
  }

  @override
  Future<Exercice?> getById(String id) async {
    final cached = _detailCache.get(id);
    if (cached != null) return cached;
    final result = _datasource.getById(id);
    if (result != null) {
      _detailCache.set(id, result, ttl: CacheTtl.exercices, tags: {'exercices', 'exercice_$id'});
    }
    return result;
  }

  @override
  Future<Exercice> create(Exercice exercice) async {
    final created = await _datasource.add(exercice);
    _cache.invalidateByTag('atelier_${exercice.atelierId}');
    _invalidationRegistry?.markInvalidated<ExerciceCreatedEvent>();
    _eventBus?.emit(ExerciceCreatedEvent(exerciceId: created.id, atelierId: exercice.atelierId));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.exercice,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Exercice> update(Exercice exercice) async {
    final updated = await _datasource.update(exercice);
    _cache.invalidateByTag('atelier_${exercice.atelierId}');
    _detailCache.invalidateKey(exercice.id);
    _invalidationRegistry?.markInvalidated<ExerciceUpdatedEvent>();
    _eventBus?.emit(ExerciceUpdatedEvent(exerciceId: updated.id, atelierId: exercice.atelierId));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.exercice,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final existing = _datasource.getById(id);
    final atelierId = existing?.atelierId;
    await _datasource.delete(id);
    if (atelierId != null) {
      _cache.invalidateByTag('atelier_$atelierId');
    }
    _detailCache.invalidateKey(id);
    _invalidationRegistry?.markInvalidated<ExerciceDeletedEvent>();
    _eventBus?.emit(ExerciceDeletedEvent(exerciceId: id, atelierId: atelierId ?? ''));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.exercice,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<void> reorder(String atelierId, List<String> exerciceIds) async {
    await _datasource.reorder(atelierId, exerciceIds);
    _cache.invalidateByTag('atelier_$atelierId');
    _invalidationRegistry?.markInvalidated<ExerciceReorderedEvent>();
    _eventBus?.emit(ExerciceReorderedEvent(atelierId));

    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.exercice,
      entityId: atelierId,
      operationType: SyncOperationType.reorder,
      data: {'order': exerciceIds},
    );
  }

  @override
  Future<bool> close(String id) async {
    final existing = _datasource.getById(id);
    final atelierId = existing?.atelierId;
    if (existing != null) {
      await _datasource.update(existing.copyWith(statut: ExerciceStatut.ferme));
    }
    _cache.invalidateByTag('atelier_$atelierId');
    _detailCache.invalidateKey(id);

    if (_dioClient != null) {
      final result = await _dioClient!.put<dynamic>(
        '${ApiEndpoints.exercices}/$id/close',
        data: {},
      );

      return await result.fold(
        (failure) {
          return false;
        },
        (data) async {
          if (data is Map<String, dynamic>) {
            final atelierClosed = data['atelier_closed'] == true;
            _invalidationRegistry?.markInvalidated<ExerciceClosedEvent>();
            _eventBus?.emit(ExerciceClosedEvent(exerciceId: id, atelierId: atelierId ?? ''));
            return atelierClosed;
          }
          return false;
        },
      );
    }

    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.exercice,
      entityId: id,
      operationType: SyncOperationType.update,
      data: {'statut': 'ferme'},
    );

    _invalidationRegistry?.markInvalidated<ExerciceClosedEvent>();
    _eventBus?.emit(ExerciceClosedEvent(exerciceId: id, atelierId: atelierId ?? ''));
    return false;
  }

  /// Synchronise les exercices depuis le backend vers le cache local.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.exercices);

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

          final exercices = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => Exercice.fromJson(map))
              .where((e) => e.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(exercices);
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Met a jour le cache local avec les exercices provenant de l'API.
  Future<void> upsertAllFromRemote(List<Exercice> exercices) async {
    await _datasource.upsertAll(exercices);
  }

  /// Vide le cache in-memory.
  void clearCache() {
    _cache.clear();
    _detailCache.clear();
  }
}
