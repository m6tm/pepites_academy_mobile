import '../exceptions/cache_exception.dart';

/// Interface définissant le contrat pour la gestion des préférences locales.
/// Suit les principes de l'architecture hexagonale (Port).
abstract class PreferencesRepository {
  /// Récupère une valeur booléenne associée à une clé.
  /// Lève une [CacheException] en cas d'erreur.
  Future<bool?> getBool(String key);

  /// Enregistre une valeur booléenne associée à une clé.
  /// Lève une [CacheException] en cas d'erreur.
  Future<void> setBool(String key, bool value);

  /// Récupère une valeur de type String associée à une clé.
  /// Lève une [CacheException] en cas d'erreur.
  Future<String?> getString(String key);

  /// Enregistre une valeur de type String associée à une clé.
  /// Lève une [CacheException] en cas d'erreur.
  Future<void> setString(String key, String value);

  /// Vérifie si une clé existe dans les préférences.
  Future<bool> containsKey(String key);

  /// Supprime une valeur associée à une clé.
  Future<void> remove(String key);

  /// Vide toutes les préférences.
  Future<void> clear();
}
