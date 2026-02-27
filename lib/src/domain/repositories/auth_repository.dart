import '../failures/network_failure.dart';

/// Interface du depot pour les operations d'authentification.
abstract class AuthRepository {
  /// Inscrit un nouvel utilisateur.
  ///
  /// Retourne un [NetworkFailure] en cas d'erreur, sinon null si succes.
  Future<NetworkFailure?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  /// Connecte un utilisateur.
  ///
  /// [deviceType] Type d'appareil (smartphone_android, smartphone_ios, etc.).
  /// [deviceName] Nom de l'appareil.
  /// [model] Modele de l'appareil.
  /// [location] Localisation de l'appareil.
  Future<NetworkFailure?> login({
    required String email,
    required String password,
    String? deviceType,
    String? deviceName,
    String? model,
    String? location,
  });

  /// Deconnecte l'utilisateur actuel.
  Future<void> logout();

  /// Envoie un code OTP a l'adresse e-mail pour la reinitialisation du mot de passe.
  Future<NetworkFailure?> forgotPassword(String email);

  /// Verifie le code OTP envoye par e-mail.
  Future<NetworkFailure?> verifyOtp(String email, String code);

  /// Definit un nouveau mot de passe.
  Future<NetworkFailure?> resetPassword(String newPassword);
}
