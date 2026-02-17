import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/seance.dart';
import '../../../../injection_container.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../../presentation/widgets/stat_card.dart';
import '../../../../presentation/widgets/quick_action_tile.dart';
import '../../../../presentation/widgets/activity_card.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../../../../presentation/widgets/circular_progress_widget.dart';
import '../../../state/seance_state.dart';
import '../../academy/academicien_registration_page.dart';
import '../../scanner/qr_scanner_page.dart';
import '../../notification/notifications_page.dart';
import '../../search/search_page.dart';
import '../../../widgets/academy_toast.dart';
import '../../seance/seance_detail_page.dart';
import '../../seance/atelier_composition_page.dart';
import '../../../state/atelier_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/encadreur_internal_widgets.dart';

/// Ecran d'accueil du dashboard encadreur.
/// Affiche la seance en cours, statistiques terrain et academiciens supervises.
class EncadreurHomeScreen extends StatefulWidget {
  final String userName;
  final String greeting;
  final VoidCallback? onSmsTap;
  final void Function(int)? onNavigateToTab;

  const EncadreurHomeScreen({
    super.key,
    required this.userName,
    required this.greeting,
    this.onSmsTap,
    this.onNavigateToTab,
  });

  @override
  State<EncadreurHomeScreen> createState() => _EncadreurHomeScreenState();
}

class _EncadreurHomeScreenState extends State<EncadreurHomeScreen> {
  late final SeanceState _seanceState;

