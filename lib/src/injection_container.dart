import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'application/services/activity_service.dart';
import 'application/services/annotation_service.dart';
import 'application/services/app_preferences.dart';
import 'application/services/atelier_service.dart';
import 'application/services/exercice_service.dart';
import 'application/services/bulletin_service.dart';
import 'application/services/connectivity_service.dart';
import 'application/services/qr_scanner_service.dart';
import 'application/services/seance_service.dart';
import 'application/services/search_service.dart';
import 'application/services/referentiel_service.dart';
import 'application/services/sms_service.dart';
import 'application/services/notification_service.dart';
import 'application/services/sync_service.dart';
import 'application/services/auth_service.dart';
import 'application/services/biometric_service.dart';
import 'application/services/security_service.dart';
import 'application/services/dashboard_service.dart';
import 'application/services/role_service.dart';
import 'infrastructure/datasources/activity_local_datasource.dart';
import 'infrastructure/datasources/academicien_local_datasource.dart';
import 'infrastructure/datasources/annotation_local_datasource.dart';
import 'infrastructure/datasources/atelier_local_datasource.dart';
import 'infrastructure/datasources/exercice_local_datasource.dart';
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
import 'infrastructure/datasources/api_sync_datasource_impl.dart';
import 'infrastructure/network/dio_client.dart';
import 'infrastructure/network/auth_interceptor.dart';
import 'infrastructure/repositories/activity_repository_impl.dart';
import 'infrastructure/repositories/academicien_repository_impl.dart';
import 'infrastructure/repositories/annotation_repository_impl.dart';
import 'infrastructure/repositories/atelier_repository_impl.dart';
import 'infrastructure/repositories/exercice_repository_impl.dart';
import 'infrastructure/repositories/bulletin_repository_impl.dart';
import 'infrastructure/repositories/connectivity_repository_impl.dart';
import 'infrastructure/repositories/encadreur_repository_impl.dart';
import 'infrastructure/repositories/niveau_scolaire_repository_impl.dart';
import 'infrastructure/repositories/poste_football_repository_impl.dart';
import 'infrastructure/repositories/preferences_repository_impl.dart';
import 'infrastructure/repositories/presence_repository_impl.dart';
import 'infrastructure/repositories/seance_repository_impl.dart';
import 'infrastructure/repositories/sms_repository_impl.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'infrastructure/repositories/notification_repository_impl.dart';
import 'infrastructure/repositories/security_repository_impl.dart';
import 'domain/entities/sync_operation.dart';
import 'infrastructure/repositories/sync_repository_impl.dart';
import 'infrastructure/repositories/role_repository_impl.dart';
import 'infrastructure/repositories/dashboard_repository_impl.dart';
import 'infrastructure/services/firebase_push_notification_service.dart';
import 'infrastructure/services/upload_service.dart';
import 'presentation/state/connectivity_state.dart';
import 'presentation/state/search_state.dart';
import 'presentation/state/sms_state.dart';
import 'presentation/state/notification_state.dart';
import 'presentation/state/sync_state.dart';
import 'presentation/state/theme_state.dart';
import 'presentation/state/language_state.dart';
import 'presentation/state/exercice_state.dart';
import 'presentation/state/atelier_state.dart';
import 'presentation/state/annotation_state.dart';

