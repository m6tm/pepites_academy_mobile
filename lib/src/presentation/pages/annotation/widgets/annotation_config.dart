import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/annotation.dart';

class AnnotationFormConfig {
  final List<ConfigurationElementEvaluation> configuration;
  final bool showHistorique;
  final bool showCommentaire;
  final int maxHistoriqueItems;
  final String scoreMaxTotal;
  final String scoreMaxCritere;
  final double noteMin;
  final double noteMax;
  final int noteDivisions;

  const AnnotationFormConfig({
    required this.configuration,
    this.showHistorique = true,
    this.showCommentaire = true,
    this.maxHistoriqueItems = 3,
    this.scoreMaxTotal = '5',
    this.scoreMaxCritere = '5',
    this.noteMin = 0,
    this.noteMax = 5,
    this.noteDivisions = 10,
  });

  static const AnnotationFormConfig defaultConfig = AnnotationFormConfig(
    configuration: [],
    scoreMaxTotal: '5',
    scoreMaxCritere: '5',
    noteMin: 0,
    noteMax: 5,
    noteDivisions: 10,
  );

  factory AnnotationFormConfig.fromAtelier(Atelier atelier) {
    return AnnotationFormConfig(
      configuration: atelier.configurationEvaluation ?? [],
    );
  }
}

class AnnotationNoteEntry {
  final String critereId;
  final String elementId;
  double note;

  AnnotationNoteEntry({
    required this.critereId,
    required this.elementId,
    this.note = 0,
  });

  String get key => '${critereId}_$elementId';
}

class AnnotationNoteManager {
  final List<ConfigurationElementEvaluation> configuration;
  final Map<String, double> _notes = {};

  AnnotationNoteManager(this.configuration) {
    _initDefaultNotes();
  }

  void _initDefaultNotes() {
    for (final config in configuration) {
      for (final elementId in config.elementIds) {
        _notes['${config.critereId}_$elementId'] = -1.0;
      }
    }
  }

  double getNote(String critereId, String elementId) {
    final value = _notes['${critereId}_$elementId'] ?? -1.0;
    return value < 0 ? 0.0 : value;
  }

  void setNote(String critereId, String elementId, double note) {
    _notes['${critereId}_$elementId'] = note;
  }

  double getCritereTotal(ConfigurationElementEvaluation config) {
    final notes = config.elementIds.map((eid) => getNote(config.critereId, eid)).toList();
    if (notes.isEmpty) return 0.0;
    return notes.fold(0.0, (sum, n) => sum + n) / notes.length;
  }

  double get scoreTotal {
    if (configuration.isEmpty) return 0.0;
    double sommeMoyennes = 0;
    for (final config in configuration) {
      sommeMoyennes += getCritereTotal(config);
    }
    return sommeMoyennes / configuration.length;
  }

  bool get allElementsRated {
    for (final config in configuration) {
      for (final elementId in config.elementIds) {
        final value = _notes['${config.critereId}_$elementId'] ?? -1.0;
        if (value < 0) return false;
      }
    }
    return true;
  }

  List<ScoreAnnotation> toScoreAnnotations() {
    return configuration.map((config) {
      return ScoreAnnotation(
        critereId: config.critereId,
        elements: config.elementIds.map((eid) => ScoreElementNote(
          elementId: eid,
          note: _notes['${config.critereId}_$eid'] ?? 0.0,
        )).toList(),
      );
    }).toList();
  }

  void reset() {
    _notes.clear();
    _initDefaultNotes();
  }
}

class AnnotationDisplayConfig {
  final bool showScoreTotal;
  final bool showScoreCritere;
  final bool showHistorique;
  final bool showDateInHistorique;
  final bool showCommentaireInHistorique;
  final int maxHistoriqueItems;

  const AnnotationDisplayConfig({
    this.showScoreTotal = true,
    this.showScoreCritere = true,
    this.showHistorique = true,
    this.showDateInHistorique = true,
    this.showCommentaireInHistorique = true,
    this.maxHistoriqueItems = 3,
  });

  static const AnnotationDisplayConfig defaultConfig = AnnotationDisplayConfig();
}
