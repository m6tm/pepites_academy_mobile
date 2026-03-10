import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../../l10n/app_localizations.dart';
import '../state/connectivity_state.dart';
import '../state/sync_state.dart';
import '../theme/app_colors.dart';
import 'connectivity_indicator.dart';

/// Carte affichant les statistiques globales de l'academie.
///
/// Ce widget affiche les KPIs principaux sur le dashboard SupAdmin:
/// - Total academiciens
/// - Total encadreurs
/// - Seances du jour
/// - Presences du jour
///
/// Il integre egalement un indicateur de connectivite et un bouton
/// de rafraichissement avec animation.
class GlobalStatsCard extends StatefulWidget {
  /// Les statistiques du dashboard a afficher.
  final DashboardStats? stats;

  /// Indique si les donnees proviennent du cache.
  final bool isFromCache;

  /// Indique si le chargement est en cours.
  final bool isLoading;

  /// Callback appele lors du rafraichissement.
  final VoidCallback? onRefresh;

  /// Etat de connectivite pour l'indicateur.
  final ConnectivityState connectivityState;

  /// Etat de synchronisation pour l'indicateur.
  final SyncState syncState;

  const GlobalStatsCard({
    super.key,
    this.stats,
    this.isFromCache = false,
    this.isLoading = false,
    this.onRefresh,
    required this.connectivityState,
    required this.syncState,
  });

  @override
  State<GlobalStatsCard> createState() => _GlobalStatsCardState();
}

class _GlobalStatsCardState extends State<GlobalStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    if (widget.isLoading) return;
    _refreshController.forward(from: 0);
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final stats = widget.stats;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tete avec titre, indicateur connectivite et bouton refresh
          _buildHeader(context, l10n, isDark),
          const SizedBox(height: 20),
          // Grille des KPIs
          _buildKpiGrid(context, l10n, stats, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.globalOverview,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              // Badge hors-ligne si donnees en cache
              if (widget.isFromCache)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.statusOffline,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Indicateur de connectivite compact
        ConnectivityIndicator(
          connectivityState: widget.connectivityState,
          syncState: widget.syncState,
          compact: true,
        ),
        const SizedBox(width: 12),
        // Bouton de rafraichissement
        _buildRefreshButton(isDark),
      ],
    );
  }

  Widget _buildRefreshButton(bool isDark) {
    return GestureDetector(
      onTap: widget.isLoading ? null : _handleRefresh,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: widget.isLoading
            ? AnimatedBuilder(
                animation: _spinAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinAnimation.value * 2 * 3.14159,
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  );
                },
              )
            : Icon(Icons.refresh_rounded, size: 20, color: AppColors.primary),
      ),
    );
  }

  Widget _buildKpiGrid(
    BuildContext context,
    AppLocalizations l10n,
    DashboardStats? stats,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiItem(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFF3B82F6),
            label: l10n.academicians,
            value: stats?.nbAcademiciens.toString() ?? '-',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiItem(
            icon: Icons.sports_rounded,
            iconColor: const Color(0xFF8B5CF6),
            label: l10n.coaches,
            value: stats?.nbEncadreurs.toString() ?? '-',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiItem(
            icon: Icons.today_rounded,
            iconColor: AppColors.primary,
            label: l10n.sessionsToday,
            value: stats?.nbSeancesJour.toString() ?? '-',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiItem(
            icon: Icons.how_to_reg_rounded,
            iconColor: const Color(0xFF10B981),
            label: l10n.attendancesToday,
            value: stats?.nbPresencesJour.toString() ?? '-',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
