import '../entities/activity.dart';

/// Contrat pour la gestion du journal d'activites.
abstract class ActivityRepository {
  /// Enregistre une nouvelle activite.
  Future<Activity> add(Activity activity);

  /// Recupere toutes les activites triees par date decroissante.
  Future<List<Activity>> getAll();

  /// Recupere les N dernieres activites.
  Future<List<Activity>> getRecent(int limit);

  /// Supprime les activites anterieures a une date donnee.
  Future<void> purgeOlderThan(DateTime date);
}
