import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'sync_service.dart';

/// Service gerant la logique metier liee a l'authentification.
class AuthService {
  final AuthRepository _authRepository;
  SyncService? _syncService;

  AuthService(this._authRepository);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Inscrit un nouvel utilisateur.
  Future<NetworkFailure?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return _authRepository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }

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
  }) {
    return _authRepository.login(
      email: email,
      password: password,
      deviceType: deviceType,
      deviceName: deviceName,
      model: model,
      location: location,
    );
  }

  /// Deconnecte l'utilisateur et vide la queue de synchronisation.
  Future<void> logout() async {
    await _syncService?.clearAll();
    return _authRepository.logout();
  }

  /// Demande une reinitialisation de mot de passe.
  Future<NetworkFailure?> forgotPassword(String email) {
    return _authRepository.forgotPassword(email);
  }

  /// Verifie le code OTP.
  Future<NetworkFailure?> verifyOtp(String email, String code) {
    return _authRepository.verifyOtp(email, code);
  }

  /// Reinitialise le mot de passe.
  Future<NetworkFailure?> resetPassword(String newPassword) {
    return _authRepository.resetPassword(newPassword);
  }
}
