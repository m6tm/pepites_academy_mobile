import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State management pour la langue de l'application.
/// Persiste le choix de l'utilisateur via SharedPreferences.
class LanguageState extends ChangeNotifier {
  static const String _prefKey = 'app_language';

  /// Langues disponibles dans l'application.
  static const List<LanguageOption> languesDisponibles = [
    LanguageOption(
      code: 'fr',
      label: 'Francais',
      drapeau: '\u{1F1EB}\u{1F1F7}',
      locale: Locale('fr', 'FR'),
    ),
    LanguageOption(
      code: 'en',
      label: 'English',
      drapeau: '\u{1F1EC}\u{1F1E7}',
      locale: Locale('en', 'US'),
    ),
  ];

  Locale _locale = const Locale('fr', 'FR');
  Locale get locale => _locale;

  /// Code de la langue active.
  String get codeLangue => _locale.languageCode;

  /// Libelle de la langue active.
  String get label {
    final option = languesDisponibles.firstWhere(
      (l) => l.code == _locale.languageCode,
      orElse: () => languesDisponibles.first,
    );
    return option.label;
  }

  /// Charge la langue sauvegardee depuis les preferences.
  Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) {
      final option = languesDisponibles.firstWhere(
        (l) => l.code == code,
        orElse: () => languesDisponibles.first,
      );
      _locale = option.locale;
    }
    notifyListeners();
  }

  /// Change la langue et persiste le choix.
  Future<void> setLangue(String code) async {
    final option = languesDisponibles.firstWhere(
      (l) => l.code == code,
      orElse: () => languesDisponibles.first,
    );
    _locale = option.locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }
}

/// Modele representant une option de langue.
class LanguageOption {
  final String code;
  final String label;
  final String drapeau;
  final Locale locale;

  const LanguageOption({
    required this.code,
    required this.label,
    required this.drapeau,
    required this.locale,
  });
}
