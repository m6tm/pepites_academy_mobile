import '../failures/network_failure.dart';

/// Interface du depot pour les operations de securite.
abstract class SecurityRepository {
  /// Change le mot de passe de l'utilisateur connecte.
  ///
  /// Retourne un [NetworkFailure] en cas d'erreur, sinon null si succes.
  Future<NetworkFailure?> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Recupere l'historique des modifications de mot de passe.
  ///
  /// Retourne une liste de maps ou un [NetworkFailure].
  Future<(NetworkFailure?, List<Map<String, dynamic>>?)> getPasswordHistory();

  /// Recupere les preferences biometriques de l'utilisateur.
  ///
  /// Retourne une map ou un [NetworkFailure].
  Future<(NetworkFailure?, Map<String, dynamic>?)> getBiometricPreferences();

  /// Met a jour les preferences biometriques.
  ///
  /// Retourne un [NetworkFailure] en cas d'erreur, sinon null si succes.
  Future<NetworkFailure?> updateBiometricPreferences({
    bool? biometricEnabled,
    String? biometricType,
    String? deviceId,
  });

  /// Desactive l'authentification biometrique.
  ///
  /// Retourne un [NetworkFailure] en cas d'erreur, sinon null si succes.
  Future<NetworkFailure?> disableBiometric();

  /// Deconnecte tous les autres appareils.
  ///
  /// Retourne le nombre de sessions revoquees ou un [NetworkFailure].
  Future<(NetworkFailure?, int?)> logoutAllDevices();

  /// Recupere la liste des sessions actives.
  ///
  /// Retourne une liste de maps ou un [NetworkFailure].
  Future<(NetworkFailure?, List<Map<String, dynamic>>?)> getActiveSessions();

  /// Revoque une session specifique.
  ///
  /// Retourne un [NetworkFailure] en cas d'erreur, sinon null si succes.
  Future<NetworkFailure?> revokeSession(String sessionId);
}
