import '../../domain/entities/dashboard_stats.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Service applicatif pour la gestion du dashboard SupAdmin.
///
/// Ce service orchestre les operations liees au dashboard en utilisant
/// le [DashboardRepository] pour l'acces aux donnees et la gestion du cache.
class DashboardService {
  final DashboardRepository _repository;

  DashboardService({required DashboardRepository repository})
    : _repository = repository;

  /// Recupere les statistiques completes du dashboard.
  Future<(DashboardStats?, NetworkFailure?, bool isFromCache)> getStats({
    bool forceRefresh = false,
  }) async {
    return _repository.getStats(forceRefresh: forceRefresh);
  }

  /// Recupere la saison en cours.
  Future<(Season?, NetworkFailure?)> getCurrentSeason() async {
    return _repository.getCurrentSeason();
  }

  /// Ouvre une nouvelle saison.
  Future<NetworkFailure?> openSeason({
    required String name,
    required DateTime startDate,
  }) async {
    return _repository.openSeason(name: name, startDate: startDate);
  }

  /// Ferme la saison en cours.
  Future<NetworkFailure?> closeSeason({
    required String seasonId,
    required DateTime endDate,
  }) async {
    return _repository.closeSeason(seasonId: seasonId, endDate: endDate);
  }

  /// Force le rafraichissement des statistiques.
  Future<(DashboardStats?, NetworkFailure?, bool)> refreshStats() async {
    return _repository.getStats(forceRefresh: true);
  }

  /// Invalide le cache des statistiques.
  Future<void> invalidateCache() async {
    await _repository.invalidateCache();
  }
}
