import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../application/services/sync_service.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation du depot Dashboard avec gestion du cache et synchronisation.
///
/// Utilise une strategie cache-first pour optimiser les performances
/// et permettre le fonctionnement hors-ligne.
class DashboardRepositoryImpl implements DashboardRepository {
  final DioClient _dioClient;
  final SharedPreferences _sharedPrefs;

  // Cles de cache
  static const String _keyCachedStats = 'cached_dashboard_stats';
  static const String _keyCachedStatsTimestamp =
      'cached_dashboard_stats_timestamp';
  static const String _keyCurrentSeason = 'current_season';
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  // Cache memoire
  DashboardStats? _cachedStats;
  Season? _cachedSeason;

  // Stream controller pour la reactivite UI
  final StreamController<DashboardStats> _statsController =
      StreamController<DashboardStats>.broadcast();

  // Service de synchronisation (injection optionnelle pour mode hors-ligne)
  SyncService? _syncService;

  DashboardRepositoryImpl(this._dioClient, this._sharedPrefs);

  /// Injecte le service de synchronisation pour le mode hors-ligne.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Stream<DashboardStats> get statsStream => _statsController.stream;

  @override
  Future<(DashboardStats?, NetworkFailure?, bool isFromCache)> getStats({
    bool forceRefresh = false,
  }) async {
    // Verifier si on peut utiliser le cache
    if (!forceRefresh) {
      final cachedStats = await _getCachedStats();
      if (cachedStats != null) {
        // Retourner le cache avec l'indicateur isFromCache = true
        return (cachedStats, null, true);
      }
    }

    // Si pas de cache ou forceRefresh, charger depuis l'API
    try {
      final result = await _dioClient.get<dynamic>(ApiEndpoints.dashboardStats);

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
            final stats = DashboardStats.fromJson(data);
            // Sauvegarder en cache
            _saveStatsToCacheSync(stats);
            _cachedStats = stats;
            _statsController.add(stats);
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
  Future<(Season?, NetworkFailure?)> getCurrentSeason() async {
    // Retourner le cache si disponible
    if (_cachedSeason != null) {
      return (_cachedSeason, null);
    }

    // Charger depuis les preferences
    final seasonJson = _sharedPrefs.getString(_keyCurrentSeason);
    if (seasonJson != null && seasonJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(seasonJson) as Map<String, dynamic>;
        _cachedSeason = Season.fromJson(decoded);
        return (_cachedSeason, null);
      } catch (_) {
        // Ignorer les erreurs de parsing
      }
    }

    // Charger depuis l'API
    try {
      final result = await _dioClient.get<dynamic>(
        '${ApiEndpoints.seasons}/current',
      );

      return result.fold((failure) => (null, failure), (data) {
        if (data is Map<String, dynamic>) {
          final season = Season.fromJson(data);
          _cachedSeason = season;
          // Sauvegarder en cache
          _sharedPrefs.setString(
            _keyCurrentSeason,
            jsonEncode(season.toJson()),
          );
          return (season, null);
        }
        return (null, null);
      });
    } catch (e) {
      return (
        null,
        NetworkFailure(type: NetworkFailureType.unknown, message: e.toString()),
      );
    }
  }

  @override
  Future<NetworkFailure?> openSeason({
    required String name,
    required DateTime startDate,
  }) async {
    // Creer la saison localement d'abord
    final seasonId = 'season_${DateTime.now().millisecondsSinceEpoch}';
    final season = Season(
      id: seasonId,
      name: name,
      startDate: startDate,
      status: SeasonStatus.open,
    );
    _cachedSeason = season;
    _sharedPrefs.setString(_keyCurrentSeason, jsonEncode(season.toJson()));

    // Invalider le cache des stats
    invalidateCache();

    // Enqueuer l'operation de synchronisation
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.season,
      entityId: seasonId,
      operationType: SyncOperationType.create,
      data: {
        'id': seasonId,
        'name': name,
        'start_date': startDate.toIso8601String(),
        'status': 'open',
      },
    );

    // Tenter l'appel API si connecte
    try {
      final result = await _dioClient.post<dynamic>(
        ApiEndpoints.seasons,
        data: {
          'name': name,
          'start_date': startDate.toIso8601String(),
          'status': 'open',
        },
      );

      return result.fold(
        (failure) {
          // En cas d'erreur, l'operation reste dans la file d'attente
          // pour une synchronisation ulterieure
          return failure;
        },
        (data) {
          // Mettre a jour le cache avec la reponse du serveur
          if (data is Map<String, dynamic>) {
            final serverSeason = Season.fromJson(data);
            _cachedSeason = serverSeason;
            _sharedPrefs.setString(
              _keyCurrentSeason,
              jsonEncode(serverSeason.toJson()),
            );
          }
          return null;
        },
      );
    } catch (e) {
      // L'operation reste dans la file d'attente pour synchronisation ulterieure
      return NetworkFailure(
        type: NetworkFailureType.unknown,
        message: e.toString(),
      );
    }
  }

