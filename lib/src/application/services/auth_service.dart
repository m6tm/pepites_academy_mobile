import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/auth_repository.dart';

/// Service gérant la logique métier liée à l'authentification.
class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

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
  Future<NetworkFailure?> login({
    required String email,
    required String password,
  }) {
    return _authRepository.login(email: email, password: password);
  }

  /// Déconnecte l'utilisateur.
  Future<void> logout() {
    return _authRepository.logout();
  }
}
