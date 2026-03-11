import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../domain/entities/dashboard_stats.dart';
import '../../../domain/entities/chart_stats.dart';
import '../../../injection_container.dart';
import '../../widgets/global_stats_card.dart';
import '../../widgets/season_management_card.dart';
import '../../widgets/supadmin_module_grid.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/sync_notification_banner.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/stats_chart_widget.dart';

/// Dashboard principal pour le Super Administrateur.
///
/// Cette page assemble tous les composants du dashboard SupAdmin:
/// - Statistiques globales (GlobalStatsCard)
/// - Gestion des saisons (SeasonManagementCard)
/// - Grille des modules (SupAdminModuleGrid)
/// - Graphiques de statistiques (StatsChartWidget)
/// - Vue d'ensemble des KPIs
class SupAdminDashboardPage extends StatefulWidget {
  /// Nom d'utilisateur affiche dans l'en-tete.
  final String userName;

  /// URL de la photo de profil.
  final String? photoUrl;

  /// Callback pour naviguer vers un onglet specifique.
  final ValueChanged<int>? onNavigateToTab;

  /// Callback pour naviguer vers la liste des encadreurs.
  final VoidCallback? onNavigateToEncadreurs;

  /// Callback pour naviguer vers les referentiels.
  final VoidCallback? onNavigateToReferentiels;

  const SupAdminDashboardPage({
    super.key,
    this.userName = 'Super Admin',
    this.photoUrl,
    this.onNavigateToTab,
    this.onNavigateToEncadreurs,
    this.onNavigateToReferentiels,
  });

  @override
  State<SupAdminDashboardPage> createState() => _SupAdminDashboardPageState();
}

class _SupAdminDashboardPageState extends State<SupAdminDashboardPage> {
  /// Statistiques du dashboard.
  DashboardStats? _dashboardStats;

  /// Statistiques pour les graphiques.
  ChartStats? _chartStats;

  /// Indique si les donnees proviennent du cache.
  bool _isFromCache = false;

  /// Indique si le chargement est en cours.
  bool _isLoading = false;

  /// Indique si le chargement des graphiques est en cours.
  bool _isChartLoading = false;

  /// Periode selectionnee pour les graphiques.
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  /// Timer pour le rafraichissement periodique.
  Timer? _refreshTimer;

  /// Intervalle de rafraichissement en secondes.
  static const int _refreshIntervalSeconds = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Charge les donnees initiales (cache puis API).
  Future<void> _loadInitialData() async {
    // Afficher le cache immediatement
    final cachedStats = DependencyInjection.dashboardService
        .getCachedStatsSync();
    if (cachedStats != null && mounted) {
      setState(() {
        _dashboardStats = cachedStats;
        _isFromCache = true;
      });
    }

    // Charger les donnees fraiches
    await _fetchStats();
    await _fetchChartStats();
  }

