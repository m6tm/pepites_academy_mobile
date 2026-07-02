import 'package:flutter/foundation.dart';
import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/academicien_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/academicien.dart';
import '../../domain/entities/historique_parcours_sportif.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/academicien_repository.dart';
import '../datasources/academicien_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation locale du repository academicien.
/// Delegue les operations au datasource local.
class AcademicienRepositoryImpl implements AcademicienRepository {
  final AcademicienLocalDatasource _datasource;
  final RepositoryCache<Academicien?> _cache = RepositoryCache<Academicien?>();
  final RepositoryCache<List<Academicien>> _listCache = RepositoryCache<List<Academicien>>();
  DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  AcademicienRepositoryImpl(this._datasource);

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

  /// Injecte le garde de connectivite.
  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  void _invalidateCaches() {
    _cache.invalidateByTag('academiciens');
    _listCache.invalidateByTag('academiciens');
  }

  /// Migre un academicien cree offline (ID timestamp) vers l'UUID assigne par le serveur.
  /// Si l'UUID serveur existe deja (suite a un upsertAllFromRemote par exemple),
  /// on supprime simplement l'entree locale obsolete pour eviter tout doublon.
  Future<void> migrateLocalId(String localId, String serverId) async {
    final local = await _datasource.getById(localId);
    if (local == null) return;

    final existingServer = await _datasource.getById(serverId);
    if (existingServer == null) {
      final json = local.toJson()..['id'] = serverId;
      final migrated = Academicien.fromJson(json);
      await _datasource.create(migrated);
    }

    await _datasource.delete(localId);
    _cache.invalidateKey(localId);
    _cache.invalidateByTag('academiciens');
    _listCache.invalidateByTag('academiciens');
    _eventBus?.emit(AcademicienUpdatedEvent(serverId));
  }

  @override
  Future<Academicien?> getById(String id) async {
    final fresh = _cache.get(id);
    if (fresh != null) return fresh;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      return _cache.getStale(id) ?? await _datasource.getById(id);
    }

