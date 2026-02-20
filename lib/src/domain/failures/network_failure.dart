/// Énumération des types d'erreurs réseau possibles dans le domaine.
enum NetworkFailureType {
  /// Pas de connexion internet.
  noConnection,

  /// Temps d'attente dépassé.
  timeout,

  /// Erreur côté serveur (5xx).
  serverError,

  /// Erreur d'authentification (401/403).
  unauthorized,

  /// Ressource non trouvée (404).
  notFound,

  /// Erreur inattendue ou inconnue.
  unknown,
}

/// Représente un échec lors d'une requête réseau au niveau du domaine.
class NetworkFailure {
  /// Le type d'erreur.
  final NetworkFailureType type;

  /// Un message descriptif optionnel.
  final String? message;

  /// Code d'erreur optionnel venant du serveur.
  final int? statusCode;

  const NetworkFailure({required this.type, this.message, this.statusCode});

  @override
  String toString() =>
      'NetworkFailure(type: $type, message: $message, statusCode: $statusCode)';
}
