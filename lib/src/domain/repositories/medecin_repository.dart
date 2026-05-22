import '../entities/medecin_dashboard_stats.dart';
import '../failures/network_failure.dart';
import '../../core/network/connectivity_guard.dart';

/// Interface du depot pour les operations liees au medecin.
abstract class MedecinRepository {
  /// Recupere les statistiques du dashboard medecin.
  ///
  /// Retourne un tuple (statistiques, erreur, isFromCache).
  Future<(MedecinDashboardStats?, NetworkFailure?, bool isFromCache)> getStats({
    bool forceRefresh = false,
  });

  /// Invalide le cache des statistiques.
  Future<void> invalidateCache();

  /// Injecte le garde de connectivite pour le fallback offline.
  void setConnectivityGuard(ConnectivityGuard guard);
}
