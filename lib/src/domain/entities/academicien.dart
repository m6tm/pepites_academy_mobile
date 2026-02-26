/// Représente un élève inscrit à l'académie (Pépites Academy).
class Academicien {
  final String id;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String photoUrl;
  final String telephoneParent;
  final String posteFootballId; // Référence à l'id du poste
  final String niveauScolaireId; // Référence à l'id du niveau scolaire
  final String codeQrUnique;
  final String? piedFort; // Optionnel (Gaucher, Droitier, Ambidextre)

  Academicien({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.photoUrl,
    required this.telephoneParent,
    required this.posteFootballId,
    required this.niveauScolaireId,
    required this.codeQrUnique,
    this.piedFort,
  });

  /// Serialise l'academicien en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance.toIso8601String(),
      'photoUrl': photoUrl,
      'telephoneParent': telephoneParent,
      'posteFootballId': posteFootballId,
      'niveauScolaireId': niveauScolaireId,
      'codeQrUnique': codeQrUnique,
      'piedFort': piedFort,
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
      photoUrl:
          json['photoUrl'] as String? ?? json['photo_url'] as String? ?? '',
      telephoneParent:
          json['telephoneParent'] as String? ??
          json['telephone_parent'] as String? ??
          '',
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
    );
  }
}
