import 'score_annotation.dart';
export 'score_annotation.dart';

/// Represente une annotation multicritere d'un academicien sur un atelier.
/// Remplace l'ancien modele (tags + note unique) par un systeme d'evaluation
/// structuree sur 5 criteres x 2 elements, chaque element etant note sur 5.
class Annotation {
  final String id;
  final String academicienId;
  final String atelierId;
  final String? exerciceId;
  final String seanceId;
  final String encadreurId;
  final DateTime horodate;
  final List<ScoreAnnotation> scores;
  final String? commentaire;

  Annotation({
    required this.id,
    required this.academicienId,
    required this.atelierId,
    this.exerciceId,
    required this.seanceId,
    required this.encadreurId,
    required this.horodate,
    required this.scores,
    this.commentaire,
  });

  double get scoreTotal =>
      scores.fold(0.0, (sum, s) => sum + s.totalCritere);

  String get contenu => commentaire ?? '';

  List<String> get tags => [];

  double? get note => null;

  Annotation copyWith({
    String? id,
    String? academicienId,
    String? atelierId,
    String? exerciceId,
    String? seanceId,
    String? encadreurId,
    DateTime? horodate,
    List<ScoreAnnotation>? scores,
    String? commentaire,
  }) {
    return Annotation(
      id: id ?? this.id,
      academicienId: academicienId ?? this.academicienId,
      atelierId: atelierId ?? this.atelierId,
      exerciceId: exerciceId ?? this.exerciceId,
      seanceId: seanceId ?? this.seanceId,
      encadreurId: encadreurId ?? this.encadreurId,
      horodate: horodate ?? this.horodate,
      scores: scores ?? this.scores,
      commentaire: commentaire ?? this.commentaire,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academicien_id': academicienId,
      'atelier_id': atelierId,
      'exercice_id': exerciceId,
      'seance_id': seanceId,
      'encadreur_id': encadreurId,
      'horodate': horodate.toIso8601String(),
      'scores': scores.map((s) => s.toJson()).toList(),
      'contenu': commentaire,
    };
  }

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] as String,
      academicienId: (json['academicien_id'] ?? json['academicienId']) as String,
      atelierId: (json['atelier_id'] ?? json['atelierId']) as String,
      exerciceId: json['exercice_id'] as String?,
      seanceId: (json['seance_id'] ?? json['seanceId']) as String,
      encadreurId: (json['encadreur_id'] ?? json['encadreurId']) as String,
      horodate: DateTime.parse(json['horodate'] as String),
      scores: (json['scores'] as List<dynamic>?)
              ?.map((e) => ScoreAnnotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      commentaire: (json['contenu'] ?? json['commentaire']) as String?,
    );
  }
}