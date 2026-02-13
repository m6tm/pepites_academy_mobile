/// Types d'ateliers predefinies avec leurs icones associees.
enum AtelierType {
  dribble,
  passes,
  finition,
  physique,
  jeuEnSituation,
  tactique,
  gardien,
  echauffement,
  personnalise,
}

/// Represente un exercice specifique au sein d'une seance d'entrainement.
class Atelier {
  final String id;
  final String nom;
  final String description;
  final AtelierType type;
  final int ordre;
  final String seanceId;

  Atelier({
    required this.id,
    required this.nom,
    this.description = '',
    required this.type,
    required this.ordre,
    required this.seanceId,
  });

  /// Cree une copie de l'atelier avec des champs modifies.
  Atelier copyWith({
    String? id,
    String? nom,
    String? description,
    AtelierType? type,
    int? ordre,
    String? seanceId,
  }) {
    return Atelier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      type: type ?? this.type,
      ordre: ordre ?? this.ordre,
      seanceId: seanceId ?? this.seanceId,
    );
  }

  /// Serialise l'atelier en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'type': type.name,
      'ordre': ordre,
      'seanceId': seanceId,
    };
  }

  /// Deserialise un atelier depuis un Map JSON.
  factory Atelier.fromJson(Map<String, dynamic> json) {
    return Atelier(
      id: json['id'] as String,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: AtelierType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AtelierType.personnalise,
      ),
      ordre: json['ordre'] as int? ?? 0,
      seanceId: json['seanceId'] as String,
    );
  }

  /// Retourne le label affichable du type d'atelier.
  String get typeLabel {
    switch (type) {
      case AtelierType.dribble:
        return 'Dribble';
      case AtelierType.passes:
        return 'Passes';
      case AtelierType.finition:
        return 'Finition';
      case AtelierType.physique:
        return 'Condition physique';
      case AtelierType.jeuEnSituation:
        return 'Jeu en situation';
      case AtelierType.tactique:
        return 'Tactique';
      case AtelierType.gardien:
        return 'Gardien';
      case AtelierType.echauffement:
        return 'Echauffement';
      case AtelierType.personnalise:
        return 'Personnalise';
    }
  }
}
