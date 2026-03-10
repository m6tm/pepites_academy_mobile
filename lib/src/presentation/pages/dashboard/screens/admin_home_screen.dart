import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../helpers/activity_l10n_helper.dart';
import '../../../../presentation/widgets/stat_card.dart';
import '../../../../presentation/widgets/quick_action_tile.dart';
import '../../../../presentation/widgets/activity_card.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../../../../presentation/widgets/circular_progress_widget.dart';
import '../../../../presentation/widgets/global_stats_card.dart';
import '../../../../presentation/widgets/season_management_card.dart';
import '../../../../injection_container.dart';
import '../../../../domain/entities/activity.dart';
import '../../../../domain/entities/seance.dart';
import '../../../../domain/entities/dashboard_stats.dart';
import '../../academy/academicien_registration_page.dart';
import '../../encadreur/encadreur_list_page.dart';
import '../../notification/notifications_page.dart';
import '../../seance/seance_detail_page.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/seance_card.dart';

/// Ecran d'accueil du dashboard administrateur.
/// Affiche la vue d'ensemble avec statistiques, actions rapides et activite recente.
class AdminHomeScreen extends StatefulWidget {
  final String userName;
  final String greeting;
  final String? photoUrl;
  final ValueChanged<int>? onNavigateToTab;