/// Gestionnaire d'injection de dependances simplifie pour le projet.
/// Centralise la creation des services et repositories.
class DependencyInjection {
  static late final ActivityService activityService;
  static late final AppPreferences preferences;
  static late final AuthService authService;
  static late final EncadreurRepositoryImpl encadreurRepository;
  static late final AcademicienRepositoryImpl academicienRepository;
  static late final PresenceRepositoryImpl presenceRepository;
  static late final SeanceRepositoryImpl seanceRepository;
  static late final AtelierRepositoryImpl atelierRepository;
  static late final ExerciceRepositoryImpl exerciceRepository;
  static late final QrScannerService qrScannerService;
  static late final SeanceService seanceService;
  static late final AtelierService atelierService;
  static late final ExerciceService exerciceService;
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
  static late final ExerciceState exerciceState;
  static late final AtelierState atelierState;
  static late final AnnotationState annotationState;
  static late final FirebasePushNotificationService
  firebasePushNotificationService;
  static late final BiometricService biometricService;
  static late final SecurityService securityService;
  static late final SecurityRepositoryImpl securityRepository;
  static late final ApiSyncDatasourceImpl apiSyncDatasource;
  static late final DashboardService dashboardService;
  static late final RoleService roleService;
  static late final RoleRepositoryImpl roleRepository;
  static late final DashboardRepositoryImpl dashboardRepository;
  static late final UploadService uploadService;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static late PreferencesRepositoryImpl _preferencesRepository;
  static late SeanceLocalDatasource _seanceDatasource;
  static late SmsLocalDatasource _smsDatasource;
  static late DioClient _dioClient;

  static DioClient get dioClient => _dioClient;

  static late NotificationLocalDatasource notificationDatasource;

  /// Initialise les dependances asynchrones.
  static Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    // Initialisation du Repository Preferences (Infrastructure)
    final preferencesRepository = PreferencesRepositoryImpl(sharedPrefs);
    _preferencesRepository = preferencesRepository;

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
    _seanceDatasource = seanceDatasource;
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

    // Initialisation du Repository Exercice
    final exerciceDatasource = ExerciceLocalDatasource(sharedPrefs);
    exerciceRepository = ExerciceRepositoryImpl(exerciceDatasource);

    // Initialisation du Service Seance
    seanceService = SeanceService(
      seanceRepository: seanceRepository,
      presenceRepository: presenceRepository,
    );

    // Initialisation du Service Atelier
    atelierService = AtelierService(
      atelierRepository: atelierRepository,
      seanceRepository: seanceRepository,
      exerciceRepository: exerciceRepository,
    );

    // Initialisation du Service Exercice
    exerciceService = ExerciceService(
      exerciceRepository: exerciceRepository,
      atelierRepository: atelierRepository,
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
      presenceRepository: presenceRepository,
    );

    // Initialisation du module SMS
    final smsDatasource = SmsLocalDatasource(sharedPrefs);
    _smsDatasource = smsDatasource;
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
    final dioClient = DioClient();
    _dioClient = dioClient;

    // Ajout de l'intercepteur d'authentification pour le refresh automatique
    final authInterceptor = AuthInterceptor(
      dio: dioClient.dio,
      preferences: preferences,
    );
    dioClient.addInterceptor(authInterceptor);

    // Restauration du token (temporairement manuel pour rassurer si besoin,
    // bien que l'intercepteur le gère aussi pour chaque requête)
    final token = await preferences.getToken();
    if (token != null) {
      dioClient.setToken(token);
    }

    final apiDatasource = ApiSyncDatasourceImpl(dioClient);
    apiSyncDatasource = apiDatasource;
    syncService = SyncService(
      syncRepository: syncRepo,
      apiDatasource: apiDatasource,
      connectivityService: connectivityService,
    );

    // Configuration du callback pour les erreurs de conflit (409)
    syncService.onConflictError = _handleConflictError;

    // Initialisation du module Notifications
    notificationDatasource = NotificationLocalDatasource(sharedPrefs);
    notificationRepository = NotificationRepositoryImpl(
      notificationDatasource,
      sharedPrefs,
      dioClient: _dioClient,
    );
    notificationRepository.setSyncService(syncService);
    notificationService = NotificationService(
      notificationRepository: notificationRepository,
    );
    notificationState = NotificationState(
      notificationService: notificationService,
    );

    // Initialisation du service de notifications push Firebase
    firebasePushNotificationService = FirebasePushNotificationService(
      notificationDatasource,
      sharedPrefs,
    );

    // Connexion du callback pour rafraîchir les notifications in-app en temps réel
    firebasePushNotificationService.onNotificationReceived = () {
      notificationState.rafraichirDepuisCache();
    };

