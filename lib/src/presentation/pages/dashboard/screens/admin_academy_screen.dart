import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../../presentation/widgets/section_title.dart';
import '../../../../injection_container.dart';
import '../../academy/academicien_list_page.dart';
import '../../encadreur/encadreur_list_page.dart';
import '../widgets/admin_internal_widgets.dart';

/// Ecran Academie du dashboard administrateur.
/// Gestion des academiciens et encadreurs avec recherche et statistiques.
class AdminAcademyScreen extends StatelessWidget {
  const AdminAcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcademicienListPage(
                            repository:
                                DependencyInjection.academicienRepository,
                          ),
                        ),
                      );
                    },
                    child: const MiniStatCard(
                      label: 'Total inscrits',
                      value: '47',
                      icon: Icons.people_rounded,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: MiniStatCard(
                    label: 'Actifs ce mois',
                    value: '42',
                    icon: Icons.trending_up_rounded,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
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
                    child: const MiniStatCard(
                      label: 'Encadreurs',
                      value: '8',
                      icon: Icons.sports_rounded,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SectionTitle(
            title: 'Academiciens recents',
            actionLabel: 'Voir tous',
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final academiciens = [
              AcademicienData('Amadou Keita', 'Avant-centre', 'CM2', 95),
              AcademicienData('Ibrahim Traore', 'Milieu offensif', '6eme', 88),
              AcademicienData('Moussa Diaby', 'Ailier droit', '5eme', 92),
              AcademicienData(
                'Sekou Coulibaly',
                'Defenseur central',
                '4eme',
                78,
              ),
              AcademicienData('Youssouf Kone', 'Gardien', 'CM1', 85),
            ];
            final data = academiciens[index];
            return AcademicienListItem(data: data);
          }, childCount: 5),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}
