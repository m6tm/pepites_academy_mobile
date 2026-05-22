import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../application/services/sync_service.dart';
import '../../domain/entities/sync_operation.dart';
import '../../core/events/dashboard_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../domain/entities/chart_stats.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/exceptions/network_exception.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation du depot Dashboard avec gestion du cache et synchronisation.
///
/// Utilise RepositoryCache pour la fraicheur des donnees et SharedPreferences
/// uniquement pour la persistance de la saison courante.
class DashboardRepositoryImpl implements DashboardRepository {
  final DioClient _dioClient;
  final SharedPreferences _sharedPrefs;

  // Cache memoire fraicheur (nouveau systeme)
  final RepositoryCache<DashboardStats> _statsCache = RepositoryCache<DashboardStats>();
  final RepositoryCache<ChartStats> _chartCache = RepositoryCache<ChartStats>();

  // Persistance saison (donnee de configuration, pas de cache de fraicheur)
  static const String _keyCurrentSeason = 'current_season';
  Season? _cachedSeason;

  DomainEventBus? _eventBus;
  ConnectivityGuard? _connectivityGuard;
  SyncService? _syncService;

  DashboardRepositoryImpl(this._dioClient, this._sharedPrefs);

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  @override
  Future<(DashboardStats?, NetworkFailure?, bool isFromCache)> getStats({
    bool forceRefresh = false,
  }) async {
    const key = 'dashboard_stats';

    if (!forceRefresh) {
      final cached = _statsCache.get(key);
      if (cached != null) {
        return (cached, null, true);
      }
    }

    if (_connectivityGuard != null && !await _connectivityGuard!.isOnline) {
      final stale = _statsCache.getStale(key);
      if (stale != null) return (stale, null, true);
      throw const OfflineException();
    }

    try {
      final result = await _dioClient.get<dynamic>(ApiEndpoints.dashboardStats);

      return result.fold(
        (failure) {
          final stale = _statsCache.getStale(key);
          if (stale != null) {
            return (stale, failure, true);
          }
          return (null, failure, false);
        },
        (data) {
          if (data is Map<String, dynamic>) {
            final stats = DashboardStats.fromJson(data);
            _statsCache.set(
              key,
              stats,
              ttl: CacheTtl.dashboardStats,
              tags: {'dashboard', 'stats'},
            );
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
      final stale = _statsCache.getStale(key);
      if (stale != null) {
        return (
          stale,
          NetworkFailure(type: NetworkFailureType.unknown, message: e.toString()),
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
    if (_cachedSeason != null) {
      return (_cachedSeason, null);
    }

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

    try {
      final result = await _dioClient.get<dynamic>(
        '${ApiEndpoints.seasons}/current',
      );

      return result.fold((failure) => (null, failure), (data) {
        if (data is Map<String, dynamic>) {
          final season = Season.fromJson(data);
          _cachedSeason = season;
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
    final seasonId = 'season_${DateTime.now().millisecondsSinceEpoch}';
    final season = Season(
      id: seasonId,
      name: name,
      startDate: startDate,
      status: SeasonStatus.open,
    );
    _cachedSeason = season;
    _sharedPrefs.setString(_keyCurrentSeason, jsonEncode(season.toJson()));

    invalidateCache();
    _eventBus?.emit(const DashboardStatsUpdatedEvent());

    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.season,
      entityId: seasonId,
      operationType: SyncOperationType.create,
      data: {
        'id': seasonId,
        'name': name,
        'start_date':
            '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
        'status': 'open',
      },
    );

    try {
      final result = await _dioClient.post<dynamic>(
        ApiEndpoints.seasons,
        data: {
          'name': name,
          'start_date':
              '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
          'status': 'open',
        },
      );

      return result.fold(
        (failure) => failure,
        (data) {
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

    invalidateCache();
    _eventBus?.emit(const DashboardStatsUpdatedEvent());

    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.season,
      entityId: seasonId,
      operationType: SyncOperationType.update,
      data: {
        'id': seasonId,
        'end_date':
            '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
        'status': 'closed',
      },
    );

    try {
      final result = await _dioClient.put<dynamic>(
        '${ApiEndpoints.seasons}/$seasonId/close',
        data: {
          'end_date':
              '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
        },
      );

      return result.fold((failure) => failure, (_) => null);
    } catch (e) {
      return NetworkFailure(
        type: NetworkFailureType.unknown,
        message: e.toString(),
      );
    }
  }

  @override
  Future<void> invalidateCache() async {
    _statsCache.invalidateByTag('dashboard');
  }

  @override
  Future<void> invalidateChartStatsCache() async {
    _chartCache.invalidateByTag('dashboard_charts');
  }

  @override
  Future<(ChartStats?, NetworkFailure?, bool isFromCache)> getChartStats({
    ChartPeriod period = ChartPeriod.month,
    bool forceRefresh = false,
  }) async {
    final key = 'chart_${period.toApiValue()}';

    if (!forceRefresh) {
      final cached = _chartCache.get(key);
      if (cached != null) {
        return (cached, null, true);
      }
    }

    if (_connectivityGuard != null && !await _connectivityGuard!.isOnline) {
      final stale = _chartCache.getStale(key);
      if (stale != null) return (stale, null, true);
      throw const OfflineException();
    }

    try {
      final result = await _dioClient.get<dynamic>(
        '${ApiEndpoints.dashboardStatsCharts}?period=${period.toApiValue()}',
      );

      return result.fold(
        (failure) {
          final stale = _chartCache.getStale(key);
          if (stale != null) {
            return (stale, failure, true);
          }
          return (null, failure, false);
        },
        (data) {
          if (data is Map<String, dynamic>) {
            final stats = ChartStats.fromJson(data);
            _chartCache.set(
              key,
              stats,
              ttl: CacheTtl.dashboardStats,
              tags: {'dashboard_charts', 'dashboard'},
            );
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
      final stale = _chartCache.getStale(key);
      if (stale != null) {
        return (
          stale,
          NetworkFailure(type: NetworkFailureType.unknown, message: e.toString()),
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
}
