/// Represente une entree dans l'historique du parcours sportif d'un academicien.
class HistoriqueParcoursSportif {
  final String? id;
  final String? academicienId;
  final String? centre;
  final String? categorie;
  final String? etablissement;
  final String? anneeScolaire;
  final String? classe;

  HistoriqueParcoursSportif({
    this.id,
    this.academicienId,
    this.centre,
    this.categorie,
    this.etablissement,
    this.anneeScolaire,
    this.classe,
  });

  /// Serialise l'historique en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (academicienId != null) 'academicien_id': academicienId,
      'centre': centre,
      'categorie': categorie,
      'etablissement': etablissement,
      'annee_scolaire': anneeScolaire,
      'classe': classe,
    };
  }

  factory HistoriqueParcoursSportif.fromJson(Map<String, dynamic> json) {
    return HistoriqueParcoursSportif(
      id: json['id'] as String?,
      academicienId:
          json['academicienId'] as String? ?? json['academicien_id'] as String?,
      centre: json['centre'] as String?,
      categorie: json['categorie'] as String?,
      etablissement: json['etablissement'] as String?,
      anneeScolaire:
          json['anneeScolaire'] as String? ?? json['annee_scolaire'] as String?,
      classe: json['classe'] as String?,
    );
  }
}
