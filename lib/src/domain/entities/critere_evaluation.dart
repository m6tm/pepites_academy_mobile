import 'element_evaluation.dart';
export 'element_evaluation.dart';

/// Represente un critere d'evaluation multicritere (Technique, Tactique, etc.).
class CritereEvaluation {
  final String id;
  final String nom;
  final String description;
  final int? ordre;
  final List<ElementEvaluation> elements;

  const CritereEvaluation({
    required this.id,
    required this.nom,
    required this.description,
    this.ordre,
    required this.elements,
  });

  CritereEvaluation copyWith({
    String? id,
    String? nom,
    String? description,
    int? ordre,
    List<ElementEvaluation>? elements,
  }) {
    return CritereEvaluation(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      ordre: ordre ?? this.ordre,
      elements: elements ?? this.elements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'ordre': ordre,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }

  factory CritereEvaluation.fromJson(Map<String, dynamic> json) {
    return CritereEvaluation(
      id: json['id'] as String,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ordre: json['ordre'] as int?,
      elements: (json['elements'] as List<dynamic>?)
              ?.map((e) => ElementEvaluation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
