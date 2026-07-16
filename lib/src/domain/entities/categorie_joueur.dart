/// Represente une categorie de joueurs (U15, U12, Seniors, etc.).
class CategorieJoueur {
  final String id;
  final String nom;
  final String? description;
  final int ordre;
  final DateTime createdAt;

  CategorieJoueur({
    required this.id,
    required this.nom,
    this.description,
    required this.ordre,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Cree une copie de la categorie avec des champs modifies.
  CategorieJoueur copyWith({
    String? id,
    String? nom,
    String? description,
    bool clearDescription = false,
    int? ordre,
    DateTime? createdAt,
  }) {
    return CategorieJoueur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: clearDescription ? null : (description ?? this.description),
      ordre: ordre ?? this.ordre,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'ordre': ordre,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Deserialisation depuis Map.
  factory CategorieJoueur.fromJson(Map<String, dynamic> json) {
    return CategorieJoueur(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      ordre: json['ordre'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