    return _cache.getOrFetch(id, () async {
      final academicien = await _datasource.getById(id);
      if (academicien != null) {
        _cache.set(
          id,
          academicien,
          ttl: CacheTtl.academiciens,
          tags: {'academiciens', 'academicien_$id'},
        );
      }
      return academicien;
    });
  }

  /// Variante SWR : emet d'abord la donnee stale puis la fraiche.
  Stream<Academicien> getAcademicienSwr(String id) async* {
    final stale = _cache.getStale(id) ?? await _datasource.getById(id);
    if (stale != null) yield stale;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return;

    final fresh = await _cache.getOrFetch(id, () async {
      final a = await _datasource.getById(id);
      if (a == null) throw Exception('Academicien $id introuvable');
      return a;
    });
    if (fresh != null) {
      _cache.set(id, fresh, ttl: CacheTtl.academiciens, tags: {'academiciens', 'academicien_$id'});
      yield fresh;
    }
  }

  @override
  Future<List<Academicien>> getAll() async {
    const key = 'all';
    final cached = _listCache.get(key);
    if (cached != null) return cached;

    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      final stale = _listCache.getStale(key);
      if (stale != null) return stale;
    }

    return _listCache.getOrFetch(key, () async {
      final list = await _datasource.getAll();
      _listCache.set(key, list, ttl: CacheTtl.academiciens, tags: {'academiciens'});
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
  ///
  /// Garantit l'absence de doublon lors de la migration d'un ID local
  /// (timestamp genere offline) vers l'UUID assigne par le serveur :
  /// si un academicien distant a la meme cle naturelle (nom + prenom +
  /// date de naissance) qu'un academicien local mais un ID different,
  /// l'ancien ID local est supprime.
  Future<void> upsertAllFromRemote(List<Academicien> remoteList) async {
    final local = await _datasource.getAll();
    final localMap = {for (final a in local) a.id: a};

    String naturalKey(Academicien a) {
      return '${a.nom.trim().toLowerCase()}|'
          '${a.prenom.trim().toLowerCase()}|'
          '${a.dateNaissance.toIso8601String()}';
    }

    final localByNaturalKey = <String, String>{};
    for (final a in local) {
      localByNaturalKey[naturalKey(a)] = a.id;
    }

    for (final remote in remoteList) {
      final existingLocalId = localByNaturalKey[naturalKey(remote)];
      if (existingLocalId != null && existingLocalId != remote.id) {
        localMap.remove(existingLocalId);
      }
      localMap[remote.id] = remote;
    }

    await _datasource.saveAll(localMap.values.toList());
    _cache.invalidateByTag('academiciens');
    _listCache.invalidateByTag('academiciens');
  }

  @override
  Future<Academicien> create(Academicien academicien) async {
    final created = await _datasource.create(academicien);
    _invalidateCaches();
    _eventBus?.emit(AcademicienCreatedEvent(created.id));
    _invalidationRegistry?.markInvalidated<AcademicienCreatedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Academicien> update(Academicien academicien) async {
    final updated = await _datasource.update(academicien);
    _cache.invalidateByTag('academicien_${academicien.id}');
    _invalidateCaches();
    _eventBus?.emit(AcademicienUpdatedEvent(academicien.id));
    _invalidationRegistry?.markInvalidated<AcademicienUpdatedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<Academicien?> getByQrCode(String qrCode) =>
      _datasource.getByQrCode(qrCode);

  @override
  Future<List<Academicien>> search(String query) => _datasource.search(query);

  Future<void> delete(String id) async {
    await _datasource.delete(id);
    _cache.invalidateKey(id);
    _invalidateCaches();
    _eventBus?.emit(AcademicienDeletedEvent(id));
    _invalidationRegistry?.markInvalidated<AcademicienDeletedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Synchronise les academiciens depuis le backend vers le cache local.
  /// Retourne true si la synchronisation a reussi.
  Future<bool> syncFromApi() async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.academiciens);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[AcademicienRepo] Erreur sync: ${failure.message}');
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

          final academiciens = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) {
                // Log pour voir les donnees brutes recues
                debugPrint('[AcademicienRepo] RAW DATA for ${map['id']}: $map');
                return _parseAcademicien(map);
              })
              .where((a) => a.id.isNotEmpty)
              .toList();

          await upsertAllFromRemote(academiciens);
          debugPrint(
            '[AcademicienRepo] Synced ${academiciens.length} academiciens from backend',
          );
          return true;
        },
      );
    } catch (e) {
      debugPrint('[AcademicienRepo] Exception sync: $e');
      return false;
    }
  }

  /// Parse un academicien depuis les donnees du backend.
  Academicien _parseAcademicien(Map<String, dynamic> map) {
    // Parse l'historique du parcours sportif
    final historiqueRaw =
        map['historique_parcours'] as List<dynamic>? ??
        map['historiqueParcours'] as List<dynamic>? ??
        [];
    final historiqueParcours = historiqueRaw
        .whereType<Map<String, dynamic>>()
        .map((h) => HistoriqueParcoursSportif.fromJson(h))
        .toList();

    return Academicien(
      id: (map['id']?.toString() ?? ''),
      nom: (map['nom'] as String?) ?? '',
      prenom: (map['prenom'] as String?) ?? '',
      dateNaissance:
          DateTime.tryParse(
            (map['date_naissance'] as String?) ??
                (map['dateNaissance'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      lieuNaissance:
          (map['lieu_naissance'] as String?) ??
          (map['lieuNaissance'] as String?) ??
          '',
      nationalite: map['nationalite'] as String? ?? '',
      sexe: map['sexe'] as String? ?? '',
      photoUrl:
          (map['photo_url'] as String?) ?? (map['photoUrl'] as String?) ?? '',
      telephoneEleve:
          (map['telephone_eleve'] as String?) ??
          (map['telephoneEleve'] as String?) ??
          '',
      taille: map['taille'] as int? ?? 0,
      email: map['email'] as String? ?? '',
      whatsapp: map['whatsapp'] as String? ?? '',
      twitter: map['twitter'] as String?,
      facebook: map['facebook'] as String?,
      posteFootballId:
          (map['poste_football_id'] as String?) ??
          (map['posteFootballId'] as String?) ??
          '',
      niveauScolaireId:
          (map['niveau_scolaire_id'] as String?) ??
          (map['niveauScolaireId'] as String?) ??
          '',
      codeQrUnique:
          (map['code_qr_unique'] as String?) ??
          (map['codeQrUnique'] as String?) ??
          '',
      piedFort: (map['pied_fort'] as String?) ?? (map['piedFort'] as String?),
      nomParent:
          (map['nom_parent'] as String?) ?? (map['nomParent'] as String?) ?? '',
      prenomParent:
          (map['prenom_parent'] as String?) ??
          (map['prenomParent'] as String?) ??
          '',
      fonctionParent:
          (map['fonction_parent'] as String?) ??
          (map['fonctionParent'] as String?) ??
          '',
      telephoneParent:
          (map['telephone_parent'] as String?) ??
          (map['telephoneParent'] as String?) ??
          '',
      nomTuteur:
          (map['nom_tuteur'] as String?) ?? (map['nomTuteur'] as String?) ?? '',
      prenomTuteur:
          (map['prenom_tuteur'] as String?) ??
          (map['prenomTuteur'] as String?) ??
          '',
      fonctionTuteur:
          (map['fonction_tuteur'] as String?) ??
          (map['fonctionTuteur'] as String?) ??
          '',
      telephoneTuteur:
          (map['telephone_tuteur'] as String?) ??
          (map['telephoneTuteur'] as String?) ??
          '',
      photoTuteurUrl:
          (map['photo_tuteur_url'] as String?) ??
          (map['photoTuteurUrl'] as String?),
      garantType:
          (map['garant_type'] as String?) ?? (map['garantType'] as String?),
      emailGarant:
          (map['email_garant'] as String?) ??
          (map['emailGarant'] as String?) ??
          '',
      adresseGarant:
          (map['adresse_garant'] as String?) ??
          (map['adresseGarant'] as String?) ??
          '',
      atouts: map['atouts'] as String?,
      faiblesses: map['faiblesses'] as String?,
      descriptionPerformances:
          (map['description_performances'] as String?) ??
          (map['descriptionPerformances'] as String?),
      aProblemesPeau:
          (map['a_problemes_peau'] as bool?) ??
          (map['aProblemesPeau'] as bool?),
      aAllergie: (map['a_allergie'] as bool?) ?? (map['aAllergie'] as bool?),
      allergieDetails:
          (map['allergie_details'] as String?) ??
          (map['allergieDetails'] as String?),
      aimeTravailGroupe:
          (map['aime_travail_groupe'] as bool?) ??
          (map['aimeTravailGroupe'] as bool?),
      historiqueParcours: historiqueParcours,
      signatureAcademicienUrl:
          (map['signature_academicien_url'] as String?) ??
          (map['signatureAcademicienUrl'] as String?),
      signatureParentUrl:
          (map['signature_parent_url'] as String?) ??
          (map['signatureParentUrl'] as String?),
      photoParentUrl:
          (map['photo_parent_url'] as String?) ??
          (map['photoParentUrl'] as String?),
      etablissementScolaire:
          (map['etablissement_scolaire'] as String?) ??
          (map['etablissementScolaire'] as String?),
      anneeScolaireActuelle:
          (map['annee_scolaire_actuelle'] as String?) ??
          (map['anneeScolaireActuelle'] as String?),
      remarquesScolaires:
          (map['remarques_scolaires'] as String?) ??
          (map['remarquesScolaires'] as String?),
      certificatMedicalUrl:
          (map['certificat_medical_url'] as String?) ??
          (map['certificatMedicalUrl'] as String?),
    );
  }
}
