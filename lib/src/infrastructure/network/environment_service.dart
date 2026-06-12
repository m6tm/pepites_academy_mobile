import 'package:flutter/foundation.dart';

/// Environnements d'exécution supportés par l'application.
enum AppEnvironment {
  local,
  staging,
  production;

  bool get isLocal => this == local;
  bool get isStaging => this == staging;
  bool get isProduction => this == production;
}

/// Configuration réseau associée à un environnement.
class _NetworkConfig {
  const _NetworkConfig({required this.baseUrl});
  final String baseUrl;
}

/// Service centralisé de résolution de l'environnement et des URLs backend.
///
/// L'environnement est déterminé dans l'ordre suivant :
/// 1. `--dart-define=ENV=xxx` passé au build Flutter.
/// 2. Mode release → [AppEnvironment.production].
/// 3. Fallback → [AppEnvironment.local].
///
/// Valeurs `ENV` acceptées : `local`, `staging`, `production`.
class EnvironmentService {
  EnvironmentService._();

  static const String _envKey = 'ENV';

  static const Map<AppEnvironment, _NetworkConfig> _configs = {
    AppEnvironment.local: _NetworkConfig(
      // Utiliser `String.fromEnvironment('LOCAL_IP')` pour surcharger l'IP locale.
      baseUrl: 'http://192.168.1.237:5500/v1',
    ),
    AppEnvironment.staging: _NetworkConfig(
      baseUrl: 'https://api-staging.pepitesacademy.com/v1',
    ),
    AppEnvironment.production: _NetworkConfig(
      baseUrl: 'https://api.pepitesacademy.com/v1',
    ),
  };

  /// Environnement actuellement actif.
  static AppEnvironment get current {
    const String env = String.fromEnvironment(_envKey);

    if (env.isEmpty) {
      return kReleaseMode ? AppEnvironment.production : AppEnvironment.local;
    }

    return AppEnvironment.values.firstWhere(
      (e) => e.name == env.toLowerCase(),
      orElse: () => AppEnvironment.local,
    );
  }

  /// URL de base du backend pour l'environnement actif.
  static String get baseUrl => _configs[current]!.baseUrl;
}
