import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'sync_service.dart';
import 'cache_manager.dart';

/// Service gerant la logique metier liee a l'authentification.
class AuthService {
  final AuthRepository _authRepository;
  SyncService? _syncService;
  CacheManager? _cacheManager;

  AuthService(this._authRepository);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Injecte le gestionnaire de cache.
  void setCacheManager(CacheManager manager) {
    _cacheManager = manager;
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
  /// Vide egalement tous les caches locaux pour eviter la persistance
  /// des donnees entre differents utilisateurs.
  Future<void> logout() async {
    // 1. Vider tous les caches de donnees metier
    await _cacheManager?.clearAll();

    // 2. Vider la queue de synchronisation
    await _syncService?.clearAll();

    // 3. Deconnecter via le repository (appel API + nettoyage preferences)
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
