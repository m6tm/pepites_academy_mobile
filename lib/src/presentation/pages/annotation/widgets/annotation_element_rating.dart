import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/atelier.dart';
import '../../../../domain/entities/referentiel_evaluation_data.dart';
import '../../../theme/app_colors.dart';
import 'annotation_rating_colors.dart';
import 'annotation_slider.dart';

class AnnotationElementRating extends StatelessWidget {
  final ConfigurationElementEvaluation config;
  final double Function(String, String) getNote;
  final void Function(String, String, double) setNote;
  final bool isDark;

  const AnnotationElementRating({
    super.key,
    required this.config,
    required this.getNote,
    required this.setNote,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  critere.nom,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
              ),
              RatingBar(
                note: moyenne,
                maxNote: 5,
                width: 60,
                height: 6,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...resolvedElements.expand((e) => [
            AnnotationSlider(
              critereId: config.critereId,
              elementId: e.id,
              libelle: e.libelle,
              value: getNote(config.critereId, e.id),
              onChanged: (v) => setNote(config.critereId, e.id, v),
              isDark: isDark,
            ),
            const SizedBox(height: 8),
          ]).toList()..removeLast(),
        ],
      ),
    );
  }
}
