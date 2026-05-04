/// Represente une entree dans l'historique du parcours sportif d'un academicien.
class HistoriqueParcoursSportif {
  final String? id;
  final String? academicienId;
  final String? centre;
  final String? annee;
  final String? categorie;
  final String? autresRemarques;

  HistoriqueParcoursSportif({
    this.id,
    this.academicienId,
    this.centre,
    this.annee,
    this.categorie,
    this.autresRemarques,
  });

  /// Serialise l'historique en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (academicienId != null) 'academicien_id': academicienId,
      'centre': centre,
      'annee': annee,
      'categorie': categorie,
      'autres_remarques': autresRemarques,
    };
  }

  factory HistoriqueParcoursSportif.fromJson(Map<String, dynamic> json) {
    return HistoriqueParcoursSportif(
      id: json['id'] as String?,
      academicienId:
          json['academicienId'] as String? ?? json['academicien_id'] as String?,
      centre: json['centre'] as String?,
      annee: json['annee'] as String?,
      categorie: json['categorie'] as String?,
      autresRemarques:
          json['autresRemarques'] as String? ??
          json['autres_remarques'] as String?,
    );
  }
}