  @override
  Future<NetworkFailure?> closeSeason({
    required String seasonId,
    required DateTime endDate,
  }) async {
    // Mettre a jour le cache local d'abord
    if (_cachedSeason != null && _cachedSeason!.id == seasonId) {
      _cachedSeason = Season(
        id: _cachedSeason!.id,
        name: _cachedSeason!.name,
        startDate: _cachedSeason!.startDate,
        endDate: endDate,
        status: SeasonStatus.closed,
      );
      _sharedPrefs.setString(
        _keyCurrentSeason,
        jsonEncode(_cachedSeason!.toJson()),
      );
    }

    // Invalider le cache des stats
    invalidateCache();

    // Enqueuer l'operation de synchronisation
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.season,
      entityId: seasonId,
      operationType: SyncOperationType.update,
      data: {
        'id': seasonId,
        'end_date': endDate.toIso8601String(),
        'status': 'closed',
      },
    );

    // Tenter l'appel API si connecte
    try {
      final result = await _dioClient.put<dynamic>(
        '${ApiEndpoints.seasons}/$seasonId/close',
        data: {'end_date': endDate.toIso8601String()},
      );

      return result.fold(
        (failure) {
          // En cas d'erreur, l'operation reste dans la file d'attente
          return failure;
        },
        (_) {
          return null;
        },
      );
    } catch (e) {
      // L'operation reste dans la file d'attente pour synchronisation ulterieure
      return NetworkFailure(
        type: NetworkFailureType.unknown,
        message: e.toString(),
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
  DashboardStats? getCachedStatsSync() {
    // Retourner le cache memoire si disponible
    if (_cachedStats != null) {
      return _cachedStats;
    }

    // Charger depuis les preferences
    return _loadStatsFromPrefsSync();
  }

  @override
  Future<void> saveStatsToCache(DashboardStats stats) async {
    _cachedStats = stats;
    _saveStatsToCacheSync(stats);
    _statsController.add(stats);
  }

  /// Recupere les statistiques en cache si disponibles et valides.
  Future<DashboardStats?> _getCachedStats() async {
    // Verifier d'abord le cache memoire
    if (_cachedStats != null) {
      return _cachedStats;
    }

    // Verifier le cache persistant
    final cachedJson = _sharedPrefs.getString(_keyCachedStats);
    if (cachedJson == null || cachedJson.isEmpty) {
      return null;
    }

    // Verifier si le cache est expire
    final timestampStr = _sharedPrefs.getString(_keyCachedStatsTimestamp);
    if (timestampStr != null) {
      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp != null) {
        final now = DateTime.now();
        if (now.difference(timestamp) > _cacheValidityDuration) {
          return null; // Cache expire
        }
      }
    }

    try {
      final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
      _cachedStats = DashboardStats.fromJson(decoded);
      return _cachedStats;
    } catch (_) {
      return null;
    }
  }

  /// Sauvegarde les statistiques en cache de maniere synchrone.
  void _saveStatsToCacheSync(DashboardStats stats) {
    _sharedPrefs.setString(_keyCachedStats, jsonEncode(stats.toJson()));
    _sharedPrefs.setString(
      _keyCachedStatsTimestamp,
      DateTime.now().toIso8601String(),
    );
  }

  /// Charge les statistiques depuis les preferences de maniere synchrone.
  DashboardStats? _loadStatsFromPrefsSync() {
    final cachedJson = _sharedPrefs.getString(_keyCachedStats);
    if (cachedJson == null || cachedJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
      return DashboardStats.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Libere les ressources.
  void dispose() {
    _statsController.close();
  }
}
