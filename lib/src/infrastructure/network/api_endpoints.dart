/// Classe contenant les constantes relatives aux points de terminaison de l'API.
class ApiEndpoints {
  /// URL de base du serveur.
  /// À modifier en fonction de l'environnement (Dev, Staging, Prod).
  static const String baseUrl = 'http://localhost:5000/v1';

  /// Chemin pour la synchronisation des données.
  static const String sync = '/sync';

  /// Chemin pour l'authentification.
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  /// Délais d'expiration des requêtes (en millisecondes).
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;
}
