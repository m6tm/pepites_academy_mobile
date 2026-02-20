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

  /// Envoie un code OTP à l'adresse e-mail pour la réinitialisation du mot de passe.
  Future<NetworkFailure?> forgotPassword(String email);

  /// Vérifie le code OTP envoyé par e-mail.
  Future<NetworkFailure?> verifyOtp(String email, String code);

  /// Définit un nouveau mot de passe.
  Future<NetworkFailure?> resetPassword(String newPassword);
}
