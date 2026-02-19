import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/exceptions/cache_exception.dart';
import '../../domain/repositories/preferences_repository.dart';

/// Implémentation concrète de [PreferencesRepository] utilisant shared_preferences.
/// Gère la robustesse avec des blocs try-catch et le mapping vers les exceptions de domaine.
class PreferencesRepositoryImpl implements PreferencesRepository {
  final SharedPreferences _prefs;
  AppLocalizations? _l10n;

  PreferencesRepositoryImpl(this._prefs);

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheReadKey(key, e.toString()) ??
            "Erreur lors de la lecture de la cle '$key' : $e",
      );
    }
  }

  @override
  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheWriteKey(key, e.toString()) ??
            "Erreur lors de l'ecriture de la cle '$key' : $e",
      );
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheReadString(key, e.toString()) ??
            "Erreur lors de la lecture de la chaine '$key' : $e",
      );
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheWriteString(key, e.toString()) ??
            "Erreur lors de l'ecriture de la chaine '$key' : $e",
      );
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
        _l10n?.exceptionCacheDeleteKey(key, e.toString()) ??
            "Erreur lors de la suppression de la cle '$key' : $e",
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheResetPrefs(e.toString()) ??
            "Erreur lors de la reinitialisation des preferences : $e",
      );
    }
  }
}
