import 'package:flutter/foundation.dart';
import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/dossier_medical_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/dossier_medical.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/dossier_medical_repository.dart';
import '../datasources/dossier_medical_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation du repository des dossiers medicaux.
/// Gere le cache local, la synchronisation et les evenements de domaine.
class DossierMedicalRepositoryImpl implements DossierMedicalRepository {
  final DossierMedicalLocalDatasource _datasource;
  final RepositoryCache<List<DossierMedical>> _listCache = RepositoryCache<List<DossierMedical>>();
  final RepositoryCache<DossierMedical?> _detailCache = RepositoryCache<DossierMedical?>();

  DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  DossierMedicalRepositoryImpl(this._datasource);

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

  void _invalidateListCache(String academicienId) {
    _listCache.invalidateByTag('dossiers_medicaux_$academicienId');
    _listCache.invalidateByTag('dossiers_medicaux');
  }

  void _invalidateDetailCache(String id) {
    _detailCache.invalidateByTag('dossier_medical_$id');
  }

  @override
  Future<List<DossierMedical>> getByAcademicienId(String academicienId) async {
    final key = 'academicien_$academicienId';
    final cached = _listCache.get(key);
    if (cached != null) return cached;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      final stale = _listCache.getStale(key);
      if (stale != null) return stale;
      return _datasource.getByAcademicienId(academicienId);
    }

    return _listCache.getOrFetch(key, () async {
      final list = await _datasource.getByAcademicienId(academicienId);
      _listCache.set(
        key,
        list,
        ttl: CacheTtl.dossiersMedicaux,
        tags: {'dossiers_medicaux', 'dossiers_medicaux_$academicienId'},
      );
      return list;
    });
  }

  /// Variante SWR : emet d'abord la donnee stale puis la fraiche.
  Stream<List<DossierMedical>> getByAcademicienIdSwr(String academicienId) async* {
    final key = 'academicien_$academicienId';
    final stale = _listCache.getStale(key) ?? await _datasource.getByAcademicienId(academicienId);
    yield stale;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return;

    final fresh = await _listCache.getOrFetch(key, () => _datasource.getByAcademicienId(academicienId));
    _listCache.set(
      key,
      fresh,
      ttl: CacheTtl.dossiersMedicaux,
      tags: {'dossiers_medicaux', 'dossiers_medicaux_$academicienId'},
    );
    yield fresh;
  }

  @override
  Future<DossierMedical?> getById(String id) async {
    final cached = _detailCache.get(id);
    if (cached != null) return cached;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      return _detailCache.getStale(id) ?? await _datasource.getById(id);
    }

    return _detailCache.getOrFetch(id, () async {
      final dossier = await _datasource.getById(id);
      if (dossier != null) {
        _detailCache.set(
          id,
          dossier,
          ttl: CacheTtl.dossiersMedicaux,
          tags: {'dossiers_medicaux', 'dossier_medical_$id'},
        );
      }
      return dossier;
    });
  }

  @override
  Future<DossierMedical> create(DossierMedical dossier) async {
    final created = await _datasource.create(dossier);
    _invalidateListCache(created.academicienId);
    _eventBus?.emit(DossierMedicalCreatedEvent(created.id, created.academicienId));
    _invalidationRegistry?.markInvalidated<DossierMedicalCreatedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.dossierMedical,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<DossierMedical> update(DossierMedical dossier) async {
    final updated = await _datasource.update(dossier);
    _invalidateDetailCache(updated.id);
    _invalidateListCache(updated.academicienId);
    _eventBus?.emit(DossierMedicalUpdatedEvent(updated.id, updated.academicienId));
    _invalidationRegistry?.markInvalidated<DossierMedicalUpdatedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.dossierMedical,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final dossier = await _datasource.getById(id);
    await _datasource.delete(id);
    _detailCache.invalidateKey(id);
    if (dossier != null) {
      _invalidateListCache(dossier.academicienId);
    }
    _eventBus?.emit(DossierMedicalDeletedEvent(id, dossier?.academicienId ?? ''));
    _invalidationRegistry?.markInvalidated<DossierMedicalDeletedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.dossierMedical,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Vide les caches memoire (appel lors de la deconnexion).
  void clearCache() {
    _listCache.clear();
    _detailCache.clear();
  }

  /// Synchronise les dossiers medicaux d'un academicien depuis le backend.
  Future<bool> syncFromApi(String academicienId) async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(
        ApiEndpoints.dossiersMedicaux(academicienId),
      );

      return await result.fold(
        (failure) {
          debugPrint('[DossierMedicalRepo] Erreur sync: ${failure.message}');
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

          final dossiers = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => DossierMedical.fromJson(map))
              .where((d) => d.id.isNotEmpty)
              .toList();

          final local = await _datasource.getAll();
          final localMap = {for (final d in local) d.id: d};
          for (final remote in dossiers) {
            localMap[remote.id] = remote;
          }
          await _datasource.saveAll(localMap.values.toList());

          _invalidateListCache(academicienId);

          debugPrint(
            '[DossierMedicalRepo] Synced ${dossiers.length} dossiers for $academicienId',
          );
          return true;
        },
      );
    } catch (e) {
      debugPrint('[DossierMedicalRepo] Exception sync: $e');
      return false;
    }
  }
}
