/// Représente un exercice spécifique au sein d'une séance d'entraînement.
class Atelier {
  final String id;
  final String nom;
  final String description;
  final String icone; // Nom ou clé de l'icône représentative
  final int ordre; // Pour l'organisation par glisser-déposer
  final String seanceId;

  Atelier({
    required this.id,
    required this.nom,
    required this.description,
    required this.icone,
    required this.ordre,
    required this.seanceId,
  });
}
