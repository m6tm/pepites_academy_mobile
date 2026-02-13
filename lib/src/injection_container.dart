import 'package:shared_preferences/shared_preferences.dart';
import 'application/services/app_preferences.dart';
import 'domain/repositories/encadreur_repository.dart';
import 'infrastructure/datasources/academicien_local_datasource.dart';
import 'infrastructure/datasources/encadreur_local_datasource.dart';
import 'infrastructure/repositories/academicien_repository_impl.dart';
import 'infrastructure/repositories/encadreur_repository_impl.dart';
import 'infrastructure/repositories/preferences_repository_impl.dart';

/// Gestionnaire d'injection de dépendances simplifié pour le projet.
/// Centralise la création des services et repositories.
class DependencyInjection {
  static late final AppPreferences preferences;
  static late final EncadreurRepository encadreurRepository;
  static late final AcademicienRepositoryImpl academicienRepository;

  /// Initialise les dépendances asynchrones.
  static Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    // Initialisation du Repository (Infrastructure)
    final preferencesRepository = PreferencesRepositoryImpl(sharedPrefs);

    // Initialisation du Service (Application)
    preferences = AppPreferences(preferencesRepository);

    // Initialisation du Repository Encadreur
    final encadreurDatasource = EncadreurLocalDatasource(sharedPrefs);
    encadreurRepository = EncadreurRepositoryImpl(encadreurDatasource);

    // Initialisation du Repository Academicien
    final academicienDatasource = AcademicienLocalDatasource(sharedPrefs);
    academicienRepository = AcademicienRepositoryImpl(academicienDatasource);
  }
}