  @override
  void initState() {
    super.initState();
    _seanceState = SeanceState(DependencyInjection.seanceService);
    _seanceState.addListener(_onStateChanged);
    _seanceState.chargerSeances();
    DependencyInjection.notificationState.chargerNotifications('encadreur');
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  /// Verifie qu'une seance est ouverte avant d'ouvrir les ateliers.
  Future<void> _ouvrirAteliers() async {
    final seanceOuverte = await DependencyInjection.seanceRepository
        .getSeanceOuverte();
    if (!mounted) return;

    if (seanceOuverte == null) {
      AcademyToast.show(
        context,
        title: 'Aucune seance en cours',
        description: 'Veuillez ouvrir une seance avant de gerer les ateliers.',
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
  }

  /// Verifie qu'une seance est ouverte avant de lancer le scanner.
  Future<void> _ouvrirScanner() async {
    final seanceOuverte = await DependencyInjection.seanceRepository
        .getSeanceOuverte();
    if (!mounted) return;

    if (seanceOuverte == null) {
      AcademyToast.show(
        context,
        title: 'Aucune seance en cours',
        description: 'Veuillez ouvrir une seance avant de scanner.',
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
  }

  @override
  void dispose() {
    _seanceState.removeListener(_onStateChanged);
    _seanceState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: DashboardHeader(
            userName: widget.userName,
            role: 'Encadreur',
            greeting: widget.greeting,
            notificationCount:
                DependencyInjection.notificationState.nonLuesCount,
            onSearchTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SearchPage()));
            },
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
          ),
        ),
        SliverToBoxAdapter(child: _buildTerrainBanner(colorScheme)),
        if (_seanceState.seanceOuverte != null)
          SliverToBoxAdapter(
            child: _buildCurrentSeanceCard(context, colorScheme),
          )
        else
          SliverToBoxAdapter(child: _buildNoSeanceCard(context, colorScheme)),
        const SliverToBoxAdapter(child: SectionTitle(title: 'Mon activite')),
        SliverToBoxAdapter(child: _buildCoachStats()),
        const SliverToBoxAdapter(child: SectionTitle(title: 'Actions terrain')),
        SliverToBoxAdapter(child: _buildCoachQuickActions(context)),
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Mes academiciens',
            actionLabel: 'Tout voir',
          ),
        ),
        SliverToBoxAdapter(child: _buildAcademiciensList(colorScheme)),
        const SliverToBoxAdapter(child: SectionTitle(title: 'Mes indicateurs')),
        SliverToBoxAdapter(child: _buildCoachPerformance(context, colorScheme)),
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Mes dernieres annotations',
            actionLabel: 'Tout voir',
          ),
        ),
        SliverToBoxAdapter(child: _buildRecentAnnotations()),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
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
                        'SEANCE EN COURS',
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
                  'Pret pour le terrain',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gerez vos seances, evaluez vos joueurs et suivez leur progression.',
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

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SeanceDetailPage(seance: seance)),
        );
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
                        'En cours',
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
                  value: '${seance.nbPresents}',
                  label: 'Presents',
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 12),
                SeanceStatChip(
                  icon: Icons.sports_soccer_rounded,
                  value: '${seance.atelierIds.length}',
                  label: 'Ateliers',
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 12),
                SeanceStatChip(
                  icon: Icons.edit_note_rounded,
                  value: '0',
                  label: 'Annotations',
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      'Ajouter atelier',
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
                      'Fermer seance',
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
            'Aucune seance en cours',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ouvrez une seance pour commencer.',
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
  }

  Widget _buildCoachStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
        children: const [
          StatCard(
            label: 'Seances dirigees',
            value: '16',
            icon: Icons.sports_soccer_rounded,
            color: Color(0xFF3B82F6),
            trend: '+4',
            trendUp: true,
          ),
          StatCard(
            label: 'Annotations',
            value: '127',
            icon: Icons.edit_note_rounded,
            color: Color(0xFF8B5CF6),
            trend: '+23',
            trendUp: true,
          ),
          StatCard(
            label: 'Ateliers crees',
            value: '48',
            icon: Icons.fitness_center_rounded,
            color: Color(0xFFF59E0B),
            trend: '+8',
            trendUp: true,
          ),
          StatCard(
            label: 'Presence moy.',
            value: '89%',
            icon: Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            trend: '+2%',
            trendUp: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCoachQuickActions(BuildContext context) {
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
            title: 'Inscrire',
            description: 'Nouvel academicien',
            icon: Icons.person_add_rounded,
            color: const Color(0xFF10B981),
            badge: 'Go',
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
            title: 'Mes annotations',
            description: 'Evaluer un academicien',
            icon: Icons.edit_note_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () => widget.onNavigateToTab?.call(3),
          ),
          QuickActionTile(
            title: 'Mes ateliers',
            description: 'Gerer les exercices',
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFFF59E0B),
            onTap: _ouvrirAteliers,
          ),
          QuickActionTile(
            title: 'Presences',
            description: 'Scanner les arrivees',
            icon: Icons.qr_code_scanner_rounded,
            color: AppColors.primary,
            onTap: _ouvrirScanner,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademiciensList(ColorScheme colorScheme) {
    final academiciens = [
      AcademicienMini('Amadou K.', 'Avant-centre', const Color(0xFF3B82F6)),
      AcademicienMini('Ibrahim T.', 'Milieu', const Color(0xFF8B5CF6)),
      AcademicienMini('Moussa D.', 'Ailier', const Color(0xFF10B981)),
      AcademicienMini('Sekou C.', 'Defenseur', const Color(0xFFF59E0B)),
      AcademicienMini('Youssouf K.', 'Gardien', AppColors.primary),
      AcademicienMini('Bakary S.', 'Milieu def.', const Color(0xFF6366F1)),
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemCount: academiciens.length,
        itemBuilder: (context, index) {
          final acad = academiciens[index];
          return AcademicienMiniCard(data: acad);
        },
      ),
    );
  }

  Widget _buildCoachPerformance(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            children: const [
              CircularProgressWidget(
                progress: 0.89,
                label: 'Taux de\npresence',
                centerText: '89%',
                color: Color(0xFF10B981),
                size: 80,
                strokeWidth: 7,
              ),
              CircularProgressWidget(
                progress: 0.76,
                label: 'Annotations\npar seance',
                centerText: '7.6',
                color: Color(0xFF8B5CF6),
                size: 80,
                strokeWidth: 7,
              ),
              CircularProgressWidget(
                progress: 0.95,
                label: 'Seances\ncloturees',
                centerText: '95%',
                color: Color(0xFF3B82F6),
                size: 80,
                strokeWidth: 7,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExpBar(colorScheme),
        ],
      ),
    );
  }

  Widget _buildExpBar(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Niveau d\'activite',
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
                'Expert',
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
            value: 0.78,
            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '78% vers le niveau suivant',
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAnnotations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: const [
          ActivityCard(
            title: 'Amadou Keita - Dribbles',
            subtitle: 'Excellent controle de balle, progres constants.',
            time: 'Il y a 1h',
            icon: Icons.star_rounded,
            iconColor: Color(0xFFF59E0B),
          ),
          ActivityCard(
            title: 'Ibrahim Traore - Passes',
            subtitle:
                'Bonne vision du jeu, precis sur les transmissions longues.',
            time: 'Il y a 1h',
            icon: Icons.thumb_up_rounded,
            iconColor: Color(0xFF10B981),
          ),
          ActivityCard(
            title: 'Sekou Coulibaly - Defense',
            subtitle: 'Positionnement a travailler dans les duels aeriens.',
            time: 'Il y a 2h',
            icon: Icons.warning_rounded,
            iconColor: Color(0xFFF59E0B),
          ),
          ActivityCard(
            title: 'Moussa Diaby - Finition',
            subtitle: 'En net progres devant le but, frappe puissante.',
            time: 'Hier',
            icon: Icons.sports_soccer_rounded,
            iconColor: Color(0xFF3B82F6),
            isLast: true,
          ),
        ],
      ),
    );
  }
}
