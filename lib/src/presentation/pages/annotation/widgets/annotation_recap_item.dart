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

    final resolvedElements = <({String id, String libelle})>[];
    for (final elementId in config.elementIds) {
      final element = critere.elements.where((e) => e.id == elementId).firstOrNull;
      if (element != null) {
        resolvedElements.add((id: element.id, libelle: element.libelle));
      }
    }

    if (resolvedElements.isEmpty) return const SizedBox.shrink();

    final notes = resolvedElements
        .map((e) => getNote(config.critereId, e.id))
        .toList();
    final moyenne = notes.isEmpty
        ? 0.0
        : notes.fold(0.0, (sum, n) => sum + n) / notes.length;

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
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: resolvedElements
                      .map((e) => _buildNoteLine(e.libelle, getNote(config.critereId, e.id)))
                      .toList(),
                ),
              ],
            ),
          ),
          RatingBar(
            note: moyenne,
            maxNote: 5,
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
