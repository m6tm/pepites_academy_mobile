import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/preferences_events.dart';
import '../../domain/exceptions/cache_exception.dart';
import '../../domain/repositories/preferences_repository.dart';

/// Implementation concrete de [PreferencesRepository] utilisant shared_preferences.
class PreferencesRepositoryImpl implements PreferencesRepository {
  final SharedPreferences _prefs;
  AppLocalizations? _l10n;
  DomainEventBus? _eventBus;

  PreferencesRepositoryImpl(this._prefs);

  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  void _emitUpdated() {
    _eventBus?.emit(const PreferencesUpdatedEvent());
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
      _emitUpdated();
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
      _emitUpdated();
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheWriteString(key, e.toString()) ??
            "Erreur lors de l'ecriture de la chaine '$key' : $e",
      );
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheReadKey(key, e.toString()) ??
            "Erreur lors de la lecture de la cle '$key' : $e",
      );
    }
  }

  @override
  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
      _emitUpdated();
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheWriteKey(key, e.toString()) ??
            "Erreur lors de l'ecriture de la cle '$key' : $e",
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
      _emitUpdated();
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
      _emitUpdated();
    } catch (e) {
      throw CacheException(
        _l10n?.exceptionCacheResetPrefs(e.toString()) ??
            "Erreur lors de la reinitialisation des preferences : $e",
      );
    }
  }
}
