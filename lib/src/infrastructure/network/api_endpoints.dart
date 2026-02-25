/// Classe contenant les constantes relatives aux points de terminaison de l'API.
class ApiEndpoints {
  /// URL de base du serveur.
  /// À modifier en fonction de l'environnement (Dev, Staging, Prod).
  // Utiliser 10.0.2.2 pour l'émulateur Android, localhost pour iOS ou le Web.
  // static const String baseUrl = 'http://10.0.2.2:5000/v1';
  // static const String baseUrl = 'https://apipepites-academy.vercel.app/v1';
  static const String baseUrl = 'http://192.168.223.148:5000/v1';

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

  /// Chemins pour les présences.
  static const String presences = '/presences';

  /// Chemins pour les bulletins.
  static const String bulletins = '/bulletins';

  /// Chemins pour les référentiels.
  static const String postesFootball = '/referentiels/postes';
  static const String niveauxScolaires = '/referentiels/niveaux';

  /// Chemin pour la vérification de santé du serveur.
  static const String health = '/health';

  /// Délais d'expiration des requêtes (en millisecondes).
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;
}
