import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/activity.dart';
import '../../../../presentation/helpers/activity_l10n_helper.dart';
import '../../../../presentation/widgets/activity_card.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../../../../injection_container.dart';
import '../../../../domain/entities/medecin_dashboard_stats.dart';
import '../../../theme/app_colors.dart';
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
  List<Activity> _activites = [];
  bool _activitesLoading = true;

  bool _bilansStatsLoading = true;
  int _totalBilans = 0;
  int _totalMusculaire = 0;
  int _totalArticulaire = 0;
  int _totalTraumatique = 0;

  @override
  void initState() {
    super.initState();
    // Charger les statistiques au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DependencyInjection.medecinDashboardState.loadStats(forceRefresh: true);
      _loadBilanStats();
      _loadActivitesRecentes();
    });

    // Écouter la fin de synchronisation pour rafraîchir les données
    DependencyInjection.syncState.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    DependencyInjection.syncState.removeListener(_onSyncChanged);
    super.dispose();
  }

  /// Charge les statistiques analytiques reelles issues des bilans medicaux.
  Future<void> _loadBilanStats() async {
    try {
      final bilans =
          await DependencyInjection.bilanMedicalMensuelRepository.getAll();
      var totalMusculaire = 0;
      var totalArticulaire = 0;
      var totalTraumatique = 0;
      for (final bilan in bilans) {
        totalMusculaire += bilan.blessuresMusculaire;
        totalArticulaire += bilan.blessuresArticulaire;
        totalTraumatique += bilan.blessuresTraumatique;
      }
      if (mounted) {
        setState(() {
          _totalBilans = bilans.length;
          _totalMusculaire = totalMusculaire;
          _totalArticulaire = totalArticulaire;
          _totalTraumatique = totalTraumatique;
          _bilansStatsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _bilansStatsLoading = false);
      }
    }
  }

  /// Charge les activites recentes depuis le service d'activites.
  Future<void> _loadActivitesRecentes() async {
    try {
      final activites = await DependencyInjection.activityService
          .getActivitesRecentes(limit: 5);
      if (mounted) {
        setState(() {
          _activites = activites;
          _activitesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _activitesLoading = false);
      }
    }
  }

  void _onSyncChanged() {
    final syncState = DependencyInjection.syncState;
    // Si la synchronisation vient de se terminer avec succès, on rafraîchit les stats
    if (!syncState.isSyncing &&
        syncState.lastSyncResult != null &&
        syncState.lastSyncResult!.successCount > 0) {
      if (mounted) {
        DependencyInjection.medecinDashboardState.refresh();
        _loadBilanStats();
        _loadActivitesRecentes();
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
                            label: l10n.medicalOverviewTotalReports,
                            value: _bilansStatsLoading
                                ? '-'
                                : _totalBilans.toString(),
                            icon: Icons.assignment_outlined,
                            color: AppColors.primary,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MedicalStatCard(
                            label: l10n.medicalOverviewMuscleInjuries,
                            value: _bilansStatsLoading
                                ? '-'
                                : _totalMusculaire.toString(),
                            icon: Icons.fitness_center_rounded,
                            color: Colors.orange,
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
                            label: l10n.medicalOverviewJointInjuries,
                            value: _bilansStatsLoading
                                ? '-'
                                : _totalArticulaire.toString(),
                            icon: Icons.accessibility_new_rounded,
                            color: Colors.blue,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MedicalStatCard(
                            label: l10n.medicalOverviewTraumaInjuries,
                            value: _bilansStatsLoading
                                ? '-'
                                : _totalTraumatique.toString(),
                            icon: Icons.local_hospital_outlined,
                            color: Colors.red,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SectionTitle(title: l10n.recentActivities)),
                if (_activitesLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_activites.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          l10n.noRecentActivity,
                          style: GoogleFonts.montserrat(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: _buildRecentActivity(),
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
          colors: [Color(0xFF8B0A1E), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B0A1E).withValues(alpha: 0.3),
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

  Widget _buildRecentActivity() {
    final activityHelper = ActivityL10nHelper(AppLocalizations.of(context)!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(_activites.length, (index) {
          final item = _activites[index];
          return ActivityCard(
            title: activityHelper.titre(item),
            subtitle: activityHelper.description(item),
            time: _formatTempsRelatif(item.date),
            icon: _iconeParType(item.type),
            iconColor: _couleurParType(item.type),
            isLast: index == _activites.length - 1,
          );
        }),
      ),
    );
  }

  /// Retourne l'icone associee a un type d'activite.
  IconData _iconeParType(ActivityType type) {
    switch (type) {
      case ActivityType.seanceOuverte:
        return Icons.play_circle_outline_rounded;
      case ActivityType.seanceCloturee:
        return Icons.check_circle_outline_rounded;
      case ActivityType.seanceProgrammee:
        return Icons.schedule_rounded;
      case ActivityType.academicienInscrit:
        return Icons.person_add_outlined;
      case ActivityType.academicienSupprime:
        return Icons.person_remove_outlined;
      case ActivityType.encadreurInscrit:
        return Icons.sports_rounded;
      case ActivityType.presenceEnregistree:
        return Icons.qr_code_scanner_rounded;
      case ActivityType.smsEnvoye:
        return Icons.sms_outlined;
      case ActivityType.smsEchec:
        return Icons.sms_failed_outlined;
      case ActivityType.bulletinGenere:
        return Icons.description_outlined;
      case ActivityType.referentielPosteAjoute:
      case ActivityType.referentielPosteModifie:
      case ActivityType.referentielPosteSupprime:
      case ActivityType.referentielNiveauAjoute:
      case ActivityType.referentielNiveauModifie:
      case ActivityType.referentielNiveauSupprime:
        return Icons.tune_rounded;
      case ActivityType.bilanMedicalMensuelCree:
      case ActivityType.bilanMedicalMensuelModifie:
      case ActivityType.bilanMedicalMensuelSupprime:
        return Icons.medical_information_outlined;
    }
  }

  /// Retourne la couleur associee a un type d'activite.
  Color _couleurParType(ActivityType type) {
    switch (type) {
      case ActivityType.seanceOuverte:
      case ActivityType.presenceEnregistree:
        return const Color(0xFF10B981);
      case ActivityType.seanceCloturee:
      case ActivityType.bulletinGenere:
        return AppColors.primary;
      case ActivityType.seanceProgrammee:
      case ActivityType.academicienInscrit:
        return const Color(0xFF3B82F6);
      case ActivityType.academicienSupprime:
        return AppColors.primary;
      case ActivityType.encadreurInscrit:
      case ActivityType.smsEnvoye:
        return const Color(0xFF8B5CF6);
      case ActivityType.smsEchec:
        return AppColors.primary;
      case ActivityType.referentielPosteAjoute:
      case ActivityType.referentielPosteModifie:
      case ActivityType.referentielPosteSupprime:
      case ActivityType.referentielNiveauAjoute:
      case ActivityType.referentielNiveauModifie:
      case ActivityType.referentielNiveauSupprime:
        return const Color(0xFFF59E0B);
      case ActivityType.bilanMedicalMensuelCree:
      case ActivityType.bilanMedicalMensuelModifie:
      case ActivityType.bilanMedicalMensuelSupprime:
        return const Color(0xFFEF4444);
    }
  }

  /// Formate une date en temps relatif.
  String _formatTempsRelatif(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);

    if (difference.inMinutes < 1) return l10n.justNow;
    if (difference.inMinutes < 60) return l10n.minutesAgo(difference.inMinutes);
    if (difference.inHours < 24) return l10n.hoursAgo(difference.inHours);
    if (difference.inDays == 1) return l10n.yesterday;
    if (difference.inDays < 7) return l10n.daysAgo(difference.inDays);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
