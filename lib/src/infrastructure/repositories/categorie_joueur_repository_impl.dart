import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/events/referentiel_events.dart';
import '../../core/network/connectivity_guard.dart';
import '../../core/resilience/mutation_resilience_handler.dart';
import '../../core/resilience/resilience_result.dart';
import '../../domain/entities/categorie_joueur.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/categorie_joueur_repository.dart';
import '../datasources/categorie_joueur_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation concrete de [CategorieJoueurRepository] utilisant le stockage local.
class CategorieJoueurRepositoryImpl implements CategorieJoueurRepository {
  final CategorieJoueurLocalDatasource _datasource;
  DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;
  MutationResilienceHandler? _resilienceHandler;

  final _cache = RepositoryCache<List<CategorieJoueur>>();
  final _detailCache = RepositoryCache<CategorieJoueur>();

  CategorieJoueurRepositoryImpl(this._datasource);

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

  @override
  Future<List<CategorieJoueur>> getAll() async {
    const key = 'all';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getAll();
    result.sort((a, b) => a.ordre.compareTo(b.ordre));
    _cache.set(
      key,
      result,
      ttl: CacheTtl.referentiel,
      tags: {'referentiel', 'categories'},
    );
    return result;
  }

  @override
  Future<CategorieJoueur?> getById(String id) async {
    final cached = _detailCache.get(id);
    if (cached != null) return cached;

    final result = _datasource.getById(id);
    if (result != null) {
      _detailCache.set(
        id,
        result,
        ttl: CacheTtl.referentiel,
        tags: {'referentiel', 'categorie_$id'},
      );
    }
    return result;
  }

  @override
  Future<CategorieJoueur> create(CategorieJoueur categorie) async {
    final created = await _datasource.add(categorie);
    _cache.invalidateByTag('referentiel');
    _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
    _eventBus?.emit(const ReferentielUpdatedEvent());
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.categorieJoueur,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<CategorieJoueur> update(CategorieJoueur categorie) async {
    final existing = _datasource.getById(categorie.id);
    if (existing == null) {
      final recovered = await _resilienceHandler?.recover(
        entityType: SyncEntityType.categorieJoueur,
        entityId: categorie.id,
        operationType: SyncOperationType.update,
        fallbackPayload: categorie.toJson(),
      );
      if (recovered is ResilienceSuccess<Map<String, dynamic>>) {
        final map = recovered.data;
        final categorieMap = (map['categorie_joueur'] as Map<String, dynamic>?) ?? map;
        if (categorieMap.isNotEmpty) {
          final serverCategorie = _parseCategorieJoueur(categorieMap);
          await _datasource.update(serverCategorie);
          _cache.invalidateByTag('referentiel');
          _detailCache.invalidateKey(serverCategorie.id);
          _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
          _eventBus?.emit(const ReferentielUpdatedEvent());
          return serverCategorie;
        }
      }
    }

    final updated = await _datasource.update(categorie);
    _cache.invalidateByTag('referentiel');
    _detailCache.invalidateKey(categorie.id);
    _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
    _eventBus?.emit(const ReferentielUpdatedEvent());
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.categorieJoueur,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final existing = _datasource.getById(id);

    if (existing == null) {
      final recovered = await _resilienceHandler?.recover(
        entityType: SyncEntityType.categorieJoueur,
        entityId: id,
        operationType: SyncOperationType.delete,
      );

      if (recovered is ResilienceSuccess<Map<String, dynamic>>) {
        _cache.invalidateByTag('referentiel');
        _detailCache.invalidateKey(id);
        _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
        _eventBus?.emit(const ReferentielUpdatedEvent());
        return;
      }

      // Fallback : pas de données source ou echec permanent.
      if (_isLocalId(id)) {
        await _syncService?.cancelOperationsForEntity(SyncEntityType.categorieJoueur, id);
      } else {
        await _syncService?.enqueueOperation(
          entityType: SyncEntityType.categorieJoueur,
          entityId: id,
          operationType: SyncOperationType.delete,
          data: {'id': id},
        );
      }
      _cache.invalidateByTag('referentiel');
      _detailCache.invalidateKey(id);
      _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
      _eventBus?.emit(const ReferentielUpdatedEvent());
      return;
    }

    await _datasource.delete(id);
    _cache.invalidateByTag('referentiel');
    _detailCache.invalidateKey(id);
    _invalidationRegistry?.markInvalidated<ReferentielUpdatedEvent>();
    _eventBus?.emit(const ReferentielUpdatedEvent());
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.categorieJoueur,
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

  /// Migre une categorie locale (ID timestamp) vers l'UUID assigne par le serveur.
  Future<void> migrateLocalId(String localId, String serverId) async {
    final local = _datasource.getById(localId);
    if (local == null) return;
    final migrated = local.copyWith(id: serverId);
    await _datasource.add(migrated);
    await _datasource.delete(localId);
    _cache.invalidateByTag('referentiel');
  }

  /// Synchronise les categories depuis le backend (le serveur fait foi).
  Future<bool> syncFromApi() async {
    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return false;
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.categoriesJoueurs);

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

          final categories = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => _parseCategorieJoueur(map))
              .where((c) => c.id.isNotEmpty)
              .toList();

          await _datasource.upsertAllFromRemote(categories);
          _cache.invalidateByTag('referentiel');
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  CategorieJoueur _parseCategorieJoueur(Map<String, dynamic> map) {
    return CategorieJoueur(
      id: (map['id']?.toString() ?? ''),
      nom: (map['nom'] as String?) ?? '',
      description: map['description'] as String?,
      ordre: (map['ordre'] as int?) ?? 0,
      createdAt:
          DateTime.tryParse(
            (map['created_at'] as String?) ??
                (map['createdAt'] as String?) ??
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
