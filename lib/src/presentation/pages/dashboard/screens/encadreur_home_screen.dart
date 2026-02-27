import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/annotation.dart';
import '../../../../domain/entities/atelier.dart';
import '../../../../domain/entities/presence.dart';
import '../../../../domain/entities/seance.dart';
import '../../../../injection_container.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../../presentation/widgets/stat_card.dart';
import '../../../../presentation/widgets/quick_action_tile.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../../../../presentation/widgets/circular_progress_widget.dart';
import '../../../state/seance_state.dart';
import '../../academy/academicien_list_page.dart';
import '../../academy/academicien_profile_page.dart';
import '../../academy/academicien_registration_page.dart';
import '../../scanner/qr_scanner_page.dart';
import '../../notification/notifications_page.dart';
import '../../../widgets/academy_toast.dart';
import '../../seance/seance_detail_page.dart';
import '../../seance/atelier_composition_page.dart';
import '../../../state/atelier_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/encadreur_internal_widgets.dart';

/// Ecran d'accueil du dashboard encadreur.
/// Affiche la seance en cours, statistiques terrain et academiciens supervises.
class EncadreurHomeScreen extends StatefulWidget {
  final SeanceState seanceState;
  final String userName;
  final String greeting;
  final String? photoUrl;
  final VoidCallback? onSmsTap;
  final void Function(int)? onNavigateToTab;

  const EncadreurHomeScreen({
    super.key,
    required this.seanceState,
    required this.userName,
    required this.greeting,
    this.photoUrl,
    this.onSmsTap,
    this.onNavigateToTab,
  });

  @override
  State<EncadreurHomeScreen> createState() => _EncadreurHomeScreenState();
}

