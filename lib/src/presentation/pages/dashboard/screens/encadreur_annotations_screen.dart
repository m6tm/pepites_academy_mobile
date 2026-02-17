import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../widgets/encadreur_internal_widgets.dart';

/// Ecran Annotations du dashboard encadreur.
/// Observations et evaluations des academiciens avec filtres par tags.
class EncadreurAnnotationsScreen extends StatelessWidget {
  const EncadreurAnnotationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.annotationsScreenTitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.myObservationsSubtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: MiniAnnotCard(
                    label: l10n.totalLabel,
                    value: '127',
                    icon: Icons.edit_note_rounded,
                    color: const Color(0xFF8B5CF6),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniAnnotCard(
                    label: l10n.positivesLabel,
                    value: '89',
                    icon: Icons.thumb_up_rounded,
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniAnnotCard(
                    label: l10n.toWorkOnLabel,
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
        SliverToBoxAdapter(child: _buildAnnotationTags(context, colorScheme)),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final annotations = [
              AnnotationData(
                'Amadou Keita',
                'Dribbles - Entrainement Technique',
                'Excellent controle de balle. Les feintes de corps sont de plus en plus convaincantes.',
                ['Positif', 'Technique'],
                'Il y a 1h',
              ),
              AnnotationData(
                'Ibrahim Traore',
                'Passes - Entrainement Technique',
                'Bonne vision du jeu. Precis sur les transmissions longues, a travailler les passes filtrees.',
                ['Positif', 'Tactique'],
                'Il y a 1h',
              ),
              AnnotationData(
                'Sekou Coulibaly',
                'Defense - Entrainement Technique',
                'Positionnement a travailler. Duels aeriens insuffisants, bon placement au sol.',
                ['A travailler', 'Physique'],
                'Il y a 2h',
              ),
              AnnotationData(
                'Moussa Diaby',
                'Finition - Entrainement Technique',
                'En net progres devant le but. Frappe puissante du pied droit, a developper le pied gauche.',
                ['En progres', 'Technique'],
                'Hier',
              ),
            ];
            final data = annotations[index];
            return AnnotationListItem(data: data, isDark: isDark);
          }, childCount: 4),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAnnotationTags(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final tags = [
      (l10n.allTagFilter, true),
      (l10n.tagPositif, false),
      (l10n.inProgressTagFilter, false),
      (l10n.toWorkOnLabel, false),
      (l10n.techniqueTagFilter, false),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, index) => const SizedBox(width: 8),
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
}
