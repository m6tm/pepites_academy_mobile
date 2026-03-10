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
  ///
  /// Si [forceRefresh] est true, ignore le cache et force l'appel API.
  /// Retourne un tuple (statistiques, erreur, isFromCache).
  Future<(DashboardStats?, NetworkFailure?, bool isFromCache)> getStats({
    bool forceRefresh = false,
  }) async {
    return _repository.getStats(forceRefresh: forceRefresh);
  }

  /// Recupere la saison en cours.
  ///
  /// Retourne null si aucune saison n'est active.
  Future<(Season?, NetworkFailure?)> getCurrentSeason() async {
    return _repository.getCurrentSeason();
  }

  /// Ouvre une nouvelle saison.
  ///
  /// Necessite la permission `season:manage`.
  /// Retourne une [NetworkFailure] en cas d'erreur, ou null si succes.
  Future<NetworkFailure?> openSeason({
    required String name,
    required DateTime startDate,
  }) async {
    return _repository.openSeason(name: name, startDate: startDate);
  }

  /// Ferme la saison en cours.
  ///
  /// Necessite la permission `season:manage`.
  /// Retourne une [NetworkFailure] en cas d'erreur, ou null si succes.
  Future<NetworkFailure?> closeSeason({
    required String seasonId,
    required DateTime endDate,
  }) async {
    return _repository.closeSeason(seasonId: seasonId, endDate: endDate);
  }

  /// Force le rafraichissement des statistiques.
  ///
  /// Invalide le cache et recharge les donnees depuis l'API.
  Future<(DashboardStats?, NetworkFailure?, bool)> refreshStats() async {
    return _repository.getStats(forceRefresh: true);
  }

  /// Invalide le cache des statistiques.
  ///
  /// Appele automatiquement lors des mutations (nouvelle seance, presence, etc.).
  Future<void> invalidateCache() async {
    await _repository.invalidateCache();
  }

  /// Recupere les statistiques en cache de maniere synchrone.
  ///
  /// Utile pour l'affichage immediat avant le chargement.
  DashboardStats? getCachedStatsSync() {
    return _repository.getCachedStatsSync();
  }

  /// Stream des statistiques pour la reactivite UI.
  ///
  /// Emet de nouvelles valeurs lors des mises a jour.
  Stream<DashboardStats> get statsStream => _repository.statsStream;

  /// Raccourci vers le nombre d'academiciens.
  int get nbAcademiciens =>
      _repository.getCachedStatsSync()?.nbAcademiciens ?? 0;

  /// Raccourci vers le nombre d'encadreurs.
  int get nbEncadreurs => _repository.getCachedStatsSync()?.nbEncadreurs ?? 0;

  /// Raccourci vers le nombre de seances du jour.
  int get nbSeancesJour => _repository.getCachedStatsSync()?.nbSeancesJour ?? 0;

  /// Raccourci vers le nombre de presences du jour.
  int get nbPresencesJour =>
      _repository.getCachedStatsSync()?.nbPresencesJour ?? 0;

  /// Indique si une saison est actuellement ouverte.
  bool get hasActiveSeason =>
      _repository.getCachedStatsSync()?.hasActiveSeason ?? false;
}
