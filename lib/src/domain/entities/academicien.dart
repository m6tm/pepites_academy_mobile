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
  final int taille;
  final String email;
  final String whatsapp;
  final String? twitter;
  final String? facebook;
  final String posteFootballId;
  final String niveauScolaireId;
  final String codeQrUnique;
  final String? piedFort;
  // Informations du parent
  final String nomParent;
  final String prenomParent;
  final String fonctionParent;
  final String telephoneParent;
  final String? photoParentUrl;
  // Informations du tuteur (optionnel)
  final String nomTuteur;
  final String prenomTuteur;
  final String fonctionTuteur;
  final String telephoneTuteur;
  final String? photoTuteurUrl;
  // Garant designe (parent | tuteur) + coordonnees
  final String? garantType;
  final String emailGarant;
  final String adresseGarant;
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
  // Scolarité actuelle
  final String? etablissementScolaire;
  final String? anneeScolaireActuelle;
  final String? remarquesScolaires;
  final String? certificatMedicalUrl;
  // Signatures
  final String? signatureAcademicienUrl;
  final String? signatureParentUrl;

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
    this.prenomParent = '',
    required this.fonctionParent,
    required this.telephoneParent,
    this.photoParentUrl,
    this.nomTuteur = '',
    this.prenomTuteur = '',
    this.fonctionTuteur = '',
    this.telephoneTuteur = '',
    this.photoTuteurUrl,
    this.garantType,
    this.emailGarant = '',
    this.adresseGarant = '',
    this.atouts,
    this.faiblesses,
    this.descriptionPerformances,
    this.aProblemesPeau,
    this.aAllergie,
    this.allergieDetails,
    this.aimeTravailGroupe,
    this.historiqueParcours = const [],
    this.etablissementScolaire,
    this.anneeScolaireActuelle,
    this.remarquesScolaires,
    this.certificatMedicalUrl,
    this.signatureAcademicienUrl,
    this.signatureParentUrl,
  });

  /// Nom complet du garant designe (parent ou tuteur).
  String get nomCompletGarant {
    if (garantType == 'tuteur') {
      return '${prenomTuteur.trim()} ${nomTuteur.trim()}'.trim();
    }
    return '${prenomParent.trim()} ${nomParent.trim()}'.trim();
  }

  /// Telephone du garant designe.
  String get telephoneGarant {
    if (garantType == 'tuteur') return telephoneTuteur;
    return telephoneParent;
  }

  /// Fonction du garant designe.
  String get fonctionGarant {
    if (garantType == 'tuteur') return fonctionTuteur;
    return fonctionParent;
  }

  /// Photo du garant designe.
  String? get photoGarantUrl {
    if (garantType == 'tuteur') return photoTuteurUrl;
    return photoParentUrl;
  }

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
      'prenomParent': prenomParent,
      'fonctionParent': fonctionParent,
      'telephoneParent': telephoneParent,
      'photoParentUrl': photoParentUrl ?? '',
      'nomTuteur': nomTuteur,
      'prenomTuteur': prenomTuteur,
      'fonctionTuteur': fonctionTuteur,
      'telephoneTuteur': telephoneTuteur,
      'photoTuteurUrl': photoTuteurUrl ?? '',
      'garantType': garantType,
      'emailGarant': emailGarant,
      'adresseGarant': adresseGarant,
      'atouts': atouts,
      'faiblesses': faiblesses,
      'descriptionPerformances': descriptionPerformances,
      'aProblemesPeau': aProblemesPeau,
      'aAllergie': aAllergie,
      'allergieDetails': allergieDetails,
      'aimeTravailGroupe': aimeTravailGroupe,
      'historiqueParcours': historiqueParcours.map((h) => h.toJson()).toList(),
      'etablissementScolaire': etablissementScolaire,
      'anneeScolaireActuelle': anneeScolaireActuelle,
      'remarquesScolaires': remarquesScolaires,
      'certificatMedicalUrl': certificatMedicalUrl,
      'signatureAcademicienUrl': signatureAcademicienUrl,
      'signatureParentUrl': signatureParentUrl,
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
      prenomParent:
          json['prenomParent'] as String? ??
          json['prenom_parent'] as String? ??
          '',
      fonctionParent:
          json['fonctionParent'] as String? ??
          json['fonction_parent'] as String? ??
          '',
      telephoneParent:
          json['telephoneParent'] as String? ??
          json['telephone_parent'] as String? ??
          '',
      photoParentUrl:
          json['photoParentUrl'] as String? ??
          json['photo_parent_url'] as String?,
      nomTuteur:
          json['nomTuteur'] as String? ?? json['nom_tuteur'] as String? ?? '',
      prenomTuteur:
          json['prenomTuteur'] as String? ??
          json['prenom_tuteur'] as String? ??
          '',
      fonctionTuteur:
          json['fonctionTuteur'] as String? ??
          json['fonction_tuteur'] as String? ??
          '',
      telephoneTuteur:
          json['telephoneTuteur'] as String? ??
          json['telephone_tuteur'] as String? ??
          '',
      photoTuteurUrl:
          json['photoTuteurUrl'] as String? ??
          json['photo_tuteur_url'] as String?,
      garantType:
          json['garantType'] as String? ?? json['garant_type'] as String?,
      emailGarant:
          json['emailGarant'] as String? ??
          json['email_garant'] as String? ??
          '',
      adresseGarant:
          json['adresseGarant'] as String? ??
          json['adresse_garant'] as String? ??
          '',
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
      signatureAcademicienUrl:
          json['signatureAcademicienUrl'] as String? ??
          json['signature_academicien_url'] as String?,
      signatureParentUrl:
          json['signatureParentUrl'] as String? ??
          json['signature_parent_url'] as String?,
      etablissementScolaire:
          json['etablissementScolaire'] as String? ??
          json['etablissement_scolaire'] as String?,
      anneeScolaireActuelle:
          json['anneeScolaireActuelle'] as String? ??
          json['annee_scolaire_actuelle'] as String?,
      remarquesScolaires:
          json['remarquesScolaires'] as String? ??
          json['remarques_scolaires'] as String?,
      certificatMedicalUrl:
          json['certificatMedicalUrl'] as String? ??
          json['certificat_medical_url'] as String?,
    );
  }
}
