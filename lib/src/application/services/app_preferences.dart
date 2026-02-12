import '../../domain/repositories/preferences_repository.dart';

/// Service applicatif regroupant les clés de préférences et la logique métier associée.
/// Offre une couche d'abstraction supplémentaire au-dessus du repository.
class AppPreferences {
  final PreferencesRepository _repository;

  // Clés statiques pour éviter les erreurs de frappe
  static const String _keyOnboardingCompleted = 'is_onboarding_completed';

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
}
