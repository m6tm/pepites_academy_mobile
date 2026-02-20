import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implémentation du dépôt d'authentification utilisant l'API.
class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  @override
  Future<NetworkFailure?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final result = await _dioClient.post(
      ApiEndpoints.register,
      data: {
        'prenom': firstName,
        'nom': lastName,
        'email': email,
        'mot_de_passe': password,
      },
    );

    return result.fold((failure) => failure, (_) => null);
  }

  @override
  Future<NetworkFailure?> login({
    required String email,
    required String password,
  }) async {
    final result = await _dioClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'mot_de_passe': password},
    );

    return result.fold((failure) => failure, (data) {
      // TODO: Gérer le token et les infos utilisateur
      return null;
    });
  }

  @override
  Future<void> logout() async {
    // TODO: Effacer le token localement
  }

  @override
  Future<NetworkFailure?> forgotPassword(String email) async {
    final result = await _dioClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );

    return result.fold((failure) => failure, (_) => null);
  }

  @override
  Future<NetworkFailure?> verifyOtp(String email, String code) async {
    final result = await _dioClient.post(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'code': code},
    );

    return result.fold((failure) => failure, (data) {
      // Le backend renvoie access_token et refresh_token
      final accessToken = data['access_token'] as String?;
      if (accessToken != null) {
        // On configure temporairement le token pour la requête de reset
        // Dans une vraie app, on utiliserait un intercepteur
        _dioClient.setToken(accessToken);
      }
      return null;
    });
  }

  @override
  Future<NetworkFailure?> resetPassword(String newPassword) async {
    final result = await _dioClient.post(
      ApiEndpoints.resetPassword,
      data: {'nouveau_mot_de_passe': newPassword},
    );

    // Après le reset, on peut effacer le token car le backend révoque tout
    _dioClient.setToken(null);

    return result.fold((failure) => failure, (_) => null);
  }
}
