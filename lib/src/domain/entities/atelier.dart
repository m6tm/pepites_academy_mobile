import 'annotation.dart';

/// Représente un atelier ou exercice au sein d'une séance.
class Atelier {
  /// Identifiant unique de l'atelier.
  final String id;

  /// Nom de l'exercice (ex: "Dribble", "Finition").
  final String nom;

  /// Description détaillée de l'exercice.
  final String? description;

  /// Chemin ou URL de l'icône représentant l'exercice.
  final String? icone;

  /// Ordre d'exécution dans la séance (1, 2, 3...).
  final int ordre;

  /// Identifiant de la séance parente.
  final String seanceId;

  /// Liste des annotations faites durant cet atelier (chargées optionnellement).
  final List<Annotation>? annotations;

  const Atelier({
    required this.id,
    required this.nom,
    required this.ordre,
    required this.seanceId,
    this.description,
    this.icone,
    this.annotations,
  });
}
