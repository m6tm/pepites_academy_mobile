import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../widgets/seance_card.dart';

/// Ecran Seances du dashboard administrateur.
/// Historique et suivi des entrainements avec filtres.
class AdminSeancesScreen extends StatelessWidget {
  const AdminSeancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        SliverToBoxAdapter(child: _buildSeanceFilters(colorScheme)),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
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
}
