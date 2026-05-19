import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/annotation_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../datasources/annotation_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  final _cacheAtelier = RepositoryCache<List<Annotation>>();
  final _cacheAcademicien = RepositoryCache<List<Annotation>>();
  final _cacheSeance = RepositoryCache<List<Annotation>>();

  AnnotationRepositoryImpl(this._datasource);

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setDioClient(DioClient client) {
    _dioClient = client;
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

  void _invalidateAll() {
    _cacheAtelier.invalidateByTag('annotations');
    _cacheAcademicien.invalidateByTag('annotations');
    _cacheSeance.invalidateByTag('annotations');
  }

  @override
  Future<Annotation> create(Annotation annotation) async {
    final created = await _datasource.add(annotation);
    _invalidateAll();
    _invalidationRegistry?.markInvalidated<AnnotationCreatedEvent>();
    _eventBus?.emit(AnnotationCreatedEvent(
      annotationId: created.id,
      atelierId: created.atelierId,
      academicienId: created.academicienId,
      exerciceId: created.exerciceId,
    ));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.annotation,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<List<Annotation>> getAll() async {
    final list = _datasource.getAll();
    list.sort((a, b) => b.horodate.compareTo(a.horodate));
    return list;
  }

  @override
  Future<List<Annotation>> getByAcademicien(String academicienId) async {
    final key = 'academicien_$academicienId';
    final cached = _cacheAcademicien.get(key);
    if (cached != null) return cached;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      final stale = _cacheAcademicien.getStale(key);
      if (stale != null) return stale;
    }

    return _cacheAcademicien.getOrFetch(key, () async {
      final local = _datasource.getByAcademicien(academicienId);
      if (local.isEmpty && _dioClient != null) {
        await _syncByFilter(academicienId: academicienId);
      }
      final result = _datasource.getByAcademicien(academicienId);
      _cacheAcademicien.set(key, result, ttl: CacheTtl.annotations, tags: {'annotations', 'academicien_$academicienId'});
      return result;
    });
  }

  @override
  Future<List<Annotation>> getByEncadreur(String encadreurId) async {
    final list =
        _datasource.getAll().where((a) => a.encadreurId == encadreurId).toList()
          ..sort((a, b) => b.horodate.compareTo(a.horodate));
    return list;
  }

  @override
  Future<List<Annotation>> getByAtelier(
    String atelierId, {
    bool forceRefresh = false,
  }) async {
    final key = 'atelier_$atelierId';
    if (!forceRefresh) {
      final cached = _cacheAtelier.get(key);
      if (cached != null) return cached;
    }

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      final stale = _cacheAtelier.getStale(key);
      if (stale != null) return stale;
    }

    return _cacheAtelier.getOrFetch(key, () async {
      final local = _datasource.getByAtelier(atelierId);
      if (local.isEmpty && _dioClient != null) {
        await _syncByFilter(atelierId: atelierId);
      }
      final result = _datasource.getByAtelier(atelierId);
      _cacheAtelier.set(key, result, ttl: CacheTtl.annotations, tags: {'annotations', 'atelier_$atelierId'});
      return result;
    });
  }

  @override
  Future<List<Annotation>> getBySeance(String seanceId) async {
    final key = 'seance_$seanceId';
    final cached = _cacheSeance.get(key);
    if (cached != null) return cached;

    final result = _datasource.getBySeance(seanceId);
    _cacheSeance.set(key, result, ttl: CacheTtl.annotations, tags: {'annotations', 'seance_$seanceId'});
    return result;
  }

  Future<bool> _syncByFilter({
    String? atelierId,
    String? academicienId,
  }) async {
    if (_dioClient == null) return false;
    try {
      final params = <String, dynamic>{};
      if (atelierId != null) params['atelier_id'] = atelierId;
      if (academicienId != null) params['academicien_id'] = academicienId;

      final result = await _dioClient!.get<dynamic>(
        ApiEndpoints.annotations,
        queryParameters: params,
      );

      return result.fold(
        (_) => false,
        (data) async {
          final List<dynamic> rawList;
          if (data is List) {
            rawList = data;
          } else if (data is Map<String, dynamic>) {
            rawList = data.values.whereType<List>().expand((e) => e).toList();
          } else {
            return false;
          }
          final remote = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => Annotation.fromJson(map))
              .where((a) => a.id.isNotEmpty)
              .toList();
          await _datasource.upsertAll(remote);
          return true;
        },
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.annotations);

      return result.fold(
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

          final remote = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => Annotation.fromJson(map))
              .where((a) => a.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Annotation>> getByAcademicienAndAtelier(
    String academicienId,
    String atelierId,
  ) async {
    return _datasource.getByAcademicienAndAtelier(academicienId, atelierId);
  }

  @override
  Future<List<Annotation>> getByExercice(String exerciceId) async {
    return _datasource.getByExercice(exerciceId);
  }

  @override
  Future<List<Annotation>> getByAcademicienAndExercice(
    String academicienId,
    String exerciceId,
  ) async {
    return _datasource.getByAcademicienAndExercice(academicienId, exerciceId);
  }

  Future<Annotation> update(Annotation annotation) async {
    final updated = await _datasource.update(annotation);
    _invalidateAll();
    _invalidationRegistry?.markInvalidated<AnnotationUpdatedEvent>();
    _eventBus?.emit(AnnotationUpdatedEvent(
      annotationId: updated.id,
      atelierId: updated.atelierId,
      academicienId: updated.academicienId,
    ));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.annotation,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  Future<void> delete(String id) async {
    final existing = _datasource.getAll().firstWhere((a) => a.id == id);
    await _datasource.delete(id);
    _invalidateAll();
    _invalidationRegistry?.markInvalidated<AnnotationDeletedEvent>();
    _eventBus?.emit(AnnotationDeletedEvent(
      annotationId: id,
      atelierId: existing.atelierId,
    ));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.annotation,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  void clearCache() {
    _cacheAtelier.clear();
    _cacheAcademicien.clear();
    _cacheSeance.clear();
  }
}
