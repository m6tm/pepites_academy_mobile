/// Type de tag pour une annotation.
enum TagAnnotation {
  positif,
  negatif,
  neutre, // Ajouté par sécurité si besoin de neutre
}

/// Représente une observation faite sur un académicien.
class Annotation {
  /// Identifiant unique de l'annotation.
  final String id;

  /// Contenu textuel de l'observation.
  final String contenu;

  /// Tag de l'observation (ex: positif, négatif).
  final TagAnnotation? tag;

  /// Note optionnelle attribuée (sur 10 ou 20 par exemple).
  final double? note;

  /// Date et heure de l'annotation.
  final DateTime dateHeure;

  /// Identifiant de l'académicien concerné.
  final String academicienId;

  /// Identifiant de l'atelier concerné.
  final String atelierId;

  /// Identifiant de la séance parente.
  final String seanceId;

  /// Identifiant de l'encadreur auteur de l'annotation.
  final String encadreurId;

  const Annotation({
    required this.id,
    required this.contenu,
    required this.dateHeure,
    required this.academicienId,
    required this.atelierId,
    required this.seanceId,
    required this.encadreurId,
    this.tag,
    this.note,
  });
}
