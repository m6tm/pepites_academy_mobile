import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/atelier.dart';
import '../../../../domain/entities/referentiel_evaluation_data.dart';
import '../../../theme/app_colors.dart';
import 'annotation_rating_colors.dart';

class AnnotationRecapItem extends StatelessWidget {
  final ConfigurationElementEvaluation config;
  final double Function(String, String) getNote;
  final bool isDark;

  const AnnotationRecapItem({
    super.key,
    required this.config,
    required this.getNote,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final critere = ReferentielEvaluationData.criteres
        .where((c) => c.id == config.critereId)
        .firstOrNull;
    if (critere == null) return const SizedBox.shrink();

    final element1 = critere.elements
        .where((e) => e.id == config.element1Id)
        .firstOrNull;
    final element2 = critere.elements
        .where((e) => e.id == config.element2Id)
        .firstOrNull;

    if (element1 == null || element2 == null) return const SizedBox.shrink();

    final note1 = getNote(config.critereId, config.element1Id);
    final note2 = getNote(config.critereId, config.element2Id);
    final sousTotal = note1 + note2;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  critere.nom,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildNoteLine(element1.libelle, note1),
                    const SizedBox(width: 12),
                    _buildNoteLine(element2.libelle, note2),
                  ],
                ),
              ],
            ),
          ),
          RatingBar(
            note: sousTotal,
            maxNote: 10,
            width: 50,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteLine(String libelle, double note) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          libelle,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        RatingIndicator(note: note, size: 16),
      ],
    );
  }
}
