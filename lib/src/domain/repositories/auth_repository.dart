import '../failures/network_failure.dart';

/// Interface du dépôt pour les opérations d'authentification.
abstract class AuthRepository {
  /// Inscrit un nouvel utilisateur.
  ///
  /// Retourne un [NetworkFailure] en cas d'erreur, sinon null si succès.
  Future<NetworkFailure?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  /// Connecte un utilisateur.
  Future<NetworkFailure?> login({
    required String email,
    required String password,
  });

  /// Déconnecte l'utilisateur actuel.
  Future<void> logout();
}
