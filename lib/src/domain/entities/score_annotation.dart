/// Represente la note d'un element dans une annotation.
class ScoreElementNote {
  final String elementId;
  final double note;

  const ScoreElementNote({
    required this.elementId,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'element_id': elementId,
      'note': note,
    };
  }

  factory ScoreElementNote.fromJson(Map<String, dynamic> json) {
    return ScoreElementNote(
      elementId: (json['element_id'] ?? json['elementId']) as String,
      note: (json['note'] as num).toDouble(),
    );
  }
}

/// Represente le score d'un critere dans une annotation multicritere.
class ScoreAnnotation {
  final String critereId;
  final List<ScoreElementNote> elements;

  const ScoreAnnotation({
    required this.critereId,
    required this.elements,
  });

  /// Moyenne des notes des elements du critere (sur 5).
  double get totalCritere {
    if (elements.isEmpty) return 0.0;
    return elements.fold(0.0, (sum, e) => sum + e.note) / elements.length;
  }

  ScoreAnnotation copyWith({
    String? critereId,
    List<ScoreElementNote>? elements,
  }) {
    return ScoreAnnotation(
      critereId: critereId ?? this.critereId,
      elements: elements ?? this.elements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'critere_id': critereId,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }

  factory ScoreAnnotation.fromJson(Map<String, dynamic> json) {
    final rawElements = json['elements'];
    if (rawElements is List) {
      return ScoreAnnotation(
        critereId: json['critere_id'] as String,
        elements: rawElements
            .map((e) => ScoreElementNote.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    // Fallback compatibilite ancien format
    final notes = <ScoreElementNote>[];
    final e1 = json['element_1_id'] ?? json['element1Id'];
    final n1 = json['note_element_1'] ?? json['noteElement1'];
    if (e1 != null && n1 != null) {
      notes.add(ScoreElementNote(elementId: e1 as String, note: (n1 as num).toDouble()));
    }
    final e2 = json['element_2_id'] ?? json['element2Id'];
    final n2 = json['note_element_2'] ?? json['noteElement2'];
    if (e2 != null && n2 != null) {
      notes.add(ScoreElementNote(elementId: e2 as String, note: (n2 as num).toDouble()));
    }
    return ScoreAnnotation(
      critereId: json['critere_id'] as String,
      elements: notes,
    );
  }
}
