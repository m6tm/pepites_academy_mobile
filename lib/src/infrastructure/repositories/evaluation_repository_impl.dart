import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/evaluation_events.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../datasources/evaluation_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository d'evaluations multicriteres.
/// Delegue les operations au datasource local avec synchronisation differee.
/// Un cache memoire LRU evite les deserialisations repetees depuis SharedPreferences.
class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  final _cacheAtelier = RepositoryCache<List<Evaluation>>();
  final _cacheAcademicien = RepositoryCache<List<Evaluation>>();
  final _cacheSeance = RepositoryCache<List<Evaluation>>();

  EvaluationRepositoryImpl(this._datasource);

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

  void _invalidateCaches() {
    _cacheAtelier.invalidateByTag('evaluations');
    _cacheAcademicien.invalidateByTag('evaluations');
    _cacheSeance.invalidateByTag('evaluations');
  }

  @override
  Future<Evaluation> create(Evaluation evaluation) async {
    final created = await _datasource.add(evaluation);
    _invalidateCaches();
    _invalidationRegistry?.markInvalidated<EvaluationCreeeEvent>();
    _eventBus?.emit(EvaluationCreeeEvent(
      evaluationId: created.id,
      academicienId: created.academicienId,
      atelierId: created.atelierId,
      seanceId: created.seanceId,
    ));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.evaluation,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Evaluation?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Evaluation>> getByAcademicien(String academicienId) async {
    final key = 'academicien_$academicienId';
    final cached = _cacheAcademicien.get(key);
    if (cached != null) return cached;

    return _cacheAcademicien.getOrFetch(key, () async {
      final result = _datasource.getByAcademicien(academicienId);
      _cacheAcademicien.set(
        key,
        result,
        ttl: CacheTtl.evaluations,
        tags: {'evaluations', 'academicien_$academicienId'},
      );
      return result;
    });
  }

  /// Variante SWR pour l'historique academicien.
  Stream<List<Evaluation>> getByAcademicienSwr(String academicienId) async* {
    final key = 'academicien_$academicienId';
    final stale = _cacheAcademicien.getStale(key) ?? _datasource.getByAcademicien(academicienId);
    if (stale.isNotEmpty) yield stale;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return;

    final fresh = await _cacheAcademicien.getOrFetch(key, () async => _datasource.getByAcademicien(academicienId));
    _cacheAcademicien.set(key, fresh, ttl: CacheTtl.evaluations, tags: {'evaluations', 'academicien_$academicienId'});
    yield fresh;
  }

  @override
  Future<List<Evaluation>> getByAtelier(String atelierId) async {
    final key = 'atelier_$atelierId';
    final cached = _cacheAtelier.get(key);
    if (cached != null) return cached;

    return _cacheAtelier.getOrFetch(key, () async {
      final result = _datasource.getByAtelier(atelierId);
      _cacheAtelier.set(
        key,
        result,
        ttl: CacheTtl.evaluations,
        tags: {'evaluations', 'atelier_$atelierId'},
      );
      return result;
    });
  }

  /// Variante SWR pour les evaluations d'un atelier.
  Stream<List<Evaluation>> getByAtelierSwr(String atelierId) async* {
    final key = 'atelier_$atelierId';
    final stale = _cacheAtelier.getStale(key) ?? _datasource.getByAtelier(atelierId);
    if (stale.isNotEmpty) yield stale;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return;

    final fresh = await _cacheAtelier.getOrFetch(key, () async => _datasource.getByAtelier(atelierId));
    _cacheAtelier.set(key, fresh, ttl: CacheTtl.evaluations, tags: {'evaluations', 'atelier_$atelierId'});
    yield fresh;
  }

  @override
  Future<List<Evaluation>> getBySeance(String seanceId) async {
    final key = 'seance_$seanceId';
    final cached = _cacheSeance.get(key);
    if (cached != null) return cached;

    return _cacheSeance.getOrFetch(key, () async {
      final result = _datasource.getBySeance(seanceId);
      _cacheSeance.set(
        key,
        result,
        ttl: CacheTtl.evaluations,
        tags: {'evaluations', 'seance_$seanceId'},
      );
      return result;
    });
  }

  @override
  Future<List<Evaluation>> getByAcademicienAndAtelier(
    String academicienId,
    String atelierId,
  ) async {
    return _datasource.getByAcademicienAndAtelier(academicienId, atelierId);
  }

  @override
  Future<Evaluation> update(Evaluation evaluation) async {
    final updated = await _datasource.update(evaluation);
    _invalidateCaches();
    _invalidationRegistry?.markInvalidated<EvaluationUpdatedEvent>();
    _eventBus?.emit(EvaluationUpdatedEvent(
      evaluationId: updated.id,
      academicienId: updated.academicienId,
      atelierId: updated.atelierId,
      seanceId: updated.seanceId,
    ));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.evaluation,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    _invalidateCaches();
    _invalidationRegistry?.markInvalidated<EvaluationDeletedEvent>();
    _eventBus?.emit(EvaluationDeletedEvent(id));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.evaluation,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Synchronise les evaluations depuis le backend et invalide le cache local.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.evaluations);

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
              .map((map) => Evaluation.fromJson(map))
              .where((e) => e.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          _invalidateCaches();
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  void clearCache() {
    _cacheAtelier.clear();
    _cacheAcademicien.clear();
    _cacheSeance.clear();
  }
}
