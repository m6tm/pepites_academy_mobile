import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/academicien.dart';
import '../../domain/entities/historique_parcours_sportif.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Source de donnees locale pour les academiciens.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class AcademicienLocalDatasource {
  static const String _key = 'academiciens_data';
  final SharedPreferences _prefs;

  AcademicienLocalDatasource(this._prefs);

  Future<List<Academicien>> getAll() async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Academicien?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Academicien> create(Academicien academicien) async {
    final all = await getAll();
    all.add(academicien);
    await saveAll(all);
    return academicien;
  }

  Future<Academicien> update(Academicien academicien) async {
    final all = await getAll();
    final index = all.indexWhere((e) => e.id == academicien.id);
    if (index != -1) {
      all[index] = academicien;
      await saveAll(all);
    }
    return academicien;
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }

  Future<Academicien?> getByQrCode(String qrCode) async {
    final all = await getAll();
    try {
      return all.firstWhere((e) => e.codeQrUnique == qrCode);
    } catch (_) {
      return null;
    }
  }

  Future<List<Academicien>> search(String query) async {
    final all = await getAll();
    final searchQuery = query.toLowerCase();
    return all.where((encadreur) {
      return encadreur.nom.toLowerCase().contains(searchQuery) ||
          encadreur.prenom.toLowerCase().contains(searchQuery) ||
          encadreur.telephoneParent.contains(searchQuery);
    }).toList();
  }

  /// Vide le cache local.
  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  Future<void> saveAll(List<Academicien> list) async {
    final jsonList = list.map((e) => _toJson(e)).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }

  Map<String, dynamic> _toJson(Academicien a) {
    return {
      'id': a.id,
      'nom': a.nom,
      'prenom': a.prenom,
      'dateNaissance': a.dateNaissance.toIso8601String(),
      'lieuNaissance': a.lieuNaissance,
      'nationalite': a.nationalite,
      'sexe': a.sexe,
      'photoUrl': a.photoUrl,
      'telephoneEleve': a.telephoneEleve,
      'telephoneParent': a.telephoneParent,
      'taille': a.taille,
      'email': a.email,
      'whatsapp': a.whatsapp,
      'twitter': a.twitter,
      'facebook': a.facebook,
      'posteFootballId': a.posteFootballId,
      'niveauScolaireId': a.niveauScolaireId,
      'codeQrUnique': a.codeQrUnique,
      'piedFort': a.piedFort,
      'nomParent': a.nomParent,
      'prenomParent': a.prenomParent,
      'fonctionParent': a.fonctionParent,
      'nomTuteur': a.nomTuteur,
      'prenomTuteur': a.prenomTuteur,
      'fonctionTuteur': a.fonctionTuteur,
      'telephoneTuteur': a.telephoneTuteur,
      'photoTuteurUrl': a.photoTuteurUrl,
      'garantType': a.garantType,
      'emailGarant': a.emailGarant,
      'adresseGarant': a.adresseGarant,
      'atouts': a.atouts,
      'faiblesses': a.faiblesses,
      'descriptionPerformances': a.descriptionPerformances,
      'aProblemesPeau': a.aProblemesPeau,
      'aAllergie': a.aAllergie,
      'allergieDetails': a.allergieDetails,
      'aimeTravailGroupe': a.aimeTravailGroupe,
      'historiqueParcours': a.historiqueParcours
          .map((h) => h.toJson())
          .toList(),
      'signatureAcademicienUrl': a.signatureAcademicienUrl,
      'signatureParentUrl': a.signatureParentUrl,
      'photoParentUrl': a.photoParentUrl,
    };
  }

  Academicien _fromJson(Map<String, dynamic> json) {
    return Academicien(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: DateTime.parse(json['dateNaissance'] as String),
      lieuNaissance: json['lieuNaissance'] as String? ?? '',
      nationalite: json['nationalite'] as String? ?? '',
      sexe: json['sexe'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      telephoneEleve: json['telephoneEleve'] as String? ?? '',
      telephoneParent: json['telephoneParent'] as String? ?? '',
      taille: json['taille'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      twitter: json['twitter'] as String?,
      facebook: json['facebook'] as String?,
      posteFootballId: json['posteFootballId'] as String? ?? '',
      niveauScolaireId: json['niveauScolaireId'] as String? ?? '',
      codeQrUnique: json['codeQrUnique'] as String? ?? '',
      piedFort: json['piedFort'] as String?,
      nomParent: json['nomParent'] as String? ?? '',
      prenomParent: json['prenomParent'] as String? ?? '',
      fonctionParent: json['fonctionParent'] as String? ?? '',
      nomTuteur: json['nomTuteur'] as String? ?? '',
      prenomTuteur: json['prenomTuteur'] as String? ?? '',
      fonctionTuteur: json['fonctionTuteur'] as String? ?? '',
      telephoneTuteur: json['telephoneTuteur'] as String? ?? '',
      photoTuteurUrl: json['photoTuteurUrl'] as String?,
      garantType: json['garantType'] as String?,
      emailGarant: json['emailGarant'] as String? ?? '',
      adresseGarant: json['adresseGarant'] as String? ?? '',
      atouts: json['atouts'] as String?,
      faiblesses: json['faiblesses'] as String?,
      descriptionPerformances: json['descriptionPerformances'] as String?,
      aProblemesPeau: json['aProblemesPeau'] as bool?,
      aAllergie: json['aAllergie'] as bool?,
      allergieDetails: json['allergieDetails'] as String?,
      aimeTravailGroupe: json['aimeTravailGroupe'] as bool?,
      historiqueParcours:
          (json['historiqueParcours'] as List<dynamic>?)
              ?.map(
                (h) => HistoriqueParcoursSportif.fromJson(
                  h as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      signatureAcademicienUrl: json['signatureAcademicienUrl'] as String?,
      signatureParentUrl: json['signatureParentUrl'] as String?,
      photoParentUrl: json['photoParentUrl'] as String?,
    );
  }

  /// Synchronise les academiciens depuis le backend.
  /// Remplace les donnees locales par celles du serveur.
  Future<bool> syncFromApi(DioClient dioClient) async {
    try {
      final result = await dioClient.get<List<dynamic>>(
        ApiEndpoints.academiciens,
      );
      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[Academicien] Sync failed: ${failure.message}');
          return false;
        },
        (data) async {
          final academiciens = data.map((json) {
            final map = json as Map<String, dynamic>;
            return Academicien(
              id: map['id'] as String,
              nom: map['nom'] as String,
              prenom: map['prenom'] as String,
              dateNaissance: DateTime.parse(
                map['date_naissance'] as String? ??
                    map['dateNaissance'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
              lieuNaissance:
                  map['lieu_naissance'] as String? ??
                  map['lieuNaissance'] as String? ??
                  '',
              nationalite: map['nationalite'] as String? ?? '',
              sexe: map['sexe'] as String? ?? '',
              photoUrl:
                  (map['photo_url'] as String?) ??
                  (map['photoUrl'] as String?) ??
                  '',
              telephoneEleve:
                  map['telephone_eleve'] as String? ??
                  map['telephoneEleve'] as String? ??
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
              piedFort:
                  map['pied_fort'] as String? ?? map['piedFort'] as String?,
              nomParent:
                  map['nom_parent'] as String? ??
                  map['nomParent'] as String? ??
                  '',
              prenomParent:
                  map['prenom_parent'] as String? ??
                  map['prenomParent'] as String? ??
                  '',
              fonctionParent:
                  map['fonction_parent'] as String? ??
                  map['fonctionParent'] as String? ??
                  '',
              telephoneParent:
                  map['telephone_parent'] as String? ??
                  map['telephoneParent'] as String? ??
                  '',
              nomTuteur:
                  map['nom_tuteur'] as String? ??
                  map['nomTuteur'] as String? ??
                  '',
              prenomTuteur:
                  map['prenom_tuteur'] as String? ??
                  map['prenomTuteur'] as String? ??
                  '',
              fonctionTuteur:
                  map['fonction_tuteur'] as String? ??
                  map['fonctionTuteur'] as String? ??
                  '',
              telephoneTuteur:
                  map['telephone_tuteur'] as String? ??
                  map['telephoneTuteur'] as String? ??
                  '',
              photoTuteurUrl:
                  map['photo_tuteur_url'] as String? ??
                  map['photoTuteurUrl'] as String?,
              garantType:
                  map['garant_type'] as String? ??
                  map['garantType'] as String?,
              emailGarant:
                  map['email_garant'] as String? ??
                  map['emailGarant'] as String? ??
                  '',
              adresseGarant:
                  map['adresse_garant'] as String? ??
                  map['adresseGarant'] as String? ??
                  '',
              atouts: map['atouts'] as String?,
              faiblesses: map['faiblesses'] as String?,
              descriptionPerformances:
                  map['description_performances'] as String? ??
                  map['descriptionPerformances'] as String?,
              aProblemesPeau:
                  map['a_problemes_peau'] as bool? ??
                  map['aProblemesPeau'] as bool?,
              aAllergie:
                  map['a_allergie'] as bool? ?? map['aAllergie'] as bool?,
              allergieDetails:
                  map['allergie_details'] as String? ??
                  map['allergieDetails'] as String?,
              aimeTravailGroupe:
                  map['aime_travail_groupe'] as bool? ??
                  map['aimeTravailGroupe'] as bool?,
              historiqueParcours:
                  (map['historique_parcours'] as List<dynamic>? ??
                          map['historiqueParcours'] as List<dynamic>? ??
                          [])
                      .map(
                        (h) => HistoriqueParcoursSportif.fromJson(
                          h as Map<String, dynamic>,
                        ),
                      )
                      .toList(),
              signatureAcademicienUrl:
                  (map['signature_academicien_url'] as String?) ??
                  (map['signatureAcademicienUrl'] as String?),
              signatureParentUrl:
                  (map['signature_parent_url'] as String?) ??
                  (map['signatureParentUrl'] as String?),
              photoParentUrl:
                  (map['photo_parent_url'] as String?) ??
                  (map['photoParentUrl'] as String?),
            );
          }).toList();
          await saveAll(academiciens);
          // ignore: avoid_print
          print(
            '[Academicien] Synced ${academiciens.length} items from backend',
          );
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Academicien] Sync exception: $e');
      return false;
    }
  }
}
