import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/seance_card.dart';

/// Ecran Seances du dashboard encadreur.
/// Liste des seances dirigees par l'encadreur.
class EncadreurSeancesScreen extends StatelessWidget {
  const EncadreurSeancesScreen({super.key});

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
}
