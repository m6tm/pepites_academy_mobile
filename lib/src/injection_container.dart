import 'package:shared_preferences/shared_preferences.dart';
import 'application/services/app_preferences.dart';
import 'infrastructure/repositories/preferences_repository_impl.dart';

/// Gestionnaire d'injection de dépendances simplifié pour le projet.
/// Centralise la création des services et repositories.
class DependencyInjection {
  static late final AppPreferences preferences;

  /// Initialise les dépendances asynchrones.
  static Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    // Initialisation du Repository (Infrastructure)
    final preferencesRepository = PreferencesRepositoryImpl(sharedPrefs);

    // Initialisation du Service (Application)
    preferences = AppPreferences(preferencesRepository);
  }
}
