import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/security_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation du depot de securite utilisant l'API.
class SecurityRepositoryImpl implements SecurityRepository {
  final DioClient _dioClient;

  SecurityRepositoryImpl(this._dioClient);

  @override
  Future<NetworkFailure?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final result = await _dioClient.post(
      ApiEndpoints.changePassword,
      data: {
        'ancien_mot_de_passe': oldPassword,
        'nouveau_mot_de_passe': newPassword,
      },
    );

    return result.fold((failure) => failure, (_) => null);
  }

  @override
  Future<(NetworkFailure?, List<Map<String, dynamic>>?)>
  getPasswordHistory() async {
    final result = await _dioClient.get(ApiEndpoints.passwordHistory);

    return result.fold((failure) => (failure, null), (data) {
      if (data is Map<String, dynamic> && data['historique'] is List) {
        final historique = (data['historique'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return (null, historique);
      }
      return (null, <Map<String, dynamic>>[]);
    });
  }

  @override
  Future<(NetworkFailure?, Map<String, dynamic>?)>
  getBiometricPreferences() async {
    final result = await _dioClient.get(ApiEndpoints.biometric);

    return result.fold((failure) => (failure, null), (data) {
      if (data is Map<String, dynamic>) {
        return (null, data);
      }
      return (null, null);
    });
  }

  @override
  Future<NetworkFailure?> updateBiometricPreferences({
    bool? biometricEnabled,
    String? biometricType,
    String? deviceId,
  }) async {
    final data = <String, dynamic>{};
    if (biometricEnabled != null) {
      data['biometric_enabled'] = biometricEnabled;
    }
    if (biometricType != null) {
      data['biometric_type'] = biometricType;
    }
    if (deviceId != null) {
      data['device_id'] = deviceId;
    }

    final result = await _dioClient.post(ApiEndpoints.biometric, data: data);

    return result.fold((failure) => failure, (_) => null);
  }

  @override
  Future<NetworkFailure?> disableBiometric() async {
    final result = await _dioClient.delete(ApiEndpoints.biometric);

    return result.fold((failure) => failure, (_) => null);
  }

  @override
  Future<(NetworkFailure?, int?)> logoutAllDevices() async {
    final result = await _dioClient.post(ApiEndpoints.logoutAllDevices);

    return result.fold((failure) => (failure, null), (data) {
      if (data is Map<String, dynamic>) {
        final count = data['sessions_revoquees'] as int?;
        return (null, count ?? 0);
      }
      return (null, 0);
    });
  }

  @override
  Future<(NetworkFailure?, List<Map<String, dynamic>>?)>
  getActiveSessions() async {
    final result = await _dioClient.get(ApiEndpoints.sessions);

    return result.fold((failure) => (failure, null), (data) {
      if (data is Map<String, dynamic> && data['sessions'] is List) {
        final sessions = (data['sessions'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return (null, sessions);
      }
      return (null, <Map<String, dynamic>>[]);
    });
  }

  @override
  Future<NetworkFailure?> revokeSession(String sessionId) async {
    final result = await _dioClient.delete(
      '${ApiEndpoints.sessions}/$sessionId',
    );

    return result.fold((failure) => failure, (_) => null);
  }
}
