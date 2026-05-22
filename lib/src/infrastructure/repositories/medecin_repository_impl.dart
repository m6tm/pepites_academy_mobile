import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../domain/entities/medecin_dashboard_stats.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/medecin_repository.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/exceptions/network_exception.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation du depot Medecin avec gestion du cache.
class MedecinRepositoryImpl implements MedecinRepository {
  final DioClient _dioClient;

  final RepositoryCache<MedecinDashboardStats> _cache =
      RepositoryCache<MedecinDashboardStats>();
  ConnectivityGuard? _connectivityGuard;

  MedecinRepositoryImpl(this._dioClient);

  @override
  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  @override
  Future<(MedecinDashboardStats?, NetworkFailure?, bool isFromCache)> getStats({
    bool forceRefresh = false,
  }) async {
    const key = 'medecin_stats';

    if (!forceRefresh) {
      final cached = _cache.get(key);
      if (cached != null) {
        return (cached, null, true);
      }
    }

    if (_connectivityGuard != null && !await _connectivityGuard!.isOnline) {
      final stale = _cache.getStale(key);
      if (stale != null) return (stale, null, true);
      throw const OfflineException();
    }

    try {
      final result = await _dioClient.get<dynamic>(ApiEndpoints.dashboardMedecinStats);

      return result.fold(
        (failure) {
          final stale = _cache.getStale(key);
          if (stale != null) {
            return (stale, failure, true);
          }
          return (null, failure, false);
        },
        (data) {
          if (data is Map<String, dynamic>) {
            final stats = MedecinDashboardStats.fromJson(data);
            _cache.set(
              key,
              stats,
              ttl: CacheTtl.dashboardStats,
              tags: {'medecin', 'dashboard'},
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
      final stale = _cache.getStale(key);
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
  Future<void> invalidateCache() async {
    _cache.invalidateByTag('medecin');
  }
}
