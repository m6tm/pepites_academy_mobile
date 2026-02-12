import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../injection_container.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/widgets/stat_card.dart';
import '../../../presentation/widgets/quick_action_tile.dart';
import '../../../presentation/widgets/activity_card.dart';
import '../../../presentation/widgets/section_title.dart';
import '../../../presentation/widgets/circular_progress_widget.dart';
import '../academy/registration/registration_page.dart';
import '../auth/login_page.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/seance_card.dart';

/// Dashboard principal pour le profil Administrateur.
/// Offre une vue d'ensemble complete de l'academie avec acces a toutes les fonctionnalites.
class AdminDashboardPage extends StatefulWidget {
  final String userName;

  const AdminDashboardPage({super.key, this.userName = 'Administrateur'});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _selectedNavIndex,
            children: [
              _buildHomePage(colorScheme),
              _buildAcademyPage(colorScheme),
              _buildSeancesPage(colorScheme),
              _buildCommunicationPage(colorScheme),
              _buildSettingsPage(colorScheme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(colorScheme),
    );
  }

  //... (other imports)

  /// Gestion de la déconnexion avec confirmation
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Déconnexion',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Clear session
                await DependencyInjection.preferences.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                'Déconnecter',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Page d'accueil du Dashboard Admin
  Widget _buildHomePage(ColorScheme colorScheme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // En-tete
        SliverToBoxAdapter(
          child: DashboardHeader(
            userName: widget.userName,
            role: 'Administrateur',
            greeting: _getGreeting(),
            notificationCount: 3,
            onNotificationTap: () {},
            onProfileTap: () {},
          ),
        ),

        // Banniere de bienvenue
        SliverToBoxAdapter(child: _buildWelcomeBanner(colorScheme)),

        // Statistiques principales
        const SliverToBoxAdapter(child: SectionTitle(title: 'Vue d\'ensemble')),
        SliverToBoxAdapter(child: _buildStatsGrid()),

        // Actions rapides
        const SliverToBoxAdapter(child: SectionTitle(title: 'Actions rapides')),
        SliverToBoxAdapter(child: _buildQuickActions()),

        // Seance en cours
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Seance du jour',
            actionLabel: 'Historique',
          ),
        ),
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Entrainement Technique',
            date: '12 Fev 2026',
            heureDebut: '15:00',
            heureFin: '17:00',
            encadreur: 'Coach Mamadou Diallo',
            nbPresents: 18,
            nbAteliers: 4,
            status: SeanceCardStatus.enCours,
          ),
        ),

        // Performance globale
        const SliverToBoxAdapter(
          child: SectionTitle(title: 'Performance globale'),
        ),
        SliverToBoxAdapter(child: _buildPerformanceSection(colorScheme)),

        // Activites recentes
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Activite recente',
            actionLabel: 'Tout voir',
          ),
        ),
        SliverToBoxAdapter(child: _buildRecentActivity()),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  /// Banniere de bienvenue avec gradient
  Widget _buildWelcomeBanner(ColorScheme colorScheme) {
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
                    'ADMINISTRATEUR',
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
                  'Gerez l\'ensemble de votre academie depuis cet espace centralise.',
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

  /// Grille de statistiques principales
  Widget _buildStatsGrid() {
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
            label: 'Academiciens',
            value: '47',
            icon: Icons.school_rounded,
            color: Color(0xFF3B82F6),
            trend: '+5',
            trendUp: true,
          ),
          StatCard(
            label: 'Encadreurs',
            value: '8',
            icon: Icons.sports_rounded,
            color: Color(0xFF8B5CF6),
            trend: '+1',
            trendUp: true,
          ),
          StatCard(
            label: 'Seances (mois)',
            value: '24',
            icon: Icons.calendar_today_rounded,
            color: AppColors.primary,
            trend: '+12%',
            trendUp: true,
          ),
          StatCard(
            label: 'Taux presence',
            value: '87%',
            icon: Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            trend: '+3%',
            trendUp: true,
          ),
        ],
      ),
    );
  }

  /// Actions rapides de l'admin
  Widget _buildQuickActions() {
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
            color: const Color(0xFF3B82F6),
            badge: 'Nouveau',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AcademyRegistrationPage(),
                ),
              );
            },
          ),
          QuickActionTile(
            title: 'Scanner QR',
            description: 'Controle d\'acces',
            icon: Icons.qr_code_scanner_rounded,
            color: AppColors.primary,
            onTap: () {},
          ),
          QuickActionTile(
            title: 'Envoyer SMS',
            description: 'Communication groupee',
            icon: Icons.sms_rounded,
            color: const Color(0xFF10B981),
            badge: '3',
            onTap: () {},
          ),
          QuickActionTile(
            title: 'Referentiels',
            description: 'Postes & Niveaux',
            icon: Icons.tune_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Section de performance globale avec indicateurs circulaires
  Widget _buildPerformanceSection(ColorScheme colorScheme) {
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
                progress: 0.87,
                label: 'Presence\nmoyenne',
                centerText: '87%',
                color: Color(0xFF10B981),
                size: 80,
                strokeWidth: 7,
              ),
              CircularProgressWidget(
                progress: 0.74,
                label: 'Objectifs\natteints',
                centerText: '74%',
                color: Color(0xFF3B82F6),
                size: 80,
                strokeWidth: 7,
              ),
              CircularProgressWidget(
                progress: 0.92,
                label: 'Satisfaction\nencadreurs',
                centerText: '92%',
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
                    'Tendance positive : +8% de presence en Fevrier par rapport a Janvier.',
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

  /// Activite recente
  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: const [
          ActivityCard(
            title: 'Seance ouverte',
            subtitle: 'Entrainement Technique - Coach Mamadou',
            time: 'Il y a 2h',
            icon: Icons.play_circle_outline_rounded,
            iconColor: Color(0xFF10B981),
          ),
          ActivityCard(
            title: 'Nouvel academicien',
            subtitle: 'Amadou Keita inscrit avec succes',
            time: 'Il y a 3h',
            icon: Icons.person_add_outlined,
            iconColor: Color(0xFF3B82F6),
          ),
          ActivityCard(
            title: 'SMS envoye',
            subtitle: '15 academiciens notifies pour le match amical',
            time: 'Hier',
            icon: Icons.sms_outlined,
            iconColor: Color(0xFF8B5CF6),
          ),
          ActivityCard(
            title: 'Bulletin genere',
            subtitle: 'Bulletin trimestriel de Moussa Diaby',
            time: 'Hier',
            icon: Icons.description_outlined,
            iconColor: AppColors.primary,
          ),
          ActivityCard(
            title: 'Referentiel mis a jour',
            subtitle: 'Nouveau poste: Milieu relayeur',
            time: '2 jours',
            icon: Icons.tune_rounded,
            iconColor: Color(0xFFF59E0B),
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Page Academie (onglet 2)
  Widget _buildAcademyPage(ColorScheme colorScheme) {
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
                  'Academie',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestion des academiciens et encadreurs',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Barre de recherche
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un academicien, encadreur...',
                        hintStyle: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Grille de stats
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    label: 'Total inscrits',
                    value: '47',
                    icon: Icons.people_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Actifs ce mois',
                    value: '42',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Encadreurs',
                    value: '8',
                    icon: Icons.sports_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Liste des academiciens
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Academiciens recents',
            actionLabel: 'Voir tous',
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final academiciens = [
              _AcademicienData('Amadou Keita', 'Avant-centre', 'CM2', 95),
              _AcademicienData('Ibrahim Traore', 'Milieu offensif', '6eme', 88),
              _AcademicienData('Moussa Diaby', 'Ailier droit', '5eme', 92),
              _AcademicienData(
                'Sekou Coulibaly',
                'Defenseur central',
                '4eme',
                78,
              ),
              _AcademicienData('Youssouf Kone', 'Gardien', 'CM1', 85),
            ];
            final data = academiciens[index];
            return _AcademicienListItem(data: data);
          }, childCount: 5),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  /// Page Seances (onglet 3)
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
                      'Seances',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Historique et suivi des entrainements',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Filtres
        SliverToBoxAdapter(child: _buildSeanceFilters(colorScheme)),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        // Liste des seances
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Entrainement Technique',
            date: '12 Fev 2026',
            heureDebut: '15:00',
            heureFin: '17:00',
            encadreur: 'Coach Mamadou Diallo',
            nbPresents: 18,
            nbAteliers: 4,
            status: SeanceCardStatus.enCours,
          ),
        ),
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Physique & Endurance',
            date: '11 Fev 2026',
            heureDebut: '14:00',
            heureFin: '16:00',
            encadreur: 'Coach Fatou Camara',
            nbPresents: 22,
            nbAteliers: 3,
            status: SeanceCardStatus.terminee,
          ),
        ),
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Tactique & Jeu collectif',
            date: '10 Fev 2026',
            heureDebut: '15:30',
            heureFin: '17:30',
            encadreur: 'Coach Mamadou Diallo',
            nbPresents: 20,
            nbAteliers: 5,
            status: SeanceCardStatus.terminee,
          ),
        ),
        SliverToBoxAdapter(
          child: SeanceCard(
            title: 'Gardiens - Special arrets',
            date: '13 Fev 2026',
            heureDebut: '16:00',
            heureFin: '17:30',
            encadreur: 'Coach Ali Toure',
            nbPresents: 0,
            nbAteliers: 0,
            status: SeanceCardStatus.aVenir,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildSeanceFilters(ColorScheme colorScheme) {
    final filters = ['Toutes', 'En cours', 'Terminees', 'A venir'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
            ),
            child: Center(
              child: Text(
                filters[index],
                style: GoogleFonts.montserrat(
                  fontSize: 13,
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

  /// Page Communication (onglet 4)
  Widget _buildCommunicationPage(ColorScheme colorScheme) {
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
                  'Communication',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SMS et notifications',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Statistiques SMS
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    label: 'Envoyes',
                    value: '128',
                    icon: Icons.send_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    label: 'Ce mois',
                    value: '34',
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    label: 'En echec',
                    value: '2',
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Actions de communication
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _CommunicationAction(
                  title: 'Nouveau message',
                  subtitle: 'Rediger et envoyer un SMS',
                  icon: Icons.edit_rounded,
                  color: AppColors.primary,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _CommunicationAction(
                  title: 'Message groupe',
                  subtitle: 'Envoyer a un groupe filtre',
                  icon: Icons.group_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _CommunicationAction(
                  title: 'Historique SMS',
                  subtitle: 'Consulter les messages envoyes',
                  icon: Icons.history_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        // Derniers SMS
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Derniers messages',
            actionLabel: 'Historique',
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final messages = [
              _SmsData(
                'Rappel entrainement',
                '15 destinataires',
                '12 Fev',
                true,
              ),
              _SmsData(
                'Match amical samedi',
                '22 destinataires',
                '11 Fev',
                true,
              ),
              _SmsData(
                'Changement horaire',
                '8 destinataires',
                '10 Fev',
                false,
              ),
            ];
            final msg = messages[index];
            return _SmsListItem(data: msg, isDark: isDark);
          }, childCount: 3),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  /// Page Parametres (onglet 5)
  Widget _buildSettingsPage(ColorScheme colorScheme) {
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
                  'Parametres',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configuration de l\'application',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Profil
        SliverToBoxAdapter(child: _buildProfileCard(colorScheme)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Options
        SliverToBoxAdapter(
          child: _buildSettingsSection('General', [
            _SettingsItem(
              Icons.language_rounded,
              'Langue',
              'Francais',
              const Color(0xFF3B82F6),
            ),
            _SettingsItem(
              Icons.dark_mode_rounded,
              'Theme',
              'Systeme',
              const Color(0xFF8B5CF6),
            ),
            _SettingsItem(
              Icons.notifications_outlined,
              'Notifications',
              'Activees',
              const Color(0xFFF59E0B),
            ),
          ], colorScheme),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: _buildSettingsSection('Administration', [
            _SettingsItem(
              Icons.tune_rounded,
              'Referentiels',
              'Postes, Niveaux',
              const Color(0xFF10B981),
            ),
            _SettingsItem(
              Icons.backup_rounded,
              'Sauvegarde',
              'Derniere: Aujourd\'hui',
              const Color(0xFF3B82F6),
            ),
            _SettingsItem(
              Icons.info_outline_rounded,
              'A propos',
              'Version 1.0.0',
              colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ], colorScheme),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Bouton de deconnexion
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
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
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildProfileCard(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF2D1215)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Center(
              child: Text(
                widget.userName[0].toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'admin@pepites.com',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ADMIN',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    List<_SettingsItem> items,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      title: Text(
                        item.label,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        item.value,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 60,
                        color: colorScheme.onSurface.withValues(alpha: 0.05),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de navigation inferieure
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
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Accueil',
                isSelected: _selectedNavIndex == 0,
                onTap: () => setState(() => _selectedNavIndex = 0),
              ),
              _NavItem(
                icon: Icons.school_rounded,
                label: 'Academie',
                isSelected: _selectedNavIndex == 1,
                onTap: () => setState(() => _selectedNavIndex = 1),
              ),
              _NavItem(
                icon: Icons.sports_soccer_rounded,
                label: 'Seances',
                isSelected: _selectedNavIndex == 2,
                onTap: () => setState(() => _selectedNavIndex = 2),
              ),
              _NavItem(
                icon: Icons.sms_rounded,
                label: 'SMS',
                isSelected: _selectedNavIndex == 3,
                badge: '3',
                onTap: () => setState(() => _selectedNavIndex = 3),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Reglages',
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

// --- Widgets internes ----

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
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
                  if (badge != null)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

class _AcademicienData {
  final String nom;
  final String poste;
  final String niveau;
  final int presence;

  _AcademicienData(this.nom, this.poste, this.niveau, this.presence);
}

class _AcademicienListItem extends StatelessWidget {
  final _AcademicienData data;

  const _AcademicienListItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                data.nom[0],
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.nom,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${data.poste} - ${data.niveau}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: data.presence >= 90
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : data.presence >= 80
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${data.presence}%',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: data.presence >= 90
                    ? const Color(0xFF10B981)
                    : data.presence >= 80
                    ? const Color(0xFFF59E0B)
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunicationAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _CommunicationAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmsData {
  final String title;
  final String recipients;
  final String date;
  final bool success;

  _SmsData(this.title, this.recipients, this.date, this.success);
}

class _SmsListItem extends StatelessWidget {
  final _SmsData data;
  final bool isDark;

  const _SmsListItem({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.success
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: data.success ? const Color(0xFF10B981) : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  data.recipients,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.date,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _SettingsItem(this.icon, this.label, this.value, this.color);
}