    // Initialisation de l'authentification
    final authRepository = AuthRepositoryImpl(dioClient, preferences);
    authService = AuthService(authRepository);
    authService.setSyncService(syncService);

    // Initialisation du module de securite et biometrie
    securityRepository = SecurityRepositoryImpl(dioClient);
    final localAuth = LocalAuthentication();
    biometricService = BiometricService(
      localAuth: localAuth,
      securityRepository: securityRepository,
      getBiometricEnabled: preferences.getBiometricEnabled,
      setBiometricEnabled: preferences.setBiometricEnabled,
    );
    securityService = SecurityService(repository: securityRepository);

    // Initialisation du repository Dashboard
    dashboardRepository = DashboardRepositoryImpl(dioClient, sharedPrefs);
    dashboardRepository.setSyncService(syncService);

    // Initialisation du service Dashboard
    dashboardService = DashboardService(repository: dashboardRepository);

    // Initialisation du module Roles et Permissions
    roleRepository = RoleRepositoryImpl(dioClient, sharedPrefs);
    roleService = RoleService(roleRepository: roleRepository);

    // Initialisation du service d'upload
    uploadService = UploadService(dioClient);

    connectivityState = ConnectivityState(
      connectivityService: connectivityService,
    );
    syncState = SyncState(
      syncService: syncService,
      connectivityState: connectivityState,
    );

    exerciceState = ExerciceState(exerciceService);
    atelierState = AtelierState(atelierService);
    annotationState = AnnotationState(annotationService);

