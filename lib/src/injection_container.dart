import 'package:shared_preferences/shared_preferences.dart';
import 'application/services/activity_service.dart';
import 'application/services/annotation_service.dart';
import 'application/services/app_preferences.dart';
import 'application/services/atelier_service.dart';
import 'application/services/bulletin_service.dart';
import 'application/services/connectivity_service.dart';
import 'application/services/qr_scanner_service.dart';
import 'application/services/seance_service.dart';
import 'application/services/search_service.dart';
import 'application/services/referentiel_service.dart';
import 'application/services/sms_service.dart';
import 'application/services/notification_service.dart';
import 'application/services/sync_service.dart';
import 'domain/repositories/encadreur_repository.dart';
import 'infrastructure/datasources/activity_local_datasource.dart';
import 'infrastructure/datasources/academicien_local_datasource.dart';
import 'infrastructure/datasources/annotation_local_datasource.dart';
import 'infrastructure/datasources/api_sync_datasource.dart';
import 'infrastructure/datasources/atelier_local_datasource.dart';
import 'infrastructure/datasources/bulletin_local_datasource.dart';
import 'infrastructure/datasources/connectivity_datasource.dart';
import 'infrastructure/datasources/encadreur_local_datasource.dart';
import 'infrastructure/datasources/niveau_scolaire_local_datasource.dart';
import 'infrastructure/datasources/poste_football_local_datasource.dart';
import 'infrastructure/datasources/presence_local_datasource.dart';
import 'infrastructure/datasources/seance_local_datasource.dart';
import 'infrastructure/datasources/sms_local_datasource.dart';
import 'infrastructure/datasources/notification_local_datasource.dart';
import 'infrastructure/datasources/sync_queue_local_datasource.dart';
import 'infrastructure/repositories/activity_repository_impl.dart';
import 'infrastructure/repositories/academicien_repository_impl.dart';
import 'infrastructure/repositories/annotation_repository_impl.dart';
import 'infrastructure/repositories/atelier_repository_impl.dart';
import 'infrastructure/repositories/bulletin_repository_impl.dart';
import 'infrastructure/repositories/connectivity_repository_impl.dart';
import 'infrastructure/repositories/encadreur_repository_impl.dart';
import 'infrastructure/repositories/niveau_scolaire_repository_impl.dart';
import 'infrastructure/repositories/poste_football_repository_impl.dart';
import 'infrastructure/repositories/preferences_repository_impl.dart';
import 'infrastructure/repositories/presence_repository_impl.dart';
import 'infrastructure/repositories/seance_repository_impl.dart';
import 'infrastructure/repositories/sms_repository_impl.dart';
import 'infrastructure/repositories/notification_repository_impl.dart';
import 'infrastructure/repositories/sync_repository_impl.dart';
import 'presentation/state/connectivity_state.dart';
import 'presentation/state/search_state.dart';
import 'presentation/state/sms_state.dart';
import 'presentation/state/notification_state.dart';
import 'presentation/state/sync_state.dart';
import 'presentation/state/theme_state.dart';
import 'presentation/state/language_state.dart';

/// Gestionnaire d'injection de dependances simplifie pour le projet.
/// Centralise la creation des services et repositories.
class DependencyInjection {
  static late final ActivityService activityService;
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
  static late final BulletinRepositoryImpl bulletinRepository;
  static late final BulletinService bulletinService;
  static late final SmsRepositoryImpl smsRepository;
  static late final SmsService smsService;
  static late final SmsState smsState;
  static late final SearchService searchService;
  static late final SearchState searchState;
  static late final ReferentielService referentielService;
  static late final ConnectivityService connectivityService;
  static late final SyncService syncService;
  static late final ConnectivityState connectivityState;
  static late final SyncState syncState;
  static late final NotificationRepositoryImpl notificationRepository;
  static late final NotificationService notificationService;
  static late final NotificationState notificationState;
  static late final ThemeState themeState;
  static late final LanguageState languageState;

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

    // Initialisation du Repository Bulletin
    final bulletinDatasource = BulletinLocalDatasource(sharedPrefs);
    bulletinRepository = BulletinRepositoryImpl(bulletinDatasource);

    // Initialisation du Service Bulletin
    bulletinService = BulletinService(
      bulletinRepository: bulletinRepository,
      annotationRepository: annotationRepository,
      seanceRepository: seanceRepository,
    );

    // Initialisation du module SMS
    final smsDatasource = SmsLocalDatasource(sharedPrefs);
    smsRepository = SmsRepositoryImpl(smsDatasource);
    smsService = SmsService(smsRepository: smsRepository);
    smsState = SmsState(
      smsService: smsService,
      academicienRepository: academicienRepository,
      encadreurRepository: encadreurRepoImpl,
    );

    // Initialisation du module Recherche Universelle
    searchService = SearchService(
      academicienRepository: academicienRepository,
      encadreurRepository: encadreurRepoImpl,
      seanceRepository: seanceRepository,
    );
    searchState = SearchState(searchService: searchService, prefs: sharedPrefs);

    // Initialisation du module Referentiels
    final posteDatasource = PosteFootballLocalDatasource(sharedPrefs);
    await posteDatasource.ensureInitialized();
    final posteRepository = PosteFootballRepositoryImpl(
      posteDatasource,
      academicienDatasource,
    );

    final niveauDatasource = NiveauScolaireLocalDatasource(sharedPrefs);
    await niveauDatasource.ensureInitialized();
    final niveauRepository = NiveauScolaireRepositoryImpl(
      niveauDatasource,
      academicienDatasource,
    );

    referentielService = ReferentielService(
      posteRepository: posteRepository,
      niveauRepository: niveauRepository,
    );

    // Initialisation du module Activites
    final activityDatasource = ActivityLocalDatasource(sharedPrefs);
    final activityRepository = ActivityRepositoryImpl(activityDatasource);
    activityService = ActivityService(
      repository: activityRepository,
      preferences: preferences,
    );

    // Injection tardive du service d'activites dans les services existants
    seanceService.setActivityService(activityService);
    smsService.setActivityService(activityService);
    bulletinService.setActivityService(activityService);
    qrScannerService.setActivityService(activityService);
    referentielService.setActivityService(activityService);

    // Initialisation du module Notifications
    final notificationDatasource = NotificationLocalDatasource(sharedPrefs);
    notificationRepository = NotificationRepositoryImpl(notificationDatasource);
    notificationService = NotificationService(
      notificationRepository: notificationRepository,
    );
    notificationState = NotificationState(
      notificationService: notificationService,
    );

    // Initialisation du ThemeState
    themeState = ThemeState();
    await themeState.charger();

    // Initialisation du LanguageState
    languageState = LanguageState();
    await languageState.charger();

    // Initialisation du module Hors-ligne / Synchronisation
    final connectivityDatasource = ConnectivityDatasource();
    connectivityDatasource.startListening();
    final connectivityRepo = ConnectivityRepositoryImpl(connectivityDatasource);
    connectivityService = ConnectivityService(repository: connectivityRepo);

    final syncQueueDatasource = SyncQueueLocalDatasource();
    final syncRepo = SyncRepositoryImpl(syncQueueDatasource);
    final apiSyncDatasource = StubApiSyncDatasource();
    syncService = SyncService(
      syncRepository: syncRepo,
      apiDatasource: apiSyncDatasource,
      connectivityService: connectivityService,
    );

    connectivityState = ConnectivityState(
      connectivityService: connectivityService,
    );
    syncState = SyncState(
      syncService: syncService,
      connectivityState: connectivityState,
    );
  }
}
