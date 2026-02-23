import 'package:flutter/material.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/widgets/academy_toast.dart';
import '../../injection_container.dart';

/// Service applicatif regroupant les clés de préférences et la logique métier associée.
/// Offre une couche d'abstraction supplémentaire au-dessus du repository.
class AppPreferences {
  final PreferencesRepository _repository;

  // Clés statiques pour éviter les erreurs de frappe
  static const String _keyOnboardingCompleted = 'is_onboarding_completed';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

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
    required String userId,
    required String userName,
  }) async {
    await _repository.setString(_keyUserRole, role);
    await _repository.setString(_keyUserId, userId);
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

  /// Récupère l'identifiant de l'utilisateur connecté.
  Future<String?> getUserId() async {
    return _repository.getString(_keyUserId);
  }

  /// Récupère le nom de l'utilisateur connecté.
  Future<String?> getUserName() async {
    return _repository.getString(_keyUserName);
  }

  /// Récupère le token d'accès.
  Future<String?> getToken() async {
    return _repository.getString(_keyToken);
  }

  /// Enregistre le token d'accès.
  Future<void> setToken(String token) async {
    await _repository.setString(_keyToken, token);
  }

  /// Récupère le token de rafraîchissement.
  Future<String?> getRefreshToken() async {
    return _repository.getString(_keyRefreshToken);
  }

  /// Enregistre le token de rafraîchissement.
  Future<void> setRefreshToken(String token) async {
    await _repository.setString(_keyRefreshToken, token);
  }

  /// Déconnexion de l'utilisateur.
  Future<void> logout() async {
    await _repository.remove(_keyUserRole);
    await _repository.remove(_keyUserId);
    await _repository.remove(_keyUserName);
    await _repository.remove(_keyToken);
    await _repository.remove(_keyRefreshToken);
  }

  /// Force la déconnexion et renvoie l'utilisateur à la page de connexion.
  Future<void> forceLogout([String? message]) async {
    await logout();

    final context = DependencyInjection.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      if (message != null) {
        AcademyToast.show(
          context,
          title: 'Déconnexion',
          description: message,
          isError: true,
        );
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }
}