    // Injection du service de synchronisation dans les repositories
    academicienRepository.setSyncService(syncService);
    academicienRepository.setDioClient(dioClient);
    encadreurRepoImpl.setSyncService(syncService);
    encadreurRepoImpl.setDioClient(dioClient);
    presenceRepository.setSyncService(syncService);
    presenceRepository.setDioClient(dioClient);
    seanceRepository.setSyncService(syncService);
    seanceRepository.setDioClient(dioClient);
    atelierRepository.setSyncService(syncService);
    atelierRepository.setDioClient(dioClient);
    exerciceRepository.setSyncService(syncService);
    exerciceRepository.setDioClient(dioClient);
    annotationRepository.setSyncService(syncService);
    annotationRepository.setDioClient(dioClient);
    bulletinRepository.setSyncService(syncService);
    bulletinRepository.setDioClient(dioClient);
    smsRepository.setSyncService(syncService);
    smsRepository.setDioClient(dioClient);
    niveauRepository.setSyncService(syncService);
    niveauRepository.setDioClient(dioClient);
    posteRepository.setSyncService(syncService);
    posteRepository.setDioClient(dioClient);
  }

  /// Gere les erreurs de conflit (409) en supprimant l'enregistrement local.
  /// Principalement pour les encadreurs (email duplique) et academiciens (telephone duplique).
  static Future<void> _handleConflictError(
    SyncEntityType entityType,
    String entityId,
  ) async {
    try {
      switch (entityType) {
        case SyncEntityType.encadreur:
          await encadreurRepository.delete(entityId);
          break;
        case SyncEntityType.academicien:
          await academicienRepository.delete(entityId);
          break;
        case SyncEntityType.seance:
          await seanceRepository.delete(entityId);
          break;
        case SyncEntityType.atelier:
          await atelierRepository.delete(entityId);
          break;
        case SyncEntityType.exercice:
          await exerciceRepository.delete(entityId);
          break;
        case SyncEntityType.annotation:
          await annotationRepository.delete(entityId);
          break;
        case SyncEntityType.bulletin:
          await bulletinRepository.delete(entityId);
          break;
        case SyncEntityType.smsMessage:
          await smsRepository.delete(entityId);
          break;
        default:
          // Les autres types n'ont pas de methode delete ou ne sont pas concernes
          break;
      }
      // ignore: avoid_print
      print(
        '[DI] Conflit 409: suppression locale de ${entityType.name}/$entityId',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur suppression locale apres conflit: $e');
    }
  }

  /// Synchronise les referentiels (postes et niveaux) depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  /// Retourne true si la synchronisation a reussi.
  static Future<bool> syncReferentiels() async {
    try {
      final postesOk =
          await (referentielService.posteRepository
                  as PosteFootballRepositoryImpl)
              .syncFromApi();
      final niveauxOk =
          await (referentielService.niveauRepository
                  as NiveauScolaireRepositoryImpl)
              .syncFromApi();
      return postesOk && niveauxOk;
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync referentiels: $e');
      return false;
    }
  }

  /// Synchronise uniquement les postes de football depuis le backend.
  static Future<bool> syncPostesFootball() async {
    try {
      return await (referentielService.posteRepository
              as PosteFootballRepositoryImpl)
          .syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync postes: $e');
      return false;
    }
  }

  /// Synchronise uniquement les niveaux scolaires depuis le backend.
  static Future<bool> syncNiveauxScolaires() async {
    try {
      return await (referentielService.niveauRepository
              as NiveauScolaireRepositoryImpl)
          .syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync niveaux: $e');
      return false;
    }
  }

  /// Synchronise les academiciens depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  static Future<bool> syncAcademiciens() async {
    try {
      return await academicienRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync academiciens: $e');
      return false;
    }
  }

  /// Synchronise les seances depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  static Future<bool> syncSeances() async {
    try {
      return await seanceRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync seances: $e');
      return false;
    }
  }

  /// Synchronise les ateliers depuis le backend.
  static Future<bool> syncAteliers() async {
    try {
      return await atelierRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync ateliers: $e');
      return false;
    }
  }

  /// Synchronise les exercices depuis le backend.
  static Future<bool> syncExercices() async {
    try {
      return await exerciceRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync exercices: $e');
      return false;
    }
  }

  /// Synchronise les annotations depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  static Future<bool> syncAnnotations() async {
    try {
      return await annotationRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync annotations: $e');
      return false;
    }
  }

  /// Synchronise les bulletins depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  static Future<bool> syncBulletins() async {
    try {
      return await bulletinRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync bulletins: $e');
      return false;
    }
  }

  /// Synchronise les presences depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  static Future<bool> syncPresences() async {
    try {
      return await presenceRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync presences: $e');
      return false;
    }
  }

  /// Synchronise les SMS depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  static Future<bool> syncSms() async {
    try {
      return await smsRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync sms: $e');
      return false;
    }
  }

  /// Synchronise les encadreurs depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  static Future<bool> syncEncadreurs() async {
    try {
      return await encadreurRepository.syncFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync encadreurs: $e');
      return false;
    }
  }

  /// Synchronise les preferences de notifications depuis le backend.
  /// Doit etre appelee apres l'authentification reussie.
  static Future<bool> syncNotificationPreferences() async {
    try {
      return await notificationRepository.syncPreferencesFromApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur sync preferences notifications: $e');
      return false;
    }
  }

  /// Envoie les preferences de notifications au backend.
  /// Doit etre appelee apres modification des preferences.
  static Future<bool> pushNotificationPreferences() async {
    try {
      return await notificationRepository.syncPreferencesToApi();
    } catch (e) {
      // ignore: avoid_print
      print('[DI] Erreur envoi preferences notifications: $e');
      return false;
    }
  }

  /// Propage les traductions a tous les services et repositories.
  /// Doit etre appelee depuis un widget ayant acces au [BuildContext].
  static void updateLocalizations(AppLocalizations l10n) {
    seanceService.setLocalizations(l10n);
    atelierService.setLocalizations(l10n);
    exerciceService.setLocalizations(l10n);
    bulletinService.setLocalizations(l10n);
    qrScannerService.setLocalizations(l10n);
    referentielService.setLocalizations(l10n);
    searchService.setLocalizations(l10n);
    syncService.setLocalizations(l10n);
    seanceRepository.setLocalizations(l10n);
    _preferencesRepository.setLocalizations(l10n);
    _seanceDatasource.setLocalizations(l10n);
    _smsDatasource.setLocalizations(l10n);
  }
}
