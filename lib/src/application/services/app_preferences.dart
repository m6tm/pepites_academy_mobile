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
  static const String _keyUserPrenom = 'user_prenom';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhoto = 'user_photo';
  static const String _keyToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyAutoLockMinutes = 'auto_lock_minutes';

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
    String? userPrenom,
    String? userEmail,
    String? photoUrl,
  }) async {
    await _repository.setString(_keyUserRole, role);
    await _repository.setString(_keyUserId, userId);
    await _repository.setString(_keyUserName, userName);
    if (userPrenom != null && userPrenom.isNotEmpty) {
      await _repository.setString(_keyUserPrenom, userPrenom);
    }
    if (userEmail != null && userEmail.isNotEmpty) {
      await _repository.setString(_keyUserEmail, userEmail);
    }
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await _repository.setString(_keyUserPhoto, photoUrl);
    }
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

  /// Récupère le prénom de l'utilisateur connecté.
  Future<String?> getUserPrenom() async {
    return _repository.getString(_keyUserPrenom);
  }

  /// Récupère l'email de l'utilisateur connecté.
  Future<String?> getUserEmail() async {
    return _repository.getString(_keyUserEmail);
  }

  /// Récupère le nom complet (prénom + nom) de l'utilisateur connecté.
  Future<String> getUserFullName() async {
    final prenom = await _repository.getString(_keyUserPrenom) ?? '';
    final nom = await _repository.getString(_keyUserName) ?? '';
    return '$prenom $nom'.trim();
  }

  /// Récupère la photo de l'utilisateur connecté.
  Future<String?> getUserPhoto() async {
    return _repository.getString(_keyUserPhoto);
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
  /// Efface toutes les préférences sauf l'état de l'onboarding.
  /// Désactive également l'authentification biométrique.
  Future<void> logout() async {
    final onboardingCompleted = await isOnboardingCompleted();
    await _repository.clear();
    if (onboardingCompleted) {
      await setOnboardingCompleted();
    }
    // Désactiver la biométrie localement pour éviter qu'un autre utilisateur
    // puisse s'authentifier avec les données biométriques de l'ancien utilisateur
    await setBiometricEnabled(false);
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

  // --- Gestion de la sécurité ---

  /// Vérifie si l'authentification biométrique est activée.
  Future<bool> getBiometricEnabled() async {
    final result = await _repository.getBool(_keyBiometricEnabled);
    return result ?? false;
  }

  /// Active ou désactive l'authentification biométrique.
  Future<void> setBiometricEnabled(bool enabled) async {
    await _repository.setBool(_keyBiometricEnabled, enabled);
  }

  /// Récupère le délai de verrouillage automatique en minutes.
  Future<int> getAutoLockMinutes() async {
    final result = await _repository.getInt(_keyAutoLockMinutes);
    return result ?? 5;
  }

  /// Définit le délai de verrouillage automatique en minutes.
  Future<void> setAutoLockMinutes(int minutes) async {
    await _repository.setInt(_keyAutoLockMinutes, minutes);
  }
}