  /// Demarre le rafraichissement periodique.
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: _refreshIntervalSeconds),
      (_) => _fetchStats(),
    );
  }

  /// Recupere les statistiques depuis le service.
  Future<void> _fetchStats() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final (stats, _, isFromCache) = await DependencyInjection.dashboardService
          .getStats();

      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _isFromCache = isFromCache;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Recupere les statistiques des graphiques.
  Future<void> _fetchChartStats() async {
    if (_isChartLoading) return;

    setState(() => _isChartLoading = true);

    try {
      final (stats, _, _) = await DependencyInjection.dashboardRepository
          .getChartStats(period: _selectedPeriod);

      if (mounted) {
        setState(() {
          _chartStats = stats ?? ChartStats.empty;
          _isChartLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isChartLoading = false);
      }
    }
  }

  /// Rafraichit toutes les donnees.
  Future<void> _refreshAll() async {
    await Future.wait([_fetchStats(), _fetchChartStats()]);
  }

  /// Change la periode des graphiques.
  void _onPeriodChanged(ChartPeriod period) {
    if (period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
    _fetchChartStats();
  }

  /// Retourne le message de salutation selon l'heure.
  String _getGreeting() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return 'Bonjour';

    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Bandeau de synchronisation
            SyncNotificationBanner(
              connectivityState: DependencyInjection.connectivityState,
              syncState: DependencyInjection.syncState,
            ),
            // Contenu principal avec refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshAll,
                color: colorScheme.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // En-tete avec notifications
                    SliverToBoxAdapter(
                      child: ListenableBuilder(
                        listenable: DependencyInjection.notificationState,
                        builder: (context, _) {
                          return DashboardHeader(
                            userName: widget.userName,
                            role: l10n.superAdmin,
                            greeting: _getGreeting(),
                            photoUrl: widget.photoUrl,
                            notificationCount: DependencyInjection
                                .notificationState
                                .nonLuesCount,
                            onNotificationTap: () {
                              // Navigation vers notifications
                            },
                            onProfileTap: () {
                              // Navigation vers profil
                            },
                          );
                        },
                      ),
                    ),
                    // Banniere de bienvenue
                    SliverToBoxAdapter(
                      child: _buildWelcomeBanner(colorScheme, l10n),
                    ),
                    // Statistiques globales
                    SliverToBoxAdapter(
                      child: GlobalStatsCard(
                        stats: _dashboardStats,
                        isFromCache: _isFromCache,
                        isLoading: _isLoading,
                        onRefresh: _fetchStats,
                        connectivityState:
                            DependencyInjection.connectivityState,
                        syncState: DependencyInjection.syncState,
                      ),
                    ),
                    // Gestion des saisons
                    SliverToBoxAdapter(
                      child: SeasonManagementCard(
                        currentSeason: _dashboardStats?.currentSeason,
                        onActionComplete: _refreshAll,
                      ),
                    ),
                    // Vue d'ensemble (KPIs supplementaires)
                    SliverToBoxAdapter(
                      child: SectionTitle(title: l10n.overview),
                    ),
                    SliverToBoxAdapter(child: _buildOverviewGrid(l10n)),
                    // Grille des modules
                    SliverToBoxAdapter(
                      child: SupAdminModuleGrid(
                        onNavigateToAcademy: () =>
                            widget.onNavigateToTab?.call(1),
                        onNavigateToSeances: () =>
                            widget.onNavigateToTab?.call(2),
                        onNavigateToCommunication: () =>
                            widget.onNavigateToTab?.call(3),
                        onNavigateToEncadreurs: widget.onNavigateToEncadreurs,
                        onNavigateToReferentiels:
                            widget.onNavigateToReferentiels,
                      ),
                    ),
                    // Graphiques de statistiques
                    SliverToBoxAdapter(
                      child: SectionTitle(title: l10n.globalStatistics),
                    ),
                    SliverToBoxAdapter(child: _buildChartSection(l10n)),
                    // Espace en bas
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la banniere de bienvenue.
  Widget _buildWelcomeBanner(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF2D1215)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.superAdmin.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pepites Academy',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.manageAcademy,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: colorScheme.primary,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la grille de vue d'ensemble.
  Widget _buildOverviewGrid(AppLocalizations l10n) {
    final stats = _dashboardStats;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
        children: [
          StatCard(
            label: l10n.totalSessions,
            value: stats?.nbSeancesTotal.toString() ?? '-',
            icon: Icons.event_note_rounded,
            color: const Color(0xFF3B82F6),
          ),
          StatCard(
            label: l10n.totalAttendances,
            value: stats?.nbPresencesTotal.toString() ?? '-',
            icon: Icons.how_to_reg_rounded,
            color: const Color(0xFF10B981),
          ),
          StatCard(
            label: l10n.totalAnnotations,
            value: stats?.nbAnnotationsTotal.toString() ?? '-',
            icon: Icons.note_alt_rounded,
            color: const Color(0xFF8B5CF6),
          ),
          StatCard(
            label: l10n.attendanceRate,
            value: '${(stats?.tauxPresenceMoyen ?? 0).toStringAsFixed(0)}%',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  /// Construit la section des graphiques.
  Widget _buildChartSection(AppLocalizations l10n) {
    final chartStats = _chartStats ?? ChartStats.empty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StatsChartWidget(
        stats: chartStats,
        selectedPeriod: _selectedPeriod,
        isLoading: _isChartLoading,
        onRefresh: _fetchChartStats,
        onPeriodChanged: _onPeriodChanged,
      ),
    );
  }
}