class _EncadreurHomeScreenState extends State<EncadreurHomeScreen>
    with WidgetsBindingObserver {
  late final SeanceState _seanceState;
  List<Academicien> _academiciens = [];
  bool _isLoadingAcademiciens = true;

  DateTime? _lastSeanceRefreshAt;

  String? _currentSeanceId;
  int? _currentNbPresents;
  int? _currentNbAteliers;
  int? _currentNbAnnotations;

  int? _sessionsConducted;
  int? _totalAnnotations;
  int? _workshopsCreated;
  double? _averageAttendance;

  double? _annotationsPerSession;
  double? _closedSessionsRate;
  double? _activityProgress;
  int? _toNextLevel;

  bool _isRefreshingCurrentSeanceStats = false;
  bool _isRefreshingCoachActivityStats = false;

  // Annotations recentes pour la section home
  List<Annotation> _recentAnnotations = [];
  final Map<String, Academicien?> _academicienCache = {};
  final Map<String, Atelier?> _atelierCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _seanceState = widget.seanceState;
    _seanceState.addListener(_onStateChanged);
    DependencyInjection.notificationState.chargerNotifications('encadreur');
    _chargerAcademiciens();
    _refreshCoachActivityStats();
    _loadRecentAnnotations();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _seanceState.chargerSeances();
      _refreshCurrentSeanceStats();
      _refreshCoachActivityStats();
    }
  }

  Future<void> _chargerAcademiciens() async {
    final academiciens = await DependencyInjection.academicienRepository
        .getAll();
    if (mounted) {
      setState(() {
        _academiciens = academiciens;
        _isLoadingAcademiciens = false;
      });
    }
  }

  Future<void> _refreshCoachActivityStats() async {
    if (_isRefreshingCoachActivityStats) return;
    _isRefreshingCoachActivityStats = true;

    try {
      final currentUserId = await DependencyInjection.preferences.getUserId();
      final seances = await DependencyInjection.seanceRepository.getAll();

      final seancesDirigees = currentUserId == null || currentUserId.isEmpty
          ? seances
          : seances
                .where(
                  (s) =>
                      s.encadreurResponsableId == 'current_user' ||
                      s.encadreurResponsableId == currentUserId,
                )
                .toList();

      final seanceIds = seancesDirigees.map((s) => s.id).toList();

      final closedCount = seancesDirigees.where((s) => s.estFermee).length;
      final closedRate = seancesDirigees.isEmpty
          ? 0.0
          : (closedCount / seancesDirigees.length);

      final annotationsFutures = seanceIds
          .map(DependencyInjection.annotationService.getAnnotationsSeance)
          .toList();
      final ateliersFutures = seanceIds
          .map(DependencyInjection.atelierService.getAteliersParSeance)
          .toList();
      final presencesFutures = seanceIds
          .map(DependencyInjection.presenceRepository.getBySeance)
          .toList();

      final results = await Future.wait([
        Future.wait(annotationsFutures),
        Future.wait(ateliersFutures),
        Future.wait(presencesFutures),
      ]);

      final annotationsParSeance = results[0] as List<List<dynamic>>;
      final ateliersParSeance = results[1] as List<List<dynamic>>;
      final presencesParSeance = results[2] as List<List<dynamic>>;

      int totalAnnotations = 0;
      int totalAteliers = 0;
      for (final list in annotationsParSeance) {
        totalAnnotations += list.length;
      }
      for (final list in ateliersParSeance) {
        totalAteliers += list.length;
      }

      double? avgAttendance;
      final ratios = <double>[];
      for (int i = 0; i < seancesDirigees.length; i++) {
        final seance = seancesDirigees[i];
        final denom = seance.academicienIds.length;
        if (denom <= 0) continue;

        final presences = presencesParSeance[i].cast<Presence>();
        final nbAcademiciensPresents = presences
            .where((p) => p.typeProfil == ProfilType.academicien)
            .length;
        ratios.add(nbAcademiciensPresents / denom);
      }

      if (ratios.isNotEmpty) {
        avgAttendance = ratios.reduce((a, b) => a + b) / ratios.length;
      }

      final annotationsPerSession = seancesDirigees.isEmpty
          ? 0.0
          : (totalAnnotations / seancesDirigees.length);

      final sessionsProgress = (seancesDirigees.length / 20).clamp(0.0, 1.0);
      final attendanceProgress = (avgAttendance ?? 0.0).clamp(0.0, 1.0);
      final annotationsProgress = (annotationsPerSession / 10).clamp(0.0, 1.0);
      final ateliersProgress = (totalAteliers / 50).clamp(0.0, 1.0);

      final activityProgress =
          (0.25 * sessionsProgress +
                  0.25 * closedRate.clamp(0.0, 1.0) +
                  0.25 * attendanceProgress +
                  0.15 * annotationsProgress +
                  0.10 * ateliersProgress)
              .clamp(0.0, 1.0);

      final toNextLevel = (100 - (activityProgress * 100).round()).clamp(
        0,
        100,
      );

      if (!mounted) return;
      setState(() {
        _sessionsConducted = seancesDirigees.length;
        _totalAnnotations = totalAnnotations;
        _workshopsCreated = totalAteliers;
        _averageAttendance = avgAttendance;

        _annotationsPerSession = annotationsPerSession;
        _closedSessionsRate = closedRate;
        _activityProgress = activityProgress;
        _toNextLevel = toNextLevel;
      });
    } catch (_) {
      return;
    } finally {
      _isRefreshingCoachActivityStats = false;
    }
  }

  void _onStateChanged() {
    if (!mounted) return;

    final seanceId = _seanceState.seanceOuverte?.id;
    final shouldRefresh = seanceId != _currentSeanceId;
    if (shouldRefresh) {
      _currentSeanceId = seanceId;
      _currentNbPresents = null;
      _currentNbAteliers = null;
      _currentNbAnnotations = null;
      _refreshCurrentSeanceStats();
    }

    _refreshCoachActivityStats();
    _loadRecentAnnotations();

    setState(() {});
  }

  Future<void> _refreshCurrentSeanceStats() async {
    final seance = _seanceState.seanceOuverte;
    if (seance == null) return;

    if (_isRefreshingCurrentSeanceStats) return;
    _isRefreshingCurrentSeanceStats = true;

    try {
      final results = await Future.wait([
        DependencyInjection.presenceRepository.getBySeance(seance.id),
        DependencyInjection.atelierService.getAteliersParSeance(seance.id),
        DependencyInjection.annotationService.getAnnotationsSeance(seance.id),
      ]);

      if (!mounted) return;

      setState(() {
        _currentNbPresents = (results[0] as List<Presence>).length;
        _currentNbAteliers = (results[1] as List<Atelier>).length;
        _currentNbAnnotations = (results[2] as List<Annotation>).length;
      });
    } catch (_) {
      return;
    } finally {
      _isRefreshingCurrentSeanceStats = false;
    }
  }

  /// Charge les 5 dernieres annotations de l'encadreur connecte.
  Future<void> _loadRecentAnnotations() async {
    try {
      final encadreurId = await DependencyInjection.preferences.getUserId();
      if (encadreurId == null || encadreurId.isEmpty) {
        return;
      }

      final allAnnotations = await DependencyInjection.annotationRepository
          .getByEncadreur(encadreurId);

      // Trier par date decroissante et prendre les 5 dernieres
      allAnnotations.sort((a, b) => b.horodate.compareTo(a.horodate));
      final recent = allAnnotations.take(5).toList();

      // Charger les caches pour les academiciens et ateliers
      for (final a in recent) {
        _academicienCache[a.academicienId] ??= await DependencyInjection
            .academicienRepository
            .getById(a.academicienId);
        _atelierCache[a.atelierId] ??= await DependencyInjection
            .atelierRepository
            .getById(a.atelierId);
      }

      if (!mounted) return;
      setState(() => _recentAnnotations = recent);
    } catch (_) {
      // Erreur silencieuse - on garde les donnees existantes
    }
  }

  /// Formate une date en temps relatif.
  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Construit les view models pour les annotations.
  List<AnnotationData> _buildAnnotationViewModels(List<Annotation> list) {
    return list.map((a) {
      final academicien = _academicienCache[a.academicienId];
      final atelier = _atelierCache[a.atelierId];
      final academicienNom = academicien == null
          ? a.academicienId
          : '${academicien.prenom} ${academicien.nom}'.trim();
      final atelierNom = atelier?.nom ?? a.atelierId;
      return AnnotationData(
        academicienNom,
        atelierNom,
        a.contenu,
        a.tags,
        _formatTimeAgo(a.horodate),
      );
    }).toList();
  }

  /// Verifie qu'une seance est ouverte avant d'ouvrir les ateliers.
  Future<void> _ouvrirAteliers() async {
    final seanceOuverte = await DependencyInjection.seanceRepository
        .getSeanceOuverte();
    if (!mounted) return;

    if (seanceOuverte == null) {
      final l10n = AppLocalizations.of(context)!;
      AcademyToast.show(
        context,
        title: l10n.noSessionInProgress,
        description: l10n.openSessionBeforeWorkshops,
        icon: Icons.warning_amber_rounded,
        isError: true,
      );
      return;
    }

    final atelierState = AtelierState(DependencyInjection.atelierService);
    await atelierState.chargerAteliers(seanceOuverte.id);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtelierCompositionPage(
          seance: seanceOuverte,
          atelierState: atelierState,
        ),
      ),
    );
    _seanceState.chargerSeances();
    _refreshCurrentSeanceStats();
    _refreshCoachActivityStats();
  }

  /// Ouvre la liste complete des academiciens.
  void _ouvrirListeAcademiciens() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcademicienListPage(
          repository: DependencyInjection.academicienRepository,
        ),
      ),
    );
  }

  /// Ouvre les details d'un academicien.
  Future<void> _ouvrirDetailsAcademicien(Academicien academicien) async {
    final postes = await DependencyInjection.referentielService.getAllPostes();
    final niveaux = await DependencyInjection.referentielService
        .getAllNiveaux();
    final postesMap = {for (final p in postes) p.id: p};
    final niveauxMap = {for (final n in niveaux) n.id: n};

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcademicienProfilePage(
          academicien: academicien,
          repository: DependencyInjection.academicienRepository,
          postesMap: postesMap,
          niveauxMap: niveauxMap,
        ),
      ),
    );
  }

  /// Verifie qu'une seance est ouverte avant de lancer le scanner.
  Future<void> _ouvrirScanner() async {
    final seanceOuverte = await DependencyInjection.seanceRepository
        .getSeanceOuverte();
    if (!mounted) return;

    if (seanceOuverte == null) {
      final l10n = AppLocalizations.of(context)!;
      AcademyToast.show(
        context,
        title: l10n.noSessionInProgress,
        description: l10n.openSessionBeforeScan,
        icon: Icons.warning_amber_rounded,
        isError: true,
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrScannerPage(seanceId: seanceOuverte.id),
      ),
    );
    _seanceState.chargerSeances();
    _refreshCurrentSeanceStats();
    _refreshCoachActivityStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _seanceState.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleSeanceRefreshIfStale();

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
                role: l10n.coach,
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
                onSmsTap: widget.onSmsTap,
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsPage(userRole: 'encadreur'),
                    ),
                  );
                },
                onProfileTap: () {},
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: _buildTerrainBanner(colorScheme)),
        if (_seanceState.seanceOuverte != null)
          SliverToBoxAdapter(
            child: _buildCurrentSeanceCard(context, colorScheme),
          )
        else
          SliverToBoxAdapter(child: _buildNoSeanceCard(context, colorScheme)),
        SliverToBoxAdapter(child: SectionTitle(title: l10n.myActivity)),
        SliverToBoxAdapter(child: _buildCoachStats(l10n)),
        SliverToBoxAdapter(child: SectionTitle(title: l10n.fieldActions)),
        SliverToBoxAdapter(child: _buildCoachQuickActions(context, l10n)),
        SliverToBoxAdapter(
          child: SectionTitle(
            title: l10n.myAcademicians,
            actionLabel: l10n.viewAll,
            onAction: _ouvrirListeAcademiciens,
          ),
        ),
        SliverToBoxAdapter(child: _buildAcademiciensList(colorScheme)),
        SliverToBoxAdapter(child: SectionTitle(title: l10n.myIndicators)),
        SliverToBoxAdapter(
          child: _buildCoachPerformance(context, colorScheme, l10n),
        ),
        SliverToBoxAdapter(
          child: SectionTitle(
            title: l10n.myRecentAnnotations,
            actionLabel: l10n.viewAll,
          ),
        ),
        SliverToBoxAdapter(child: _buildRecentAnnotations()),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _scheduleSeanceRefreshIfStale() {
    final now = DateTime.now();
    final last = _lastSeanceRefreshAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return;
    }
    _lastSeanceRefreshAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _seanceState.chargerSeances();
      _refreshCurrentSeanceStats();
      _refreshCoachActivityStats();
    });
  }

  Widget _buildTerrainBanner(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
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
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.sessionInProgress,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context)!.readyForField,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.manageSessionsDescription,
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
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(
              Icons.sports_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSeanceCard(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seance = _seanceState.seanceOuverte!;

    final nbPresents = _currentNbPresents ?? seance.nbPresents;
    final nbAteliers = _currentNbAteliers ?? seance.atelierIds.length;
    final nbAnnotations = _currentNbAnnotations ?? 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SeanceDetailPage(seance: seance)),
        );
        _seanceState.chargerSeances();
        _refreshCurrentSeanceStats();
        _refreshCoachActivityStats();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_circle_rounded,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.inProgress,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  seance.dureeFormatee,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              seance.titre,
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SeanceStatChip(
                  icon: Icons.people_rounded,
                  value: '$nbPresents',
                  label: AppLocalizations.of(context)!.present,
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 12),
                SeanceStatChip(
                  icon: Icons.sports_soccer_rounded,
                  value: '$nbAteliers',
                  label: AppLocalizations.of(context)!.workshops,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 12),
                SeanceStatChip(
                  icon: Icons.edit_note_rounded,
                  value: '$nbAnnotations',
                  label: AppLocalizations.of(context)!.annotations,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _ouvrirAteliers,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      AppLocalizations.of(context)!.addWorkshop,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleFermerSeance(seance),
                    icon: const Icon(Icons.stop_rounded, size: 18),
                    label: Text(
                      AppLocalizations.of(context)!.closeSession,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.15),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSeanceCard(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports_soccer_rounded,
            size: 40,
            color: colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noCurrentSession,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.openSessionToStart,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  /// Gere la fermeture d'une seance depuis le home screen.
  Future<void> _handleFermerSeance(Seance seance) async {
    final result = await _seanceState.fermerSeance(seance.id);
    if (!mounted) return;

    if (result.success) {
      AcademyToast.show(context, title: result.message, isSuccess: true);
    } else {
      AcademyToast.show(context, title: result.message, isError: true);
    }

    _seanceState.chargerSeances();
    _refreshCurrentSeanceStats();
    _refreshCoachActivityStats();
  }

  Widget _buildCoachStats(AppLocalizations l10n) {
    final sessionsValue = (_sessionsConducted ?? 0).toString();
    final annotationsValue = (_totalAnnotations ?? 0).toString();
    final ateliersValue = (_workshopsCreated ?? 0).toString();
    final attendanceValue = _averageAttendance == null
        ? '0%'
        : '${(_averageAttendance! * 100).round()}%';

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
            label: l10n.sessionsConducted,
            value: sessionsValue,
            icon: Icons.sports_soccer_rounded,
            color: Color(0xFF3B82F6),
          ),
          StatCard(
            label: l10n.annotations,
            value: annotationsValue,
            icon: Icons.edit_note_rounded,
            color: Color(0xFF8B5CF6),
          ),
          StatCard(
            label: l10n.workshopsCreated,
            value: ateliersValue,
            icon: Icons.fitness_center_rounded,
            color: Color(0xFFF59E0B),
          ),
          StatCard(
            label: l10n.averageAttendanceShort,
            value: attendanceValue,
            icon: Icons.check_circle_rounded,
            color: Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachQuickActions(BuildContext context, AppLocalizations l10n) {
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
            color: const Color(0xFF10B981),
            badge: l10n.badgeGo,
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
            title: l10n.myAnnotations,
            description: l10n.evaluateAcademician,
            icon: Icons.edit_note_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () => widget.onNavigateToTab?.call(3),
          ),
          QuickActionTile(
            title: l10n.myWorkshops,
            description: l10n.manageExercises,
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFFF59E0B),
            onTap: _ouvrirAteliers,
          ),
          QuickActionTile(
            title: l10n.attendance,
            description: l10n.scanArrivals,
            icon: Icons.qr_code_scanner_rounded,
            color: AppColors.primary,
            onTap: _ouvrirScanner,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademiciensList(ColorScheme colorScheme) {
    // Couleurs pour les cartes d'académiciens
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF6366F1),
      Color(0xFFEC4899),
    ];

    if (_isLoadingAcademiciens) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_academiciens.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Aucun académicien',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    // Afficher les 6 derniers académiciens
    final displayList = _academiciens.take(6).toList();

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final acad = displayList[index];
          final color = colors[index % colors.length];
          final miniData = AcademicienMini(
            '${acad.prenom} ${acad.nom[0]}.',
            '', // Le poste sera affiché si disponible
            color,
            id: acad.id,
            photoUrl: acad.photoUrl,
          );
          return AcademicienMiniCard(
            data: miniData,
            onTap: () => _ouvrirDetailsAcademicien(acad),
          );
        },
      ),
    );
  }

  Widget _buildCoachPerformance(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final attendanceRate = _averageAttendance ?? 0.0;
    final attendanceText = '${(attendanceRate * 100).round()}%';

    final annPerSession = _annotationsPerSession ?? 0.0;
    final annText = annPerSession.toStringAsFixed(1);
    final annProgress = (annPerSession / 10).clamp(0.0, 1.0);

    final closedRate = _closedSessionsRate ?? 0.0;
    final closedText = '${(closedRate * 100).round()}%';

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
                progress: attendanceRate.clamp(0.0, 1.0),
                label: l10n.attendanceRateLabel,
                centerText: attendanceText,
                color: Color(0xFF10B981),
                size: 80,
                strokeWidth: 7,
              ),
              CircularProgressWidget(
                progress: annProgress,
                label: l10n.annotationsPerSession,
                centerText: annText,
                color: Color(0xFF8B5CF6),
                size: 80,
                strokeWidth: 7,
              ),
              CircularProgressWidget(
                progress: closedRate.clamp(0.0, 1.0),
                label: l10n.closedSessions,
                centerText: closedText,
                color: Color(0xFF3B82F6),
                size: 80,
                strokeWidth: 7,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExpBar(colorScheme, l10n),
        ],
      ),
    );
  }

  Widget _buildExpBar(ColorScheme colorScheme, AppLocalizations l10n) {
    final progress = (_activityProgress ?? 0.0).clamp(0.0, 1.0);
    final toNext = _toNextLevel ?? 100;

    final badgeText = progress >= 0.75
        ? l10n.expert
        : '${(progress * 100).round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.activityLevel,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.toNextLevel(toNext),
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAnnotations() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_recentAnnotations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          l10n.noAnnotationRecorded,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final viewModels = _buildAnnotationViewModels(_recentAnnotations);

    return Column(
      children: viewModels.asMap().entries.map((entry) {
        return AnnotationListItem(data: entry.value, isDark: isDark);
      }).toList(),
    );
  }
}
