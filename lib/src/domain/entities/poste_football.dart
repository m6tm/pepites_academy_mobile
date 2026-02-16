/// Represente un poste de jeu au football (Gardien, Defenseur, etc.).
class PosteFootball {
  final String id;
  final String nom;
  final String? description;
  final String? iconeCodePoint;

  PosteFootball({
    required this.id,
    required this.nom,
    this.description,
    this.iconeCodePoint,
  });

  /// Cree une copie du poste avec des champs modifies.
  PosteFootball copyWith({
    String? id,
    String? nom,
    String? description,
    String? iconeCodePoint,
  }) {
    return PosteFootball(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      iconeCodePoint: iconeCodePoint ?? this.iconeCodePoint,
    );
  }

  /// Serialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'iconeCodePoint': iconeCodePoint,
    };
  }

  /// Deserialisation depuis Map.
  factory PosteFootball.fromJson(Map<String, dynamic> json) {
    return PosteFootball(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      iconeCodePoint: json['iconeCodePoint'] as String?,
    );
  }
}
