import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import '../../application/services/app_preferences.dart';

/// Implémentation du dépôt d'authentification utilisant l'API.
class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final AppPreferences _preferences;

  AuthRepositoryImpl(this._dioClient, this._preferences);

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
    String? deviceType,
    String? deviceName,
    String? model,
    String? location,
  }) async {
    final data = <String, dynamic>{
      'email': email,
      'mot_de_passe': password,
      if (deviceType != null) 'device_type': deviceType,
      if (deviceName != null) 'device_name': deviceName,
      if (model != null) 'model': model,
      if (location != null) 'location': location,
    };

    final result = await _dioClient.post(ApiEndpoints.login, data: data);

    return result.fold((failure) => failure, (data) {
      if (data is Map<String, dynamic>) {
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        if (accessToken != null) {
          // Set temporaire dans Dio
          _dioClient.setToken(accessToken);
          // Persistance globale
          _preferences.setToken(accessToken);
        }
        if (refreshToken != null) {
          _preferences.setRefreshToken(refreshToken);
        }

        final encadreur = data['encadreur'] as Map<String, dynamic>?;
        if (encadreur != null) {
          final encadreurId = encadreur['id'] as String? ?? '';
          final role = encadreur['role'] as String? ?? 'encadreur';
          final emailResponse = encadreur['email'] as String? ?? email;
          final nom = encadreur['nom'] as String? ?? '';
          final prenom = encadreur['prenom'] as String? ?? '';
          final photoUrl =
              encadreur['photo_url'] as String? ??
              encadreur['photoUrl'] as String? ??
              '';

          // Utiliser uniquement le nom pour l'affichage dans le header
          String displayName = nom.trim();
          if (displayName.isEmpty) {
            // Si pas de nom, extraire le prenom de l'email (avant @)
            final emailPrefix = emailResponse.split('@').first;
            // Capitaliser la premiere lettre
            displayName = emailPrefix.isNotEmpty
                ? emailPrefix[0].toUpperCase() + emailPrefix.substring(1)
                : emailResponse;
          }

          _preferences.setUserLoggedIn(
            role: role,
            userId: encadreurId,
            userName: displayName,
            userPrenom: prenom,
            photoUrl: photoUrl,
          );
        }
      }
      return null;
    });
  }

  @override
  Future<void> logout() async {
    // Appeler la route de déconnexion du backend pour révoquer la session
    await _dioClient.post(ApiEndpoints.logout, data: {});
    _dioClient.setToken(null);
    await _preferences.logout();
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
