import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/medecin_dashboard_stats.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/medecin_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation du depot Medecin avec gestion du cache.
class MedecinRepositoryImpl implements MedecinRepository {
  final DioClient _dioClient;
  final SharedPreferences _sharedPrefs;

  // Cles de cache
  static const String _keyCachedStats = 'cached_medecin_dashboard_stats';
  static const String _keyCachedStatsTimestamp = 'cached_medecin_dashboard_stats_timestamp';
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  // Cache memoire
  MedecinDashboardStats? _cachedStats;

  MedecinRepositoryImpl(this._dioClient, this._sharedPrefs);

  @override
  Future<(MedecinDashboardStats?, NetworkFailure?, bool isFromCache)> getStats({
    bool forceRefresh = false,
  }) async {
    // Verifier si on peut utiliser le cache
    if (!forceRefresh) {
      final cachedStats = await _getCachedStats();
      if (cachedStats != null) {
        return (cachedStats, null, true);
      }
    }

    // Charger depuis l'API
    try {
      final result = await _dioClient.get<dynamic>(ApiEndpoints.dashboardMedecinStats);

      return result.fold(
        (failure) {
          // En cas d'erreur, tenter de retourner le cache meme expire
          final fallbackCache = _cachedStats ?? _loadStatsFromPrefsSync();
          if (fallbackCache != null) {
            return (fallbackCache, failure, true);
          }
          return (null, failure, false);
        },
        (data) {
          if (data is Map<String, dynamic>) {
            final stats = MedecinDashboardStats.fromJson(data);
            // Sauvegarder en cache
            _saveStatsToCacheSync(stats);
            _cachedStats = stats;
            return (stats, null, false);
          }
          return (
            null,
            const NetworkFailure(
              type: NetworkFailureType.serverError,
              message: 'Format de reponse invalide',
            ),
            false,
          );
        },
      );
    } catch (e) {
      // En cas d'exception, tenter de retourner le cache
      final fallbackCache = _cachedStats ?? _loadStatsFromPrefsSync();
      if (fallbackCache != null) {
        return (
          fallbackCache,
          NetworkFailure(
            type: NetworkFailureType.unknown,
            message: e.toString(),
          ),
          true,
        );
      }
      return (
        null,
        NetworkFailure(type: NetworkFailureType.unknown, message: e.toString()),
        false,
      );
    }
  }

  @override
  Future<void> invalidateCache() async {
    _cachedStats = null;
    await _sharedPrefs.remove(_keyCachedStats);
    await _sharedPrefs.remove(_keyCachedStatsTimestamp);
  }

  @override
  Future<void> saveStatsToCache(MedecinDashboardStats stats) async {
    _cachedStats = stats;
    _saveStatsToCacheSync(stats);
  }

  /// Recupere les statistiques en cache si disponibles et valides.
  Future<MedecinDashboardStats?> _getCachedStats() async {
    if (_cachedStats != null) return _cachedStats;

    final cachedJson = _sharedPrefs.getString(_keyCachedStats);
    if (cachedJson == null || cachedJson.isEmpty) return null;

    final timestampStr = _sharedPrefs.getString(_keyCachedStatsTimestamp);
    if (timestampStr != null) {
      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp != null) {
        final now = DateTime.now();
        if (now.difference(timestamp) > _cacheValidityDuration) return null;
      }
    }

    try {
      final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
      _cachedStats = MedecinDashboardStats.fromJson(decoded);
      return _cachedStats;
    } catch (_) {
      return null;
    }
  }

  /// Sauvegarde les statistiques en cache de maniere synchrone.
  void _saveStatsToCacheSync(MedecinDashboardStats stats) {
    _sharedPrefs.setString(_keyCachedStats, jsonEncode(stats.toJson()));
    _sharedPrefs.setString(
      _keyCachedStatsTimestamp,
      DateTime.now().toIso8601String(),
    );
  }

  /// Charge les statistiques depuis les preferences de maniere synchrone.
  MedecinDashboardStats? _loadStatsFromPrefsSync() {
    final cachedJson = _sharedPrefs.getString(_keyCachedStats);
    if (cachedJson == null || cachedJson.isEmpty) return null;

    try {
      final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
      return MedecinDashboardStats.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