  const AdminHomeScreen({
    super.key,
    required this.userName,
    required this.greeting,
    this.photoUrl,
    this.onNavigateToTab,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Seance? _derniereSeance;
  bool _seanceLoading = true;
  List<Activity> _activites = [];
  bool _activitesLoading = true;
  DashboardStats? _dashboardStats;
  bool _statsIsFromCache = false;
  bool _statsIsLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerDerniereSeance();
    _chargerActivitesRecentes();
    _chargerDashboardStats();
    DependencyInjection.notificationState.chargerNotifications('admin');
  }

  /// Charge la derniere seance (ouverte en priorite, sinon la plus recente).
  Future<void> _chargerDerniereSeance() async {
    try {
      final ouverte = await DependencyInjection.seanceRepository
          .getSeanceOuverte();
      if (ouverte != null) {
        if (mounted) {
          setState(() {
            _derniereSeance = ouverte;
            _seanceLoading = false;
          });
        }
        return;
      }
      final toutes = await DependencyInjection.seanceRepository.getAll();
      if (toutes.isNotEmpty) {
        toutes.sort((a, b) => b.date.compareTo(a.date));
        if (mounted) {
          setState(() {
            _derniereSeance = toutes.first;
            _seanceLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _seanceLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _seanceLoading = false;
        });
      }
    }
  }

  /// Charge les statistiques du dashboard depuis le backend.
  /// Affiche les donnees en cache immediatement puis rafraichit.
  Future<void> _chargerDashboardStats() async {
    try {
      final (stats, _, isFromCache) = await DependencyInjection.dashboardService
          .getStats();
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _statsIsFromCache = isFromCache;
        });
      }
    } catch (_) {
      // Erreur silencieuse, les stats restent a null
    }
  }

  /// Rafraichit les statistiques du dashboard.
  Future<void> _rafraichirStats() async {
    if (_statsIsLoading) return;
    setState(() {
      _statsIsLoading = true;
    });
    try {
      final (stats, _, isFromCache) = await DependencyInjection.dashboardService
          .getStats(forceRefresh: true);
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _statsIsFromCache = isFromCache;
          _statsIsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _statsIsLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: ListenableBuilder(
            listenable: DependencyInjection.notificationState,
            builder: (context, _) {
              return DashboardHeader(
                userName: widget.userName,
                role: l10n.administrator,
                greeting: widget.greeting,
                photoUrl: widget.photoUrl,
                notificationCount:
                    DependencyInjection.notificationState.nonLuesCount,
                // TODO: Activer la recherche plus tard
                // onSearchTap: () {
                //   Navigator.of(
                //     context,
                //   ).push(MaterialPageRoute(builder: (_) => const SearchPage()));
                // },
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsPage(userRole: 'admin'),
                    ),
                  );
                },
                onProfileTap: () {},
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: _buildWelcomeBanner(colorScheme, l10n)),
        SliverToBoxAdapter(
          child: GlobalStatsCard(
            stats: _dashboardStats,
            isFromCache: _statsIsFromCache,
            isLoading: _statsIsLoading,
            onRefresh: _rafraichirStats,
            connectivityState: DependencyInjection.connectivityState,
            syncState: DependencyInjection.syncState,
          ),
        ),
        SliverToBoxAdapter(
          child: SeasonManagementCard(
            currentSeason: _dashboardStats?.currentSeason,
            onActionComplete: _rafraichirStats,
          ),
        ),
        SliverToBoxAdapter(child: SectionTitle(title: l10n.overview)),
        SliverToBoxAdapter(child: _buildStatsGrid(l10n)),
        SliverToBoxAdapter(child: SectionTitle(title: l10n.quickActions)),
        SliverToBoxAdapter(child: _buildQuickActions(context, l10n)),
        SliverToBoxAdapter(
          child: SectionTitle(
            title: l10n.sessionOfTheDay,
            actionLabel: l10n.history,
          ),
        ),
        SliverToBoxAdapter(child: _buildSeanceDuJour(context)),
        SliverToBoxAdapter(child: SectionTitle(title: l10n.globalPerformance)),
        SliverToBoxAdapter(
          child: _buildPerformanceSection(context, colorScheme, l10n),
        ),
        SliverToBoxAdapter(
          child: SectionTitle(
            title: l10n.recentActivity,
            actionLabel: l10n.viewAll,
          ),
        ),
        SliverToBoxAdapter(child: _buildRecentActivity()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

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
            color: AppColors.primary.withValues(alpha: 0.15),
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
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.administrator.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AppLocalizations l10n) {
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
            label: l10n.academicians,
            value: stats?.nbAcademiciens.toString() ?? '-',
            icon: Icons.school_rounded,
            color: Color(0xFF3B82F6),
          ),
          StatCard(
            label: l10n.coaches,
            value: stats?.nbEncadreurs.toString() ?? '-',
            icon: Icons.sports_rounded,
            color: Color(0xFF8B5CF6),
          ),
          StatCard(
            label: l10n.sessionsMonth,
            value: stats?.globalStats.nbSeancesMois.toString() ?? '-',
            icon: Icons.calendar_today_rounded,
            color: AppColors.primary,
          ),
          StatCard(
            label: l10n.attendanceRate,
            value: '${(stats?.tauxPresenceMoyen ?? 0).toStringAsFixed(0)}%',
            icon: Icons.check_circle_rounded,
            color: Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
        children: [
          QuickActionTile(
            title: l10n.register_action,
            description: l10n.newAcademician,
            icon: Icons.person_add_rounded,
            color: const Color(0xFF3B82F6),
            badge: l10n.badgeNew,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AcademicienRegistrationPage(),
                ),
              );
            },
          ),
          QuickActionTile(
            title: l10n.players,
            description: l10n.academiciansList,
            icon: Icons.sports_soccer_rounded,
            color: const Color(0xFF10B981),
            onTap: () {
              widget.onNavigateToTab?.call(1);
            },
          ),
          QuickActionTile(
            title: l10n.coaches,
            description: l10n.coachManagement,
            icon: Icons.sports_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EncadreurListPage(
                    repository: DependencyInjection.encadreurRepository,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = _dashboardStats;

    // Calcul des valeurs dynamiques
    final tauxPresence = (stats?.tauxPresenceMoyen ?? 0) / 100.0;
    final objectifs = (stats?.globalStats.objectifsAtteints ?? 0) / 100.0;
    final satisfaction = (stats?.globalStats.satisfactionCoachs ?? 0) / 100.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressWidget(
                progress: tauxPresence,
                label: l10n.averageAttendance,
                centerText: '${(tauxPresence * 100).toStringAsFixed(0)}%',
                color: Color(0xFF10B981),
                size: 80,
                strokeWidth: 7,
              ),
              CircularProgressWidget(
                progress: objectifs,
                label: l10n.goalsAchieved,
                centerText: '${(objectifs * 100).toStringAsFixed(0)}%',
                color: Color(0xFF3B82F6),
                size: 80,
                strokeWidth: 7,
              ),
              CircularProgressWidget(
                progress: satisfaction,
                label: l10n.coachSatisfaction,
                centerText: '${(satisfaction * 100).toStringAsFixed(0)}%',
                color: Color(0xFF8B5CF6),
                size: 80,
                strokeWidth: 7,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insights_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.positiveTrend,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Charge les activites recentes depuis le service d'activites.
  Future<void> _chargerActivitesRecentes() async {
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
        setState(() {
          _activitesLoading = false;
        });
      }
    }
  }

  Widget _buildRecentActivity() {
    if (_activitesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_activites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          AppLocalizations.of(context)!.noRecentActivity,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

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
    }
  }

  /// Formate une date en temps relatif (ex: "Il y a 2h", "Hier", "3 jours").
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

  /// Convertit le statut de l'entite en statut visuel pour la carte.
  SeanceCardStatus _mapSeanceStatus(SeanceStatus statut) {
    switch (statut) {
      case SeanceStatus.ouverte:
        return SeanceCardStatus.enCours;
      case SeanceStatus.fermee:
        return SeanceCardStatus.terminee;
      case SeanceStatus.aVenir:
        return SeanceCardStatus.aVenir;
    }
  }

  /// Construit la section seance du jour avec les donnees reelles.
  Widget _buildSeanceDuJour(BuildContext context) {
    if (_seanceLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_derniereSeance == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          AppLocalizations.of(context)!.noSessionRecorded,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final seance = _derniereSeance!;
    return SeanceCard(
      title: seance.titre,
      date: seance.dateFormatee,
      heureDebut:
          '${seance.heureDebut.hour.toString().padLeft(2, '0')}:${seance.heureDebut.minute.toString().padLeft(2, '0')}',
      heureFin:
          '${seance.heureFin.hour.toString().padLeft(2, '0')}:${seance.heureFin.minute.toString().padLeft(2, '0')}',
      encadreur: AppLocalizations.of(context)!.coach,
      nbPresents: seance.nbPresents,
      nbAteliers: seance.nbAteliers,
      status: _mapSeanceStatus(seance.statut),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SeanceDetailPage(seance: seance)),
        );
      },
    );
  }
}
