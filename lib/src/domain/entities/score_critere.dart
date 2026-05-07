/// Represente le score d'un critere d'evaluation (2 elements notes chacun sur 5).
class ScoreCritere {
  final String critereId;
  final String element1Id;
  final double noteElement1;
  final String element2Id;
  final double noteElement2;

  const ScoreCritere({
    required this.critereId,
    required this.element1Id,
    required this.noteElement1,
    required this.element2Id,
    required this.noteElement2,
  });

  /// Total du critere (somme des 2 notes, sur 10).
  double get totalCritere => noteElement1 + noteElement2;

  ScoreCritere copyWith({
    String? critereId,
    String? element1Id,
    double? noteElement1,
    String? element2Id,
    double? noteElement2,
  }) {
    return ScoreCritere(
      critereId: critereId ?? this.critereId,
      element1Id: element1Id ?? this.element1Id,
      noteElement1: noteElement1 ?? this.noteElement1,
      element2Id: element2Id ?? this.element2Id,
      noteElement2: noteElement2 ?? this.noteElement2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'critere_id': critereId,
      'element_1_id': element1Id,
      'note_element_1': noteElement1,
      'element_2_id': element2Id,
      'note_element_2': noteElement2,
    };
  }

  factory ScoreCritere.fromJson(Map<String, dynamic> json) {
    return ScoreCritere(
      critereId: (json['critere_id'] ?? json['critereId']) as String,
      element1Id: (json['element_1_id'] ?? json['element1Id']) as String,
      noteElement1:
          (json['note_element_1'] ?? json['noteElement1'] as num).toDouble(),
      element2Id: (json['element_2_id'] ?? json['element2Id']) as String,
      noteElement2:
          (json['note_element_2'] ?? json['noteElement2'] as num).toDouble(),
    );
  }
}
