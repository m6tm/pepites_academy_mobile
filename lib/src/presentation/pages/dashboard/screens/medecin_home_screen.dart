import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../../../../injection_container.dart';
import '../../../../domain/entities/medecin_dashboard_stats.dart';
import '../../notification/notifications_page.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/medecin_internal_widgets.dart';

/// Ecran d'accueil du dashboard medecin.
/// Affiche la situation sanitaire globale et les alertes.
class MedecinHomeScreen extends StatefulWidget {
  final String userName;
  final String greeting;
  final String? photoUrl;
  final VoidCallback onProfileTap;

  const MedecinHomeScreen({
    super.key,
    required this.userName,
    required this.greeting,
    required this.onProfileTap,
    this.photoUrl,
  });

  @override
  State<MedecinHomeScreen> createState() => _MedecinHomeScreenState();
}

class _MedecinHomeScreenState extends State<MedecinHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les statistiques au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DependencyInjection.medecinDashboardState.loadStats(forceRefresh: true);
    });

    // Écouter la fin de synchronisation pour rafraîchir les données
    DependencyInjection.syncState.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    DependencyInjection.syncState.removeListener(_onSyncChanged);
    super.dispose();
  }

  void _onSyncChanged() {
    final syncState = DependencyInjection.syncState;
    // Si la synchronisation vient de se terminer avec succès, on rafraîchit les stats
    if (!syncState.isSyncing &&
        syncState.lastSyncResult != null &&
        syncState.lastSyncResult!.successCount > 0) {
      if (mounted) {
        DependencyInjection.medecinDashboardState.refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final dashboardState = DependencyInjection.medecinDashboardState;
    final notificationState = DependencyInjection.notificationState;

    return ListenableBuilder(
      listenable: Listenable.merge([dashboardState, notificationState]),
      builder: (context, _) {
        final stats = dashboardState.stats;

        return RefreshIndicator(
          onRefresh: dashboardState.refresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: DashboardHeader(
                  userName: widget.userName,
                  role: l10n.chiefMedicalOfficer,
                  greeting: widget.greeting,
                  photoUrl: widget.photoUrl,
                  notificationCount: notificationState.nonLuesCount,
                  onNotificationTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(userRole: 'medecin_chef'),
                      ),
                    );
                  },
                  onSyncTap: dashboardState.refresh,
                  onProfileTap: widget.onProfileTap,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildHealthStatusBanner(
                  colorScheme,
                  l10n,
                  stats.tauxAptitude.toInt(),
                ),
              ),
              SliverToBoxAdapter(child: SectionTitle(title: l10n.healthOverview)),
              if (dashboardState.isLoading && stats == MedecinDashboardStats.empty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: MedicalStatCard(
                            label: l10n.academicians,
                            value: stats.nbAcademiciens.toString(),
                            icon: Icons.people_outline_rounded,
                            color: const Color(0xFF3B82F6),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MedicalStatCard(
                            label: l10n.consultations,
                            value: stats.nbConsultations.toString(),
                            icon: Icons.assignment_outlined,
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: MedicalStatCard(
                            label: l10n.activeAlerts,
                            value: stats.nbAlertesActives.toString(),
                            icon: Icons.warning_amber_rounded,
                            color: const Color(0xFFEF4444),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MedicalStatCard(
                            label: l10n.unfitPlayers,
                            value: stats.nbJoueursInaptes.toString(),
                            icon: Icons.health_and_safety_outlined,
                            color: const Color(0xFFF59E0B),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SectionTitle(title: l10n.recentAlerts)),
                if (stats.recentAlerts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Aucune alerte récente',
                          style: GoogleFonts.montserrat(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final alert = stats.recentAlerts[index];
                        return MedicalAlertTile(
                          title: alert.title,
                          description: alert.description,
                          date: alert.date,
                          isUrgent: alert.isUrgent,
                        );
                      },
                      childCount: stats.recentAlerts.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthStatusBanner(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    int aptitudePercentage,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.medicalFollowUp.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  aptitudePercentage >= 90 ? l10n.optimalHealth : 'Suivi Sanitaire Actif',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.fitToTrain(aptitudePercentage),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.healing_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
