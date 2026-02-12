/// Compétences évaluées dans le bulletin.
class Competences {
  final double technique;
  final double physique;
  final double tactique;
  final double mental;
  final double espritEquipe;

  const Competences({
    required this.technique,
    required this.physique,
    required this.tactique,
    required this.mental,
    required this.espritEquipe,
  });
}

/// Représente un bulletin de formation périodique.
class Bulletin {
  /// Identifiant unique du bulletin.
  final String id;

  /// Date de début de la période évaluée.
  final DateTime dateDebutPeriode;

  /// Date de fin de la période évaluée.
  final DateTime dateFinPeriode;

  /// Identifiant de l'académicien concerné.
  final String academicienId;

  /// Observations générales de l'encadreur principal.
  final String observationsGenerales;

  /// Agrégation des compétences sur la période.
  final Competences competences;

  const Bulletin({
    required this.id,
    required this.dateDebutPeriode,
    required this.dateFinPeriode,
    required this.academicienId,
    required this.observationsGenerales,
    required this.competences,
  });
}
