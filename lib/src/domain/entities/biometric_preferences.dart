/// Entité representant les preferences d'authentification biometrique.
class BiometricPreferences {
  /// Indique si l'authentification biometrique est activee.
  final bool biometricEnabled;

  /// Type de biometrie (fingerprint, face_id, etc.).
  final String? biometricType;

  /// Identifiant unique de l'appareil.
  final String? deviceId;

  const BiometricPreferences({
    this.biometricEnabled = false,
    this.biometricType,
    this.deviceId,
  });

  /// Cree une instance depuis un JSON.
  factory BiometricPreferences.fromJson(Map<String, dynamic> json) {
    return BiometricPreferences(
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      biometricType: json['biometric_type'] as String?,
      deviceId: json['device_id'] as String?,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'biometric_enabled': biometricEnabled,
      'biometric_type': biometricType,
      'device_id': deviceId,
    };
  }

  /// Cree une copie avec les nouvelles valeurs.
  BiometricPreferences copyWith({
    bool? biometricEnabled,
    String? biometricType,
    String? deviceId,
  }) {
    return BiometricPreferences(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricType: biometricType ?? this.biometricType,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
