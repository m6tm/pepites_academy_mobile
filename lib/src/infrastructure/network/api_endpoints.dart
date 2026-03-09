/// Classe contenant les constantes relatives aux points de terminaison de l'API.
class ApiEndpoints {
  /// URL de base du serveur.
  /// À modifier en fonction de l'environnement (Dev, Staging, Prod).
  // Utiliser 10.0.2.2 pour l'émulateur Android, localhost pour iOS ou le Web.
  // static const String baseUrl = 'http://10.0.2.2:5000/v1';
  // static const String baseUrl = 'https://apipepites-academy.vercel.app/v1';
  // static const String baseUrl = 'http://192.168.75.148:5000/v1';
  static const String baseUrl = 'http://192.168.1.119:5000/v1';

  /// Chemin pour la synchronisation des données.
  static const String sync = '/sync';

  /// Chemin pour l'authentification.
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  static const String register = '/auth/register';

  /// Chemins pour la réinitialisation de mot de passe.
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  /// Chemins pour les encadreurs.
  static const String encadreurs = '/encadreurs';

  /// Chemins pour les académiciens.
  static const String academiciens = '/academiciens';

  /// Chemins pour les séances.
  static const String seances = '/seances';

  /// Chemins pour les ateliers.
  static const String ateliers = '/ateliers';
  static const String ateliersReorder = '/ateliers/reorder';

  /// Chemins pour les annotations.
  static const String annotations = '/annotations';

  /// Chemins pour les notifications.
  static const String notifications = '/notifications';

  /// Chemins pour les preferences de notifications.
  static const String notificationPreferences = '/notification-preferences';

  /// Chemins pour les tokens FCM (Firebase Cloud Messaging).
  static const String fcmToken = '/fcm/token';

  /// Chemins pour les présences.
  static const String presences = '/presences';

  /// Chemins pour les bulletins.
  static const String bulletins = '/bulletins';

  /// Chemins pour les référentiels.
  static const String postesFootball = '/referentiels/postes';
  static const String niveauxScolaires = '/referentiels/niveaux';

  /// Chemins pour les SMS.
  static const String sms = '/sms';

  /// Chemin pour la vérification de santé du serveur.
  static const String health = '/health';

  /// Chemins pour la securite.
  static const String security = '/security';
  static const String changePassword = '/security/change-password';
  static const String passwordHistory = '/security/password-history';
  static const String biometric = '/security/biometric';
  static const String logoutAllDevices = '/security/sessions/logout-all';

  /// Chemins pour les sessions.
  static const String sessions = '/sessions';

  /// Chemins pour le dashboard.
  static const String dashboardStats = '/dashboard/stats';

  /// Chemins pour les rôles et permissions.
  static const String roles = '/roles';
  static const String rolePermissions = '/roles/permissions';
  static const String roleUsers = '/roles/users';
  static const String roleStats = '/roles/stats';

  /// Délais d'expiration des requêtes (en millisecondes).
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;
}
