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
}
