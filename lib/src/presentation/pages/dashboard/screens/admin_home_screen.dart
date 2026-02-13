import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../../presentation/widgets/stat_card.dart';
import '../../../../presentation/widgets/quick_action_tile.dart';
import '../../../../presentation/widgets/activity_card.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../../../../presentation/widgets/circular_progress_widget.dart';
import '../../../../injection_container.dart';
import '../../academy/academicien_registration_page.dart';
import '../../encadreur/encadreur_list_page.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/seance_card.dart';

/// Ecran d'accueil du dashboard administrateur.
/// Affiche la vue d'ensemble avec statistiques, actions rapides et activite recente.
class AdminHomeScreen extends StatelessWidget {
  final String userName;
  final String greeting;
  final ValueChanged<int>? onNavigateToTab;

  const AdminHomeScreen({
    super.key,
    required this.userName,
    required this.greeting,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: DashboardHeader(
            userName: userName,
            role: 'Administrateur',
            greeting: greeting,
            notificationCount: 3,
            onNotificationTap: () {},
            onProfileTap: () {},
          ),
        ),
        SliverToBoxAdapter(child: _buildWelcomeBanner(colorScheme)),
        const SliverToBoxAdapter(child: SectionTitle(title: 'Vue d\'ensemble')),
        SliverToBoxAdapter(child: _buildStatsGrid()),
        const SliverToBoxAdapter(child: SectionTitle(title: 'Actions rapides')),
        SliverToBoxAdapter(child: _buildQuickActions(context)),
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
        const SliverToBoxAdapter(
          child: SectionTitle(title: 'Performance globale'),
        ),
        SliverToBoxAdapter(
          child: _buildPerformanceSection(context, colorScheme),
        ),
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

  Widget _buildQuickActions(BuildContext context) {
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
                  builder: (context) => const AcademicienRegistrationPage(),
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
            title: 'Joueurs',
            description: 'Liste des academiciens',
            icon: Icons.sports_soccer_rounded,
            color: const Color(0xFF10B981),
            onTap: () {
              onNavigateToTab?.call(1);
            },
          ),
          QuickActionTile(
            title: 'Encadreurs',
            description: 'Gestion des coachs',
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
  ) {
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
}
