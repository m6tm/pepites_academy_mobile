import 'dart:convert';

import '../../../l10n/app_localizations.dart';
import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/events/seance_events.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/seance.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/seance_repository.dart';
import '../datasources/seance_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository de seances.
/// Delegue les operations au datasource local.
class SeanceRepositoryImpl implements SeanceRepository {
  final SeanceLocalDatasource _datasource;
  final RepositoryCache<SeanceWithStats> _cache =
      RepositoryCache<SeanceWithStats>(maxSize: 1);
  final RepositoryCache<List<Seance>> _listCache = RepositoryCache<List<Seance>>();
  SyncService? _syncService;
  DioClient? _dioClient;
  AppLocalizations? _l10n;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  SeanceRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Migre une seance locale (ID timestamp) vers l'UUID assigne par le serveur.
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

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Injecte le bus d'evenements de domaine.
  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  /// Injecte le registre d'invalidation.
  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

  /// Injecte le garde de connectivite.
  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  void _invalidateCaches() {
    _cache.invalidateByTag('seances');
    _listCache.invalidateByTag('seances');
  }

  @override
  Future<Seance?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Seance>> getAll() async {
    const key = 'all';
    final cached = _listCache.get(key);
    if (cached != null) return cached;

    return _listCache.getOrFetch(key, () async {
      final list = _datasource.getAll();
      _listCache.set(key, list, ttl: CacheTtl.seances, tags: {'seances'});
      return list;
    });
  }

  /// Vide les caches memoire (appel lors de la deconnexion).
  void clearCache() {
    _cache.clear();
    _listCache.clear();
  }

  /// Fusionne une liste de donnees distantes dans le cache local
  /// sans declencher d'operation de synchronisation vers le serveur.
  Future<void> upsertAllFromRemote(List<Seance> remoteList) async {
    final local = _datasource.getAll();
    final localMap = {for (final s in local) s.id: s};
    for (final remote in remoteList) {
      final existing = localMap[remote.id];
      if (existing != null &&
          existing.statut == SeanceStatus.fermee &&
          remote.statut == SeanceStatus.ouverte) {
        final preserveLocal = await _hasPendingLocalClose(remote.id);
        if (preserveLocal) continue;
      }
      localMap[remote.id] = remote;
    }
    await _datasource.saveAll(localMap.values.toList());
  }

