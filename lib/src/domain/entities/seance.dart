/// Statut d'une séance d'entraînement.
enum StatutSeance { ouverte, fermee, aVenir }

/// Représente une séance d'entraînement.
class Seance {
  /// Identifiant unique de la séance.
  final String id;

  /// Date et heure de début prévue.
  final DateTime dateDebut;

  /// Date et heure de fin prévue ou effective.
  final DateTime dateFin;

  /// Statut actuel de la séance.
  final StatutSeance statut;

  /// Identifiant de l'encadreur responsable de la séance.
  final String encadreurId;

  const Seance({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    required this.encadreurId,
    this.statut = StatutSeance.aVenir,
  });
}
