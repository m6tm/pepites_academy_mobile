/// Represente une entree dans l'historique du parcours sportif d'un academicien.
class HistoriqueParcoursSportif {
  final String? id;
  final String? academicienId;
  final String? centre;
  final String? categorie;
  final String? observation;

  HistoriqueParcoursSportif({
    this.id,
    this.academicienId,
    this.centre,
    this.categorie,
    this.observation,
  });

  /// Serialise l'historique en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (academicienId != null) 'academicienId': academicienId,
      'centre': centre,
      'categorie': categorie,
      'observation': observation,
    };
  }

  factory HistoriqueParcoursSportif.fromJson(Map<String, dynamic> json) {
    return HistoriqueParcoursSportif(
      id: json['id'] as String?,
      academicienId:
          json['academicienId'] as String? ??
          json['academicien_id'] as String?,
      centre: json['centre'] as String?,
      categorie: json['categorie'] as String?,
      observation: json['observation'] as String?,
    );
  }
}
