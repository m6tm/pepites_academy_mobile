/// TTL centralises par type de donnee.
/// Toute nouvelle entite doit ajouter sa constante ici plutot que d'utiliser
/// une duree litterale dans les repositories.
abstract class CacheTtl {
  static const evaluations = Duration(minutes: 5);
  static const referentiel = Duration(hours: 1);
  static const seances = Duration(minutes: 10);
  static const ateliers = Duration(minutes: 10);
  static const academiciens = Duration(minutes: 15);
  static const presences = Duration(minutes: 5);
}
