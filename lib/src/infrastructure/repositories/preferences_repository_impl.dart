import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/exceptions/cache_exception.dart';
import '../../domain/repositories/preferences_repository.dart';

/// Implémentation concrète de [PreferencesRepository] utilisant shared_preferences.
/// Gère la robustesse avec des blocs try-catch et le mapping vers les exceptions de domaine.
class PreferencesRepositoryImpl implements PreferencesRepository {
  final SharedPreferences _prefs;

  PreferencesRepositoryImpl(this._prefs);

  @override
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException("Erreur lors de la lecture de la clé '$key' : $e");
    }
  }

  @override
  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException("Erreur lors de l'écriture de la clé '$key' : $e");
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw CacheException(
        "Erreur lors de la suppression de la clé '$key' : $e",
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw CacheException(
        "Erreur lors de la réinitialisation des préférences : $e",
      );
    }
  }
}
