import 'package:flutter/foundation.dart';
import '../../application/services/sync_service.dart';
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
  DioClient? _dioClient;
  SyncService? _syncService;

  AcademicienRepositoryImpl(this._datasource);

  /// Injecte le client HTTP pour les appels API.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<Academicien?> getById(String id) => _datasource.getById(id);

  @override
  Future<List<Academicien>> getAll() => _datasource.getAll();

  /// Fusionne une liste de donnees distantes dans le cache local
  /// sans declencher d'operation de synchronisation vers le serveur.
  Future<void> upsertAllFromRemote(List<Academicien> remoteList) async {
    final local = await _datasource.getAll();
    final localMap = {for (final a in local) a.id: a};
    for (final remote in remoteList) {
      localMap[remote.id] = remote;
    }
    await _datasource.saveAll(localMap.values.toList());
  }

  @override
  Future<Academicien> create(Academicien academicien) async {
    final created = await _datasource.create(academicien);
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
      classeActuelle:
          (map['classe_actuelle'] as String?) ??
          (map['classeActuelle'] as String?),
      remarquesScolaires:
          (map['remarques_scolaires'] as String?) ??
          (map['remarquesScolaires'] as String?),
      certificatMedicalUrl:
          (map['certificat_medical_url'] as String?) ??
          (map['certificatMedicalUrl'] as String?),
    );
  }
}
