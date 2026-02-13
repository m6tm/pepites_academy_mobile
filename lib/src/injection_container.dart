import 'package:shared_preferences/shared_preferences.dart';
import 'application/services/annotation_service.dart';
import 'application/services/app_preferences.dart';
import 'application/services/atelier_service.dart';
import 'application/services/qr_scanner_service.dart';
import 'application/services/seance_service.dart';
import 'domain/repositories/encadreur_repository.dart';
import 'infrastructure/datasources/academicien_local_datasource.dart';
import 'infrastructure/datasources/annotation_local_datasource.dart';
import 'infrastructure/datasources/atelier_local_datasource.dart';
import 'infrastructure/datasources/encadreur_local_datasource.dart';
import 'infrastructure/datasources/presence_local_datasource.dart';
import 'infrastructure/datasources/seance_local_datasource.dart';
import 'infrastructure/repositories/academicien_repository_impl.dart';
import 'infrastructure/repositories/annotation_repository_impl.dart';
import 'infrastructure/repositories/atelier_repository_impl.dart';
import 'infrastructure/repositories/encadreur_repository_impl.dart';
import 'infrastructure/repositories/preferences_repository_impl.dart';
import 'infrastructure/repositories/presence_repository_impl.dart';
import 'infrastructure/repositories/seance_repository_impl.dart';

/// Gestionnaire d'injection de dependances simplifie pour le projet.
/// Centralise la creation des services et repositories.
class DependencyInjection {
  static late final AppPreferences preferences;
  static late final EncadreurRepository encadreurRepository;
  static late final AcademicienRepositoryImpl academicienRepository;
  static late final PresenceRepositoryImpl presenceRepository;
  static late final SeanceRepositoryImpl seanceRepository;
  static late final AtelierRepositoryImpl atelierRepository;
  static late final QrScannerService qrScannerService;
  static late final SeanceService seanceService;
  static late final AtelierService atelierService;
  static late final AnnotationRepositoryImpl annotationRepository;
  static late final AnnotationService annotationService;

  /// Initialise les dependances asynchrones.
  static Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    // Initialisation du Repository Preferences (Infrastructure)
    final preferencesRepository = PreferencesRepositoryImpl(sharedPrefs);

    // Initialisation du Service Preferences (Application)
    preferences = AppPreferences(preferencesRepository);

    // Initialisation du Repository Encadreur
    final encadreurDatasource = EncadreurLocalDatasource(sharedPrefs);
    final encadreurRepoImpl = EncadreurRepositoryImpl(encadreurDatasource);
    encadreurRepository = encadreurRepoImpl;

    // Initialisation du Repository Academicien
    final academicienDatasource = AcademicienLocalDatasource(sharedPrefs);
    academicienRepository = AcademicienRepositoryImpl(academicienDatasource);

    // Initialisation du Repository Presence
    final presenceDatasource = PresenceLocalDatasource(sharedPrefs);
    presenceRepository = PresenceRepositoryImpl(presenceDatasource);

    // Initialisation du Repository Seance
    final seanceDatasource = SeanceLocalDatasource(sharedPrefs);
    seanceRepository = SeanceRepositoryImpl(seanceDatasource);

    // Initialisation du Service QR Scanner
    qrScannerService = QrScannerService(
      academicienRepository: academicienRepository,
      encadreurRepository: encadreurRepoImpl,
      presenceRepository: presenceRepository,
      seanceRepository: seanceRepository,
    );

    // Initialisation du Repository Atelier
    final atelierDatasource = AtelierLocalDatasource(sharedPrefs);
    atelierRepository = AtelierRepositoryImpl(atelierDatasource);

    // Initialisation du Service Seance
    seanceService = SeanceService(
      seanceRepository: seanceRepository,
      presenceRepository: presenceRepository,
    );

    // Initialisation du Service Atelier
    atelierService = AtelierService(
      atelierRepository: atelierRepository,
      seanceRepository: seanceRepository,
    );

    // Initialisation du Repository Annotation
    final annotationDatasource = AnnotationLocalDatasource(sharedPrefs);
    annotationRepository = AnnotationRepositoryImpl(annotationDatasource);

    // Initialisation du Service Annotation
    annotationService = AnnotationService(
      annotationRepository: annotationRepository,
    );
  }
}
