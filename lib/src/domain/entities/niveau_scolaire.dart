/// Represente un niveau scolaire (CM1, 6eme, etc.).
class NiveauScolaire {
  final String id;
  final String nom;
  final int ordre;

  NiveauScolaire({required this.id, required this.nom, required this.ordre});

  /// Cree une copie du niveau avec des champs modifies.
  NiveauScolaire copyWith({String? id, String? nom, int? ordre}) {
    return NiveauScolaire(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      ordre: ordre ?? this.ordre,
    );
  }

  /// Serialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'ordre': ordre};
  }

  /// Deserialisation depuis Map.
  factory NiveauScolaire.fromJson(Map<String, dynamic> json) {
    return NiveauScolaire(
      id: json['id'] as String,
      nom: json['nom'] as String,
      ordre: json['ordre'] as int,
    );
  }
}
