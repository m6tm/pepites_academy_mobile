import 'package:flutter/foundation.dart';
import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/bilan_medical_mensuel_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/network/connectivity_guard.dart';
import '../../core/resilience/mutation_resilience_handler.dart';
import '../../core/resilience/resilience_result.dart';
import '../../domain/entities/bilan_medical_mensuel.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/bilan_medical_mensuel_repository.dart';
import '../datasources/bilan_medical_mensuel_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation du repository des bilans medicaux mensuels.
/// Gere le cache local, la synchronisation et les evenements de domaine.
class BilanMedicalMensuelRepositoryImpl implements BilanMedicalMensuelRepository {
  final BilanMedicalMensuelLocalDatasource _datasource;
  final RepositoryCache<List<BilanMedicalMensuel>> _listCache = RepositoryCache<List<BilanMedicalMensuel>>();
  final RepositoryCache<BilanMedicalMensuel?> _detailCache = RepositoryCache<BilanMedicalMensuel?>();

  DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;
  MutationResilienceHandler? _resilienceHandler;

  BilanMedicalMensuelRepositoryImpl(this._datasource);

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

  /// Injecte le handler de résilience pour les mutations sur entité introuvable.
  void setMutationResilienceHandler(MutationResilienceHandler handler) {
    _resilienceHandler = handler;
  }

  void _invalidateListCache(String academicienId) {
    _listCache.invalidateByTag('bilans_medicaux_$academicienId');
    _listCache.invalidateByTag('bilans_medicaux');
  }

  void _invalidateDetailCache(String id) {
    _detailCache.invalidateByTag('bilan_medical_$id');
  }

  @override
  Future<List<BilanMedicalMensuel>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<List<BilanMedicalMensuel>> getByAcademicienId(String academicienId) async {
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
        tags: {'bilans_medicaux', 'bilans_medicaux_$academicienId'},
      );
      return list;
    });
  }

  @override
  Future<BilanMedicalMensuel?> getById(String id) async {
    final cached = _detailCache.get(id);
    if (cached != null) return cached;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      return _detailCache.getStale(id) ?? await _datasource.getById(id);
    }

    return _detailCache.getOrFetch(id, () async {
      final bilan = await _datasource.getById(id);
      if (bilan != null) {
        _detailCache.set(
          id,
          bilan,
          ttl: CacheTtl.dossiersMedicaux,
          tags: {'bilans_medicaux', 'bilan_medical_$id'},
        );
      }
      return bilan;
    });
  }

  @override
  Future<BilanMedicalMensuel> create(BilanMedicalMensuel bilan) async {
    final created = await _datasource.create(bilan);
    _invalidateListCache(created.academicienId);
    _eventBus?.emit(BilanMedicalMensuelCreatedEvent(created.id, created.academicienId));
    _invalidationRegistry?.markInvalidated<BilanMedicalMensuelCreatedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bilanMedicalMensuel,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<BilanMedicalMensuel> update(BilanMedicalMensuel bilan) async {
    final existing = await _datasource.getById(bilan.id);
    if (existing == null) {
      final recovered = await _resilienceHandler?.recover(
        entityType: SyncEntityType.bilanMedicalMensuel,
        entityId: bilan.id,
        operationType: SyncOperationType.update,
        fallbackPayload: bilan.toJson(),
      );
      if (recovered is ResilienceSuccess<Map<String, dynamic>>) {
        final map = recovered.data;
        final bilanMap = (map['bilan_medical_mensuel'] as Map<String, dynamic>?) ?? map;
        if (bilanMap.isNotEmpty) {
          final serverBilan = BilanMedicalMensuel.fromJson(bilanMap);
          await _datasource.update(serverBilan);
          _invalidateDetailCache(serverBilan.id);
          _invalidateListCache(serverBilan.academicienId);
          _eventBus?.emit(BilanMedicalMensuelUpdatedEvent(serverBilan.id, serverBilan.academicienId));
          _invalidationRegistry?.markInvalidated<BilanMedicalMensuelUpdatedEvent>();
          return serverBilan;
        }
      }
    }

    final updated = await _datasource.update(bilan);
    _invalidateDetailCache(updated.id);
    _invalidateListCache(updated.academicienId);
    _eventBus?.emit(BilanMedicalMensuelUpdatedEvent(updated.id, updated.academicienId));
    _invalidationRegistry?.markInvalidated<BilanMedicalMensuelUpdatedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bilanMedicalMensuel,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final existing = await _datasource.getById(id);

    if (existing == null) {
      final recovered = await _resilienceHandler?.recover(
        entityType: SyncEntityType.bilanMedicalMensuel,
        entityId: id,
        operationType: SyncOperationType.delete,
      );

      if (recovered is ResilienceSuccess<Map<String, dynamic>>) {
        _detailCache.invalidateKey(id);
        _eventBus?.emit(BilanMedicalMensuelDeletedEvent(id, ''));
        _invalidationRegistry?.markInvalidated<BilanMedicalMensuelDeletedEvent>();
        return;
      }

      // Fallback : pas de données source ou echec permanent.
      if (_isLocalId(id)) {
        await _syncService?.cancelOperationsForEntity(SyncEntityType.bilanMedicalMensuel, id);
      } else {
        await _syncService?.enqueueOperation(
          entityType: SyncEntityType.bilanMedicalMensuel,
          entityId: id,
          operationType: SyncOperationType.delete,
          data: {'id': id},
        );
      }
      _detailCache.invalidateKey(id);
      _eventBus?.emit(BilanMedicalMensuelDeletedEvent(id, ''));
      _invalidationRegistry?.markInvalidated<BilanMedicalMensuelDeletedEvent>();
      return;
    }

    await _datasource.delete(id);
    _detailCache.invalidateKey(id);
    _invalidateListCache(existing.academicienId);
    _eventBus?.emit(BilanMedicalMensuelDeletedEvent(id, existing.academicienId));
    _invalidationRegistry?.markInvalidated<BilanMedicalMensuelDeletedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bilanMedicalMensuel,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  bool _isLocalId(String id) {
    // Les IDs serveur sont des UUID v4 ; les IDs locaux offline sont des
    // timestamps numeriques.
    return !RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(id);
  }

  /// Vide les caches memoire (appel lors de la deconnexion).
  @override
  void clearCache() {
    _listCache.clear();
    _detailCache.clear();
  }

  /// Synchronise les bilans medicaux mensuels d'un academicien depuis le backend.
  @override
  Future<bool> syncFromApi(String academicienId) async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(
        ApiEndpoints.bilansMedicaux(academicienId),
      );

      return await result.fold(
        (failure) {
          debugPrint('[BilanMedicalRepo] Erreur sync: ${failure.message}');
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

          final bilans = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => BilanMedicalMensuel.fromJson(map))
              .where((b) => b.id.isNotEmpty)
              .toList();

          final local = await _datasource.getAll();
          final localMap = {for (final b in local) b.id: b};
          for (final remote in bilans) {
            localMap[remote.id] = remote;
          }
          await _datasource.saveAll(localMap.values.toList());

          _invalidateListCache(academicienId);

          debugPrint(
            '[BilanMedicalRepo] Synced ${bilans.length} bilans for $academicienId',
          );
          return true;
        },
      );
    } catch (e) {
      debugPrint('[BilanMedicalRepo] Exception sync: $e');
      return false;
    }
  }
}
