import 'enums/exercice_statut.dart';

class Exercice {
  final String id;
  final String nom;
  final String description;
  final int ordre;
  final ExerciceStatut statut;
  final String atelierId;

  const Exercice({
    required this.id,
    required this.nom,
    required this.description,
    required this.ordre,
    required this.statut,
    required this.atelierId,
  });

  Exercice copyWith({
    String? id,
    String? nom,
    String? description,
    int? ordre,
    ExerciceStatut? statut,
    String? atelierId,
  }) {
    return Exercice(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      ordre: ordre ?? this.ordre,
      statut: statut ?? this.statut,
      atelierId: atelierId ?? this.atelierId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'ordre': ordre,
      'statut': statut.name,
      'atelierId': atelierId,
    };
  }

  factory Exercice.fromJson(Map<String, dynamic> json) {
    return Exercice(
      id: json['id'] as String,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ordre: json['ordre'] as int? ?? 0,
      statut: ExerciceStatut.values.firstWhere(
        (e) => e.name == json['statut'],
        orElse: () => ExerciceStatut.cree,
      ),
      atelierId: (json['atelier_id'] ?? json['atelierId']) as String,
    );
  }
}
