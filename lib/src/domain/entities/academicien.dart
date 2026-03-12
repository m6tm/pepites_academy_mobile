import 'historique_parcours_sportif.dart';

/// Represente un eleve inscrit a l'academie (Pepites Academy).
class Academicien {
  final String id;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String lieuNaissance;
  final String nationalite;
  final String sexe;
  final String photoUrl;
  final String telephoneEleve;
  final String telephoneParent;
  final int taille;
  final String email;
  final String whatsapp;
  final String? twitter;
  final String? facebook;
  final String posteFootballId;
  final String niveauScolaireId;
  final String codeQrUnique;
  final String? piedFort;
  // Informations du parent/tuteur
  final String nomParent;
  final String fonctionParent;
  final String emailParent;
  final String adresseParent;
  final String? photoParentUrl;
  // Autres informations football
  final String? atouts;
  final String? faiblesses;
  final String? descriptionPerformances;
  final bool? aProblemesPeau;
  final bool? aAllergie;
  final String? allergieDetails;
  final bool? aimeTravailGroupe;
  // Historique du parcours sportif
  final List<HistoriqueParcoursSportif> historiqueParcours;

  Academicien({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.lieuNaissance,
    required this.nationalite,
    required this.sexe,
    required this.photoUrl,
    required this.telephoneEleve,
    required this.telephoneParent,
    required this.taille,
    required this.email,
    required this.whatsapp,
    this.twitter,
    this.facebook,
    required this.posteFootballId,
    required this.niveauScolaireId,
    required this.codeQrUnique,
    this.piedFort,
    required this.nomParent,
    required this.fonctionParent,
    required this.emailParent,
    required this.adresseParent,
    this.photoParentUrl,
    this.atouts,
    this.faiblesses,
    this.descriptionPerformances,
    this.aProblemesPeau,
    this.aAllergie,
    this.allergieDetails,
    this.aimeTravailGroupe,
    this.historiqueParcours = const [],
  });

  /// Serialise l'academicien en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance.toIso8601String(),
      'lieuNaissance': lieuNaissance,
      'nationalite': nationalite,
      'sexe': sexe,
      'photoUrl': photoUrl,
      'telephoneEleve': telephoneEleve,
      'telephoneParent': telephoneParent,
      'taille': taille,
      'email': email,
      'whatsapp': whatsapp,
      'twitter': twitter,
      'facebook': facebook,
      'posteFootballId': posteFootballId,
      'niveauScolaireId': niveauScolaireId,
      'codeQrUnique': codeQrUnique,
      'piedFort': piedFort,
      'nomParent': nomParent,
      'fonctionParent': fonctionParent,
      'emailParent': emailParent,
      'adresseParent': adresseParent,
      'photoParentUrl': photoParentUrl ?? '',
      'atouts': atouts,
      'faiblesses': faiblesses,
      'descriptionPerformances': descriptionPerformances,
      'aProblemesPeau': aProblemesPeau,
      'aAllergie': aAllergie,
      'allergieDetails': allergieDetails,
      'aimeTravailGroupe': aimeTravailGroupe,
      'historiqueParcours': historiqueParcours.map((h) => h.toJson()).toList(),
    };
  }

  factory Academicien.fromJson(Map<String, dynamic> json) {
    return Academicien(
      id: json['id'] as String,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      dateNaissance: DateTime.parse(
        json['dateNaissance'] as String? ??
            json['date_naissance'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      lieuNaissance:
          json['lieuNaissance'] as String? ??
          json['lieu_naissance'] as String? ??
          '',
      nationalite: json['nationalite'] as String? ?? '',
      sexe: json['sexe'] as String? ?? '',
      photoUrl:
          json['photoUrl'] as String? ?? json['photo_url'] as String? ?? '',
      telephoneEleve:
          json['telephoneEleve'] as String? ??
          json['telephone_eleve'] as String? ??
          '',
      telephoneParent:
          json['telephoneParent'] as String? ??
          json['telephone_parent'] as String? ??
          '',
      taille: json['taille'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      twitter: json['twitter'] as String?,
      facebook: json['facebook'] as String?,
      posteFootballId:
          json['posteFootballId'] as String? ??
          json['poste_football_id'] as String? ??
          '',
      niveauScolaireId:
          json['niveauScolaireId'] as String? ??
          json['niveau_scolaire_id'] as String? ??
          '',
      codeQrUnique:
          json['codeQrUnique'] as String? ??
          json['code_qr_unique'] as String? ??
          '',
      piedFort: json['piedFort'] as String? ?? json['pied_fort'] as String?,
      nomParent:
          json['nomParent'] as String? ?? json['nom_parent'] as String? ?? '',
      fonctionParent:
          json['fonctionParent'] as String? ??
          json['fonction_parent'] as String? ??
          '',
      emailParent:
          json['emailParent'] as String? ??
          json['email_parent'] as String? ??
          '',
      adresseParent:
          json['adresseParent'] as String? ??
          json['adresse_parent'] as String? ??
          '',
      photoParentUrl:
          json['photoParentUrl'] as String? ??
          json['photo_parent_url'] as String?,
      atouts: json['atouts'] as String?,
      faiblesses: json['faiblesses'] as String?,
      descriptionPerformances:
          json['descriptionPerformances'] as String? ??
          json['description_performances'] as String?,
      aProblemesPeau:
          json['aProblemesPeau'] as bool? ?? json['a_problemes_peau'] as bool?,
      aAllergie: json['aAllergie'] as bool? ?? json['a_allergie'] as bool?,
      allergieDetails:
          json['allergieDetails'] as String? ??
          json['allergie_details'] as String?,
      aimeTravailGroupe:
          json['aimeTravailGroupe'] as bool? ??
          json['aime_travail_groupe'] as bool?,
      historiqueParcours:
          (json['historiqueParcours'] as List<dynamic>? ??
                  json['historique_parcours'] as List<dynamic>? ??
                  [])
              .map(
                (h) => HistoriqueParcoursSportif.fromJson(
                  h as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}
