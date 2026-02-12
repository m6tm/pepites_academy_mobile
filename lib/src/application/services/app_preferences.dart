import '../../domain/repositories/preferences_repository.dart';

/// Service applicatif regroupant les clés de préférences et la logique métier associée.
/// Offre une couche d'abstraction supplémentaire au-dessus du repository.
class AppPreferences {
  final PreferencesRepository _repository;

  // Clés statiques pour éviter les erreurs de frappe
  static const String _keyOnboardingCompleted = 'is_onboarding_completed';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserName = 'user_name';

  AppPreferences(this._repository);

  /// Vérifie si l'onboarding a été complété.
  Future<bool> isOnboardingCompleted() async {
    final result = await _repository.getBool(_keyOnboardingCompleted);
    return result ?? false;
  }

  /// Marque l'onboarding comme complété.
  Future<void> setOnboardingCompleted() async {
    await _repository.setBool(_keyOnboardingCompleted, true);
  }

  /// Réinitialise l'état de l'onboarding (utile pour le debug/test).
  Future<void> resetOnboarding() async {
    await _repository.remove(_keyOnboardingCompleted);
  }

  // --- Gestion de la session utilisateur ---

  /// Enregistre les informations de l'utilisateur connecté.
  Future<void> setUserLoggedIn({
    required String role,
    required String userName,
  }) async {
    await _repository.setString(_keyUserRole, role);
    await _repository.setString(_keyUserName, userName);
  }

  /// Vérifie si un utilisateur est connecté.
  Future<bool> isUserLoggedIn() async {
    final role = await _repository.getString(_keyUserRole);
    return role != null && role.isNotEmpty;
  }

  /// Récupère le rôle de l'utilisateur connecté.
  Future<String?> getUserRole() async {
    return _repository.getString(_keyUserRole);
  }

  /// Récupère le nom de l'utilisateur connecté.
  Future<String?> getUserName() async {
    return _repository.getString(_keyUserName);
  }

  /// Déconnexion de l'utilisateur.
  Future<void> logout() async {
    await _repository.remove(_keyUserRole);
    await _repository.remove(_keyUserName);
  }
}
