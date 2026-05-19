import '../../application/services/sync_service.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/presence_events.dart';
import '../../core/events/invalidation_registry.dart';
import '../../domain/entities/presence.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/presence_repository.dart';
import '../datasources/presence_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation locale du repository de presences.
/// Delegue les operations au datasource local.
class PresenceRepositoryImpl implements PresenceRepository {
  final PresenceLocalDatasource _datasource;
  final RepositoryCache<List<Presence>> _cache = RepositoryCache<List<Presence>>();
  DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;

  PresenceRepositoryImpl(this._datasource);

  /// Injecte le client HTTP pour les appels API.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Injecte le bus d'evenements de domaine.
  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  /// Injecte le registre d'invalidation.
  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

  void _invalidateCaches() {
    _cache.invalidateByTag('presences');
  }

  /// Vide les caches memoire (appel lors de la deconnexion).
  void clearCache() => _invalidateCaches();

  @override
  Future<Presence> mark(Presence presence) async {
    final marked = await _datasource.add(presence);
    _invalidateCaches();
    _eventBus?.emit(PresenceCreatedEvent(
      presenceId: marked.id,
      seanceId: marked.seanceId,
      profilId: marked.profilId,
    ));
    _invalidationRegistry?.markInvalidated<PresenceCreatedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.presence,
      entityId: marked.id,
      operationType: SyncOperationType.create,
      data: marked.toJson(),
    );
    return marked;
  }

  @override
  Future<List<Presence>> getBySeance(String seanceId) async {
    final key = 'seance_$seanceId';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    return _cache.getOrFetch(key, () async {
      final list = _datasource.getBySeance(seanceId);
      _cache.set(key, list, tags: {'presences', key});
      return list;
    });
  }

  @override
  Future<List<Presence>> getByProfil(String profilId) async {
    return _datasource.getByProfil(profilId);
  }

  Future<void> upsertAllFromRemote(List<Presence> remoteList) async {
    await _datasource.upsertAllFromRemote(remoteList);
  }

  /// Verifie si un profil est deja enregistre pour une seance.
  bool isAlreadyPresent(String profilId, String seanceId) {
    return _datasource.isAlreadyPresent(profilId, seanceId);
  }

  /// Synchronise les presences depuis le backend vers le cache local.
  /// Retourne true si la synchronisation a reussi.
  Future<bool> syncFromApi() async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.presences);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[PresenceRepo] Erreur sync: ${failure.message}');
          return false;
        },
        (data) async {
          final List<dynamic> rawList;
          if (data is List) {
            rawList = data;
          } else if (data is Map<String, dynamic>) {
            // L'API peut retourner un objet avec les donnees dans une cle
            rawList = data.values.whereType<List>().expand((e) => e).toList();
          } else {
            return false;
          }

          final presences = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => _parsePresence(map))
              .where((p) => p.id.isNotEmpty)
              .toList();

          await _datasource.upsertAllFromRemote(presences);
          // ignore: avoid_print
          print(
            '[PresenceRepo] Synced ${presences.length} presences from backend',
          );
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[PresenceRepo] Exception sync: $e');
      return false;
    }
  }

  /// Parse une presence depuis les donnees du backend.
  Presence _parsePresence(Map<String, dynamic> map) {
    return Presence(
      id: (map['id']?.toString() ?? ''),
      horodateArrivee:
          DateTime.tryParse(
            (map['horodate_arrivee'] as String?) ??
                (map['horodateArrivee'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      typeProfil: _parseProfilType(map['type_profil'] as String?),
      profilId:
          (map['profil_id'] as String?) ?? (map['profilId'] as String?) ?? '',
      seanceId:
          (map['seance_id'] as String?) ?? (map['seanceId'] as String?) ?? '',
    );
  }

  /// Parse le type de profil.
  ProfilType _parseProfilType(String? type) {
    switch (type?.toLowerCase()) {
      case 'academicien':
        return ProfilType.academicien;
      case 'encadreur':
        return ProfilType.encadreur;
      default:
        return ProfilType.academicien;
    }
  }
}
