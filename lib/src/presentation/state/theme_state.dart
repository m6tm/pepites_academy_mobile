import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State management pour le theme de l'application.
/// Persiste le choix de l'utilisateur via SharedPreferences.
class ThemeState extends ChangeNotifier {
  static const String _prefKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  /// Charge le theme sauvegarde depuis les preferences.
  Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefKey);
    switch (value) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// Change le theme et persiste le choix.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_prefKey, 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString(_prefKey, 'dark');
        break;
      case ThemeMode.system:
        await prefs.setString(_prefKey, 'system');
        break;
    }
  }

  /// Libelle du mode actif.
  String get label {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Systeme';
    }
  }
}
