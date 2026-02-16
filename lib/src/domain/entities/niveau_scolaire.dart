/// Represente un niveau scolaire (CM1, 6eme, etc.).
class NiveauScolaire {
  final String id;
  final String nom;
  final int ordre;
  final DateTime createdAt;
  final DateTime updatedAt;

  NiveauScolaire({
    required this.id,
    required this.nom,
    required this.ordre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Cree une copie du niveau avec des champs modifies.
  NiveauScolaire copyWith({
    String? id,
    String? nom,
    int? ordre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NiveauScolaire(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      ordre: ordre ?? this.ordre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Serialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'ordre': ordre,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Deserialisation depuis Map.
  factory NiveauScolaire.fromJson(Map<String, dynamic> json) {
    return NiveauScolaire(
      id: json['id'] as String,
      nom: json['nom'] as String,
      ordre: json['ordre'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
