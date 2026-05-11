/// Represente un element evaluable au sein d'un critere d'evaluation.
class ElementEvaluation {
  final String id;
  final String libelle;
  final String description;
  final String critereId;
  final int? ordre;

  const ElementEvaluation({
    required this.id,
    required this.libelle,
    required this.description,
    required this.critereId,
    this.ordre,
  });

  ElementEvaluation copyWith({
    String? id,
    String? libelle,
    String? description,
    String? critereId,
    int? ordre,
  }) {
    return ElementEvaluation(
      id: id ?? this.id,
      libelle: libelle ?? this.libelle,
      description: description ?? this.description,
      critereId: critereId ?? this.critereId,
      ordre: ordre ?? this.ordre,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'description': description,
      'critere_id': critereId,
      'ordre': ordre,
    };
  }

  factory ElementEvaluation.fromJson(Map<String, dynamic> json) {
    return ElementEvaluation(
      id: json['id'] as String,
      libelle: json['libelle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      critereId: (json['critere_id'] ?? json['critereId']) as String,
      ordre: json['ordre'] as int?,
    );
  }
}