  Future<bool> _hasPendingLocalClose(String seanceId) async {
    final sync = _syncService;
    if (sync == null) return false;

    try {
      final pending = await sync.getPendingOperations();
      for (final op in pending) {
        if (op.entityType != SyncEntityType.seance) continue;
        if (op.entityId != seanceId) continue;
        if (op.operationType != SyncOperationType.update) continue;

        final decoded = json.decode(op.payload);
        if (decoded is Map<String, dynamic>) {
          final statut = decoded['statut']?.toString();
          if (statut == 'fermee') return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Seance?> getSeanceOuverte() async {
    return _datasource.getSeanceOuverte();
  }

  @override
  Future<SeanceWithStats?> getSeanceEncoursWithStats() async {
    final cached = _cache.get('encours');
    if (cached != null) return cached;

    return _cache.getOrFetch('encours', () async {
      final result = await _fetchSeanceEncoursFromApi();
      if (result != null) {
        _cache.set('encours', result, ttl: CacheTtl.seances);
      }
      return result ?? SeanceWithStats(
        seance: _datasource.getSeanceOuverte()!,
        nbPresents: 0,
        nbAteliers: 0,
        nbAnnotations: 0,
        ateliers: [],
      );
    });
  }

  Future<SeanceWithStats?> _fetchSeanceEncoursFromApi() async {
    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return null;
    final client = _dioClient;
    if (client == null) return null;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.seanceEncours);

      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[SeanceRepo] _fetchSeanceEncoursFromApi failed: ${failure.message}');
          return null;
        },
        (data) {
          if (data is! Map<String, dynamic>) return null;

          final seanceMap = data['seance'] as Map<String, dynamic>?;
          final statsMap = data['stats'] as Map<String, dynamic>?;
          if (seanceMap == null || statsMap == null) return null;

          final seance = Seance.fromJson(seanceMap);
          return SeanceWithStats(
            seance: seance,
            nbPresents: statsMap['nb_presents'] as int? ?? 0,
            nbAteliers: statsMap['nb_ateliers'] as int? ?? 0,
            nbAnnotations: statsMap['nb_annotations'] as int? ?? 0,
            ateliers: (statsMap['ateliers'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ?? [],
          );
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[SeanceRepo] _fetchSeanceEncoursFromApi exception: $e');
      return null;
    }
  }

  @override
  Future<Seance> create(Seance seance) async {
    final created = _dioClient != null
        ? await _createOnline(seance)
        : await _createOffline(seance);
    _invalidateCaches();
    _eventBus?.emit(SeanceCreatedEvent(created.id));
    _invalidationRegistry?.markInvalidated<SeanceCreatedEvent>();
    return created;
  }

  /// Creation directe via API — l'UUID est attribue par le serveur.
  /// Sur 409: synchronise les seances depuis le backend, purge les seances locales
  /// stales (ID timestamp), puis propage l'erreur sans basculer en offline.
  /// Sur succes: nettoie les seances stales avant de retourner la nouvelle seance.
  Future<Seance> _createOnline(Seance seance) async {
    try {
      final payload = _buildCreatePayload(seance);
      final result = await _dioClient!.post<dynamic>(
        ApiEndpoints.seances,
        data: payload,
      );

      return await result.fold(
        (failure) async {
          if (failure.statusCode == 409) {
            // Seance deja ouverte sur le backend. Synchroniser pour recuperer
            // la vraie seance et purger les entrees locales obsoletes.
            await syncFromApi();
            await _purgerSeancesStalesLocales();
            throw Exception('SEANCE_CONFLIT');
          }
          // ignore: avoid_print
          print('[SeanceRepo] Creation online echouee (${failure.statusCode}): ${failure.message}. Bascule offline.');
          return _createOffline(seance);
        },
        (data) async {
          final map = data is Map<String, dynamic> ? data : null;
          final seanceMap = (map?['seance'] as Map<String, dynamic>?) ?? map;
          if (seanceMap != null && seanceMap['id'] != null) {
            final seanceAvecIdServeur = _parseSeanceFromMap(seanceMap, seance);
            await _datasource.add(seanceAvecIdServeur);
            await _purgerSeancesStalesLocales(exceptId: seanceAvecIdServeur.id);
            return seanceAvecIdServeur;
          }
          // La seance a ete creee cote serveur (2xx) mais le corps de la
          // reponse est absent ou mal forme. Synchroniser pour recuperer
          // l'UUID reel sans creer de doublon local avec un ID timestamp.
          await syncFromApi();
          final created = _datasource.getSeanceOuverte();
          if (created != null) {
            await _purgerSeancesStalesLocales(exceptId: created.id);
            return created;
          }
          throw Exception(
            'Seance creee sur le serveur mais UUID introuvable apres sync.',
          );
        },
      );
    } catch (e) {
      if (e is Exception && e.toString().contains('SEANCE_CONFLIT')) rethrow;
      // ignore: avoid_print
      print('[SeanceRepo] Exception creation online: $e. Bascule offline.');
      return _createOffline(seance);
    }
  }

  /// Creation offline-first avec ID timestamp + mise en file de sync.
  /// Verifie d'abord qu'aucune seance n'est deja ouverte localement.
  Future<Seance> _createOffline(Seance seance) async {
    final existing = _datasource.getSeanceOuverte();
    if (existing != null) {
      throw Exception('SEANCE_CONFLIT');
    }
    final created = await _datasource.add(seance);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  /// Supprime les seances locales avec un ID numerique (timestamp) en statut
  /// "ouverte". Ces seances n'ont jamais ete synchronisees avec le backend
  /// et ne peuvent plus l'etre une fois que le backend a son propre UUID.
  Future<void> _purgerSeancesStalesLocales({String? exceptId}) async {
    final local = _datasource.getAll();
    final staleIds = local
        .where(
          (s) =>
              s.id != exceptId &&
              s.statut == SeanceStatus.ouverte &&
              RegExp(r'^\d{10,}$').hasMatch(s.id),
        )
        .map((s) => s.id)
        .toList();
    for (final id in staleIds) {
      await _datasource.delete(id);
    }
  }

  Map<String, dynamic> _buildCreatePayload(Seance seance) {
    return {
      'titre': seance.titre,
      'date': seance.date.toIso8601String().split('T').first,
      'heure_debut': seance.heureDebut.toIso8601String(),
      'heure_fin': seance.heureFin.toIso8601String(),
      'encadreur_responsable_id': seance.encadreurResponsableId,
      if (seance.encadreurIds.isNotEmpty) 'encadreur_ids': seance.encadreurIds,
    };
  }

  Seance _parseSeanceFromMap(Map<String, dynamic> map, Seance fallback) {
    return fallback.copyWith(
      id: map['id'] as String? ?? fallback.id,
      statut: _parseStatut(map['statut'] as String?),
    );
  }

  @override
  Future<Seance> update(Seance seance) async {
    final updated = await _datasource.update(seance);
    _cache.invalidateKey('encours');
    _listCache.invalidateByTag('seance_${seance.id}');
    _invalidateCaches();
    _eventBus?.emit(SeanceUpdatedEvent(seance.id));
    _invalidationRegistry?.markInvalidated<SeanceUpdatedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<Seance> ouvrir(String id) async {
    final seance = _datasource.getById(id);
    if (seance == null) {
      throw Exception(
        _l10n?.infraSeanceNotFound(id) ?? 'Seance non trouvee : $id',
      );
    }
    final updated = seance.copyWith(statut: SeanceStatus.ouverte);
    final result = await _datasource.update(updated);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: result.id,
      operationType: SyncOperationType.update,
      data: result.toJson(),
    );
    return result;
  }

  @override
  Future<Seance> fermer(String id) async {
    final seance = _datasource.getById(id);
    if (seance == null) {
      throw Exception(
        _l10n?.infraSeanceNotFound(id) ?? 'Seance non trouvee : $id',
      );
    }
    final updated = seance.copyWith(statut: SeanceStatus.fermee);
    final result = await _datasource.update(updated);
    _cache.invalidateKey('encours');
    _invalidateCaches();
    _eventBus?.emit(SeanceClosedEvent(id));
    _invalidationRegistry?.markInvalidated<SeanceClosedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: result.id,
      operationType: SyncOperationType.update,
      data: result.toJson(),
    );
    return result;
  }

  /// Invalide le cache des stats de seance en cours.
  /// A appeler apres toute mutation (presence, atelier, annotation).
  @override
  void invalidateSeanceEncoursCache() {
    _cache.invalidateKey('encours');
  }

  @override
  Future<void> delete(String id) async {
    invalidateSeanceEncoursCache();
    await _datasource.delete(id);
    _invalidateCaches();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Synchronise les seances depuis le backend.
  /// Fusionne les donnees distantes dans le cache local.
  /// Retourne false si le serveur est inaccessible ou en cas d'erreur.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.seances);

      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[Seance] Sync failed: ${failure.message}');
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
              .map((map) {
                return Seance(
                  id: map['id'] as String,
                  titre: (map['titre'] as String?) ?? '',
                  date: DateTime.parse(
                    (map['date'] as String?) ??
                        (map['date_debut'] as String?) ??
                        DateTime.now().toIso8601String(),
                  ),
                  heureDebut: DateTime.parse(
                    (map['heure_debut'] as String?) ??
                        (map['heureDebut'] as String?) ??
                        '1970-01-01T09:00:00',
                  ),
                  heureFin: DateTime.parse(
                    (map['heure_fin'] as String?) ??
                        (map['heureFin'] as String?) ??
                        '1970-01-01T11:00:00',
                  ),
                  statut: _parseStatut(map['statut'] as String?),
                  encadreurResponsableId:
                      (map['encadreur_responsable_id'] as String?) ??
                      (map['encadreurResponsableId'] as String?) ??
                      '',
                  encadreurIds:
                      (map['encadreur_ids'] as List<dynamic>?)
                          ?.map((e) => e as String)
                          .toList() ??
                      [],
                  academicienIds:
                      (map['academicien_ids'] as List<dynamic>?)
                          ?.map((e) => e as String)
                          .toList() ??
                      [],
                  atelierIds:
                      (map['atelier_ids'] as List<dynamic>?)
                          ?.map((e) => e as String)
                          .toList() ??
                      [],
                );
              })
              .where((s) => s.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          // ignore: avoid_print
          print('[Seance] Synced ${remote.length} items from backend');
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Seance] Sync exception: $e');
      return false;
    }
  }

  /// Parse le statut depuis la reponse API.
  SeanceStatus _parseStatut(String? statut) {
    switch (statut?.toLowerCase()) {
      case 'ouverte':
        return SeanceStatus.ouverte;
      case 'fermee':
        return SeanceStatus.fermee;
      default:
        return SeanceStatus.fermee;
    }
  }
}
