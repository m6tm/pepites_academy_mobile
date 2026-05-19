import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/bulletin_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/bulletin.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/bulletin_repository.dart';
import '../datasources/bulletin_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository de bulletins de formation.
/// Delegue les operations au datasource local.
class BulletinRepositoryImpl implements BulletinRepository {
  final BulletinLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  final _cache = RepositoryCache<List<Bulletin>>();
  final _detailCache = RepositoryCache<Bulletin>();

  BulletinRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Injecte le client HTTP.
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

  @override
  Future<Bulletin> create(Bulletin bulletin) async {
    final created = await _datasource.add(bulletin);
    _cache.invalidateByTag('bulletins');
    _invalidationRegistry?.markInvalidated<BulletinCreatedEvent>();
    _eventBus?.emit(BulletinCreatedEvent(
      bulletinId: created.id,
      academicienId: created.academicienId,
    ));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Bulletin> update(Bulletin bulletin) async {
    final updated = await _datasource.update(bulletin);
    _cache.invalidateByTag('bulletins');
    _detailCache.invalidateKey(bulletin.id);
    _invalidationRegistry?.markInvalidated<BulletinCreatedEvent>();
    _eventBus?.emit(BulletinCreatedEvent(
      bulletinId: updated.id,
      academicienId: updated.academicienId,
    ));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<Bulletin?> getById(String id) async {
    final cached = _detailCache.get(id);
    if (cached != null) return cached;
    final result = _datasource.getById(id);
    if (result != null) {
      _detailCache.set(id, result, ttl: CacheTtl.bulletins, tags: {'bulletins', 'bulletin_$id'});
    }
    return result;
  }

  @override
  Future<List<Bulletin>> getByAcademicien(String academicienId) async {
    final key = 'academicien_$academicienId';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getByAcademicien(academicienId);
    _cache.set(key, result, ttl: CacheTtl.bulletins, tags: {'bulletins', 'academicien_$academicienId'});
    return result;
  }

  @override
  Future<List<Bulletin>> getAll() async {
    const key = 'all';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getAll();
    _cache.set(key, result, ttl: CacheTtl.bulletins, tags: {'bulletins'});
    return result;
  }

  @override
  Future<void> delete(String id) async {
    final existing = _datasource.getById(id);
    await _datasource.delete(id);
    _cache.invalidateByTag('bulletins');
    _detailCache.invalidateKey(id);
    _invalidationRegistry?.markInvalidated<BulletinDeletedEvent>();
    _eventBus?.emit(BulletinDeletedEvent(
      bulletinId: id,
      academicienId: existing?.academicienId ?? '',
    ));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Synchronise les bulletins depuis le backend.
  /// Fusionne les donnees distantes dans le cache local.
  /// Retourne false si le serveur est inaccessible ou en cas d'erreur.
  Future<bool> syncFromApi() async {
    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return false;
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.bulletins);

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
              .map((map) => _parseBulletinFromApi(map))
              .where((b) => b.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Parse un bulletin depuis le format API (snake_case).
  Bulletin _parseBulletinFromApi(Map<String, dynamic> map) {
    return Bulletin(
      id: map['id'] as String,
      dateDebutPeriode: DateTime.parse(
        (map['date_debut_periode'] as String?) ??
            (map['dateDebutPeriode'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
      dateFinPeriode: DateTime.parse(
        (map['date_fin_periode'] as String?) ??
            (map['dateFinPeriode'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
      typePeriode: _parsePeriodeType(map['type_periode'] as String?),
      academicienId:
          (map['academicien_id'] as String?) ??
          (map['academicienId'] as String?) ??
          '',
      encadreurId:
          (map['encadreur_id'] as String?) ??
          (map['encadreurId'] as String?) ??
          '',
      observationsGenerales:
          (map['observations_generales'] as String?) ??
          (map['observationsGenerales'] as String?) ??
          '',
      competences: _parseCompetences(
        map['competences'] as Map<String, dynamic>?,
      ),
      appreciations: _parseAppreciations(
        map['appreciations'] as List<dynamic>?,
      ),
      nbSeancesTotal:
          (map['nb_seances_total'] as int?) ??
          (map['nbSeancesTotal'] as int?) ??
          0,
      nbSeancesPresent:
          (map['nb_seances_present'] as int?) ??
          (map['nbSeancesPresent'] as int?) ??
          0,
      nbAnnotationsTotal:
          (map['nb_annotations_total'] as int?) ??
          (map['nbAnnotationsTotal'] as int?) ??
          0,
      dateGeneration: DateTime.parse(
        (map['date_generation'] as String?) ??
            (map['dateGeneration'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Parse le type de periode.
  PeriodeType _parsePeriodeType(String? type) {
    switch (type?.toLowerCase()) {
      case 'mois':
        return PeriodeType.mois;
      case 'trimestre':
        return PeriodeType.trimestre;
      case 'saison':
        return PeriodeType.saison;
      default:
        return PeriodeType.mois;
    }
  }

  /// Parse les competences depuis le format API.
  Competences _parseCompetences(Map<String, dynamic>? json) {
    if (json == null) return const Competences();
    return Competences(
      technique:
          (json['technique'] as num?)?.toDouble() ??
          (json['comp_technique'] as num?)?.toDouble() ??
          0,
      physique:
          (json['physique'] as num?)?.toDouble() ??
          (json['comp_physique'] as num?)?.toDouble() ??
          0,
      tactique:
          (json['tactique'] as num?)?.toDouble() ??
          (json['comp_tactique'] as num?)?.toDouble() ??
          0,
      mental:
          (json['mental'] as num?)?.toDouble() ??
          (json['comp_mental'] as num?)?.toDouble() ??
          0,
      espritEquipe:
          (json['espritEquipe'] as num?)?.toDouble() ??
          (json['comp_esprit_equipe'] as num?)?.toDouble() ??
          (json['esprit_equipe'] as num?)?.toDouble() ??
          0,
    );
  }

  /// Parse les appreciations depuis le format API.
  List<AppreciationDomaine> _parseAppreciations(List<dynamic>? list) {
    if (list == null) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (map) => AppreciationDomaine(
            domaine: (map['domaine'] as String?) ?? '',
            note: (map['note'] as num?)?.toDouble() ?? 0,
            commentaire: (map['commentaire'] as String?) ?? '',
          ),
        )
        .toList();
  }

  void clearCache() {
    _cache.clear();
    _detailCache.clear();
  }
}
