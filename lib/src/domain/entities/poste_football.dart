/// Represente un poste de jeu au football (Gardien, Defenseur, etc.).
class PosteFootball {
  final String id;
  final String nom;
  final String? description;
  final String? iconeCodePoint;
  final DateTime createdAt;
  final DateTime updatedAt;

  PosteFootball({
    required this.id,
    required this.nom,
    this.description,
    this.iconeCodePoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Cree une copie du poste avec des champs modifies.
  PosteFootball copyWith({
    String? id,
    String? nom,
    String? description,
    String? iconeCodePoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PosteFootball(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      iconeCodePoint: iconeCodePoint ?? this.iconeCodePoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Serialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'iconeCodePoint': iconeCodePoint,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Deserialisation depuis Map.
  factory PosteFootball.fromJson(Map<String, dynamic> json) {
    return PosteFootball(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      iconeCodePoint: json['iconeCodePoint'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
