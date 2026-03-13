import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/atelier.dart';
import '../theme/app_colors.dart';

class AteliersProgressCard extends StatelessWidget {
  final List<Atelier> ateliers;

  const AteliersProgressCard({
    super.key,
    required this.ateliers,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = ateliers.length;
    final creeCount = ateliers.where((a) => a.statut == AtelierStatut.cree).length;
    final modifieCount = ateliers.where((a) => a.statut == AtelierStatut.modifie).length;
    final valideCount = ateliers.where((a) => a.statut == AtelierStatut.valide).length;
    final appliqueCount = ateliers.where((a) => a.statut == AtelierStatut.applique).length;
    final fermeCount = ateliers.where((a) => a.statut == AtelierStatut.ferme).length;

    // Progression: applied and closed are considered "progress"
    int progressed = appliqueCount + fermeCount;
    // We can also just count 'ferme' as 100% and 'applique' as 50% for the progress, but let's go with literal:
    double progress = total == 0 ? 0 : progressed / total;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression globale',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total: $total ateliers',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (creeCount > 0) _buildStatChip('Créés', creeCount, Colors.grey, isDark),
              if (modifieCount > 0) _buildStatChip('Modifiés', modifieCount, Colors.orange, isDark),
              if (valideCount > 0) _buildStatChip('Validés', valideCount, Colors.blue, isDark),
              if (appliqueCount > 0) _buildStatChip('Appliqués', appliqueCount, Colors.purple, isDark),
              if (fermeCount > 0) _buildStatChip('Fermés', fermeCount, Colors.green, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? color.withValues(alpha: 0.8) : color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
