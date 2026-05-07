import 'score_critere.dart';
export 'score_critere.dart';

/// Represente une evaluation multicritere d'un academicien sur un atelier.
/// Produit un score structure par critere (5 criteres x 2 elements notes sur 5).
class Evaluation {
  final String id;
  final String academicienId;
  final String atelierId;
  final String seanceId;
  final String encadreurId;
  final DateTime horodate;
  final List<ScoreCritere> scores;
  final String? commentaire;

  const Evaluation({
    required this.id,
    required this.academicienId,
    required this.atelierId,
    required this.seanceId,
    required this.encadreurId,
    required this.horodate,
    required this.scores,
    this.commentaire,
  });

  /// Score total de l'evaluation (somme des 5 criteres, sur 50).
  double get scoreTotal =>
      scores.fold(0.0, (sum, s) => sum + s.totalCritere);

  Evaluation copyWith({
    String? id,
    String? academicienId,
    String? atelierId,
    String? seanceId,
    String? encadreurId,
    DateTime? horodate,
    List<ScoreCritere>? scores,
    String? commentaire,
  }) {
    return Evaluation(
      id: id ?? this.id,
      academicienId: academicienId ?? this.academicienId,
      atelierId: atelierId ?? this.atelierId,
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
      'seance_id': seanceId,
      'encadreur_id': encadreurId,
      'horodate': horodate.toIso8601String(),
      'scores': scores.map((s) => s.toJson()).toList(),
      'commentaire': commentaire,
    };
  }

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'] as String,
      academicienId:
          (json['academicien_id'] ?? json['academicienId']) as String,
      atelierId: (json['atelier_id'] ?? json['atelierId']) as String,
      seanceId: (json['seance_id'] ?? json['seanceId']) as String,
      encadreurId: (json['encadreur_id'] ?? json['encadreurId']) as String,
      horodate: DateTime.parse(json['horodate'] as String),
      scores: (json['scores'] as List<dynamic>)
          .map((e) => ScoreCritere.fromJson(e as Map<String, dynamic>))
          .toList(),
      commentaire: json['commentaire'] as String?,
    );
  }
}
