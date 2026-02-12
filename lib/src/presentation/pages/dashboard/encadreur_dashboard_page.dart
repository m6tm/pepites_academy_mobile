import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/widgets/stat_card.dart';
import '../../../presentation/widgets/quick_action_tile.dart';
import '../../../presentation/widgets/activity_card.dart';
import '../../../presentation/widgets/section_title.dart';
import '../../../presentation/widgets/circular_progress_widget.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/seance_card.dart';

/// Dashboard principal pour le profil Encadreur (Coach).
/// Optimise pour le travail terrain : seances, ateliers, annotations, scan QR.
class EncadreurDashboardPage extends StatefulWidget {
  final String userName;

  const EncadreurDashboardPage({super.key, this.userName = 'Coach'});

  @override
  State<EncadreurDashboardPage> createState() => _EncadreurDashboardPageState();
}

class _EncadreurDashboardPageState extends State<EncadreurDashboardPage>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon apres-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _selectedNavIndex,
            children: [
              _buildHomePage(colorScheme),
              _buildSeancesPage(colorScheme),
              const SizedBox(), // Placeholder pour Scanner QR (bouton central)
              _buildAnnotationsPage(colorScheme),
              _buildProfilePage(colorScheme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(colorScheme),
      floatingActionButton: _selectedNavIndex == 2 ? null : _buildScanFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Bouton flottant central "Scanner QR"
  Widget _buildScanFAB() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: FloatingActionButton.large(
        onPressed: () {
          setState(() => _selectedNavIndex = 2);
        },
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: const CircleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 2),
            Text(
              'SCAN',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Page d'accueil Encadreur
  Widget _buildHomePage(ColorScheme colorScheme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // En-tete
        SliverToBoxAdapter(
          child: DashboardHeader(
            userName: widget.userName,
            role: 'Encadreur',
            greeting: _getGreeting(),
            notificationCount: 1,
            onNotificationTap: () {},
            onProfileTap: () {},
          ),
        ),

        // Banniere terrain
        SliverToBoxAdapter(child: _buildTerrainBanner(colorScheme)),

        // Seance en cours / Prochaine seance
        SliverToBoxAdapter(child: _buildCurrentSeanceCard(colorScheme)),

        // Statistiques terrain
        const SliverToBoxAdapter(child: SectionTitle(title: 'Mon activite')),
        SliverToBoxAdapter(child: _buildCoachStats()),

        // Actions rapides
        const SliverToBoxAdapter(child: SectionTitle(title: 'Actions terrain')),
        SliverToBoxAdapter(child: _buildCoachQuickActions()),

        // Academiciens sous supervision
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Mes academiciens',
            actionLabel: 'Tout voir',
          ),
        ),
        SliverToBoxAdapter(child: _buildAcademiciensList(colorScheme)),

        // Mes performances en tant qu'encadreur
        const SliverToBoxAdapter(child: SectionTitle(title: 'Mes indicateurs')),
        SliverToBoxAdapter(child: _buildCoachPerformance(colorScheme)),

        // Dernieres annotations
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

  /// Banniere terrain style sport tech
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

  /// Carte de la seance en cours
  Widget _buildCurrentSeanceCard(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                '15:00 - 17:00',
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
            'Entrainement Technique',
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Statistiques de la seance
          Row(
            children: [
              _SeanceStatChip(
                icon: Icons.people_rounded,
                value: '18',
                label: 'Presents',
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 12),
              _SeanceStatChip(
                icon: Icons.sports_soccer_rounded,
                value: '4',
                label: 'Ateliers',
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 12),
              _SeanceStatChip(
                icon: Icons.edit_note_rounded,
                value: '12',
                label: 'Annotations',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Boutons d'action
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
                  onPressed: () {},
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
    );
  }

  /// Statistiques du coach
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

  /// Actions rapides terrain
  Widget _buildCoachQuickActions() {
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
            title: 'Ouvrir seance',
            description: 'Demarrer un entrainement',
            icon: Icons.play_circle_rounded,
            color: const Color(0xFF10B981),
            badge: 'Go',
            onTap: () {},
          ),
          QuickActionTile(
            title: 'Annoter',
            description: 'Evaluer un academicien',
            icon: Icons.edit_note_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () {},
          ),
          QuickActionTile(
            title: 'Mes ateliers',
            description: 'Gerer les exercices',
            icon: Icons.fitness_center_rounded,
            color: const Color(0xFFF59E0B),
            onTap: () {},
          ),
          QuickActionTile(
            title: 'Presences',
            description: 'Scanner les arrivees',
            icon: Icons.qr_code_scanner_rounded,
            color: AppColors.primary,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Liste horizontale des academiciens
  Widget _buildAcademiciensList(ColorScheme colorScheme) {
    final academiciens = [
      _AcademicienMini('Amadou K.', 'Avant-centre', const Color(0xFF3B82F6)),
      _AcademicienMini('Ibrahim T.', 'Milieu', const Color(0xFF8B5CF6)),
      _AcademicienMini('Moussa D.', 'Ailier', const Color(0xFF10B981)),
      _AcademicienMini('Sekou C.', 'Defenseur', const Color(0xFFF59E0B)),
      _AcademicienMini('Youssouf K.', 'Gardien', AppColors.primary),
      _AcademicienMini('Bakary S.', 'Milieu def.', const Color(0xFF6366F1)),
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
          return _AcademicienMiniCard(data: acad);
        },
      ),
    );
  }

  /// Indicateurs de performance encadreur
  Widget _buildCoachPerformance(ColorScheme colorScheme) {
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
          // Barre de progression "Experience"
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

  /// Dernieres annotations
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

  /// Page Seances de l'encadreur
  Widget _buildSeancesPage(ColorScheme colorScheme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes seances',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seances que j\'ai dirigees',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Seances
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Entrainement Technique',
            date: '12 Fev 2026',
            heureDebut: '15:00',
            heureFin: '17:00',
            encadreur: 'Moi',
            nbPresents: 18,
            nbAteliers: 4,
            status: SeanceCardStatus.enCours,
          ),
        ),
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Tactique & Jeu collectif',
            date: '10 Fev 2026',
            heureDebut: '15:30',
            heureFin: '17:30',
            encadreur: 'Moi',
            nbPresents: 20,
            nbAteliers: 5,
            status: SeanceCardStatus.terminee,
          ),
        ),
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Circuit Physique',
            date: '8 Fev 2026',
            heureDebut: '14:00',
            heureFin: '16:00',
            encadreur: 'Moi',
            nbPresents: 16,
            nbAteliers: 6,
            status: SeanceCardStatus.terminee,
          ),
        ),
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Technique Individuelle',
            date: '6 Fev 2026',
            heureDebut: '15:00',
            heureFin: '17:00',
            encadreur: 'Moi',
            nbPresents: 19,
            nbAteliers: 4,
            status: SeanceCardStatus.terminee,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  /// Page Annotations de l'encadreur
  Widget _buildAnnotationsPage(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Annotations',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mes observations et evaluations',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Statistiques d'annotations
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _MiniAnnotCard(
                    label: 'Total',
                    value: '127',
                    icon: Icons.edit_note_rounded,
                    color: const Color(0xFF8B5CF6),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniAnnotCard(
                    label: 'Positives',
                    value: '89',
                    icon: Icons.thumb_up_rounded,
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniAnnotCard(
                    label: 'A travailler',
                    value: '38',
                    icon: Icons.warning_rounded,
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Filtres par tags
        SliverToBoxAdapter(child: _buildAnnotationTags(colorScheme)),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        // Liste d'annotations
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final annotations = [
              _AnnotationData(
                'Amadou Keita',
                'Dribbles - Entrainement Technique',
                'Excellent controle de balle. Les feintes de corps sont de plus en plus convaincantes.',
                ['Positif', 'Technique'],
                'Il y a 1h',
              ),
              _AnnotationData(
                'Ibrahim Traore',
                'Passes - Entrainement Technique',
                'Bonne vision du jeu. Precis sur les transmissions longues, a travailler les passes filtrees.',
                ['Positif', 'Tactique'],
                'Il y a 1h',
              ),
              _AnnotationData(
                'Sekou Coulibaly',
                'Defense - Entrainement Technique',
                'Positionnement a travailler. Duels aeriens insuffisants, bon placement au sol.',
                ['A travailler', 'Physique'],
                'Il y a 2h',
              ),
              _AnnotationData(
                'Moussa Diaby',
                'Finition - Entrainement Technique',
                'En net progres devant le but. Frappe puissante du pied droit, a developper le pied gauche.',
                ['En progres', 'Technique'],
                'Hier',
              ),
            ];
            final data = annotations[index];
            return _AnnotationListItem(data: data, isDark: isDark);
          }, childCount: 4),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAnnotationTags(ColorScheme colorScheme) {
    final tags = [
      ('Tous', true),
      ('Positif', false),
      ('En progres', false),
      ('A travailler', false),
      ('Technique', false),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, _a) => const SizedBox(width: 8),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final (label, isSelected) = tags[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B5CF6) : colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? null
                  : Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Page profil encadreur
  Widget _buildProfilePage(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mon profil',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Carte profil
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.userName[0].toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.userName,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'coach@pepites.com',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ENCADREUR - Technique',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Statistiques rapides
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _ProfileStat(value: '16', label: 'Seances', isDark: isDark),
                _ProfileStat(
                  value: '127',
                  label: 'Annotations',
                  isDark: isDark,
                ),
                _ProfileStat(value: '48', label: 'Ateliers', isDark: isDark),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Parametres
        SliverToBoxAdapter(child: _buildCoachSettings(colorScheme)),
        // Deconnexion
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                'Se deconnecter',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildCoachSettings(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            _SettingsTile(
              icon: Icons.dark_mode_rounded,
              label: 'Theme',
              value: 'Systeme',
              color: const Color(0xFF8B5CF6),
            ),
            Divider(
              height: 1,
              indent: 60,
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              value: 'Activees',
              color: const Color(0xFFF59E0B),
            ),
            Divider(
              height: 1,
              indent: 60,
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'A propos',
              value: 'Version 1.0.0',
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Barre de navigation inferieure encadreur
  Widget _buildBottomNav(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _CoachNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Accueil',
                isSelected: _selectedNavIndex == 0,
                onTap: () => setState(() => _selectedNavIndex = 0),
              ),
              _CoachNavItem(
                icon: Icons.sports_soccer_rounded,
                label: 'Seances',
                isSelected: _selectedNavIndex == 1,
                onTap: () => setState(() => _selectedNavIndex = 1),
              ),
              // Espace central pour le FAB
              const Expanded(child: SizedBox()),
              _CoachNavItem(
                icon: Icons.edit_note_rounded,
                label: 'Annotations',
                isSelected: _selectedNavIndex == 3,
                onTap: () => setState(() => _selectedNavIndex = 3),
              ),
              _CoachNavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isSelected: _selectedNavIndex == 4,
                onTap: () => setState(() => _selectedNavIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widgets internes Encadreur ---

class _CoachNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CoachNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeanceStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SeanceStatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicienMini {
  final String nom;
  final String poste;
  final Color color;

  _AcademicienMini(this.nom, this.poste, this.color);
}

class _AcademicienMiniCard extends StatelessWidget {
  final _AcademicienMini data;

  const _AcademicienMiniCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.color.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                data.nom[0],
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: data.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.nom,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            data.poste,
            style: GoogleFonts.montserrat(
              fontSize: 9,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniAnnotCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MiniAnnotCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnnotationData {
  final String academicien;
  final String atelier;
  final String contenu;
  final List<String> tags;
  final String time;

  _AnnotationData(
    this.academicien,
    this.atelier,
    this.contenu,
    this.tags,
    this.time,
  );
}

class _AnnotationListItem extends StatelessWidget {
  final _AnnotationData data;
  final bool isDark;

  const _AnnotationListItem({required this.data, required this.isDark});

  Color _tagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'positif':
        return const Color(0xFF10B981);
      case 'en progres':
        return const Color(0xFF3B82F6);
      case 'a travailler':
        return const Color(0xFFF59E0B);
      case 'technique':
        return const Color(0xFF8B5CF6);
      case 'tactique':
        return const Color(0xFF6366F1);
      case 'physique':
        return AppColors.primary;
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    data.academicien[0],
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.academicien,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      data.atelier,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                data.time,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.contenu,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: data.tags.map((tag) {
              final color = _tagColor(tag);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurface.withValues(alpha: 0.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
