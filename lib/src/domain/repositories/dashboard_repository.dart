import '../entities/dashboard_stats.dart';
import '../failures/network_failure.dart';

/// Interface du depot pour les operations liees au dashboard.
///
/// Ce depot gere la recuperation des statistiques globales et
/// la gestion des saisons pour le dashboard SupAdmin.
abstract class DashboardRepository {
  /// Recupere les statistiques completes du dashboard.
  ///
  /// Si [forceRefresh] est true, ignore le cache et force l'appel API.
  /// Retourne un tuple (statistiques, erreur, isFromCache).
  Future<(DashboardStats?, NetworkFailure?, bool isFromCache)> getStats({
    bool forceRefresh = false,
  });

  /// Recupere la saison en cours.
  ///
  /// Retourne null si aucune saison n'est active.
  Future<(Season?, NetworkFailure?)> getCurrentSeason();

  /// Ouvre une nouvelle saison.
  ///
  /// Necessite la permission `season:manage`.
  /// Retourne une [NetworkFailure] en cas d'erreur, ou null si succes.
  Future<NetworkFailure?> openSeason({
    required String name,
    required DateTime startDate,
  });

  /// Ferme la saison en cours.
  ///
  /// Necessite la permission `season:manage`.
  /// Retourne une [NetworkFailure] en cas d'erreur, ou null si succes.
  Future<NetworkFailure?> closeSeason({
    required String seasonId,
    required DateTime endDate,
  });

  /// Invalide le cache des statistiques.
  ///
  /// Appele automatiquement lors des mutations (nouvelle seance, presence, etc.).
  Future<void> invalidateCache();

  /// Recupere les statistiques en cache de maniere synchrone.
  ///
  /// Retourne null si le cache n'existe pas ou est expire.
  DashboardStats? getCachedStatsSync();

  /// Sauvegarde les statistiques en cache local.
  ///
  /// Utilise pour le mode hors-ligne.
  Future<void> saveStatsToCache(DashboardStats stats);

  /// Stream des statistiques pour la reactivite UI.
  ///
  /// Emet de nouvelles valeurs lors des mises a jour.
  Stream<DashboardStats> get statsStream;
}
