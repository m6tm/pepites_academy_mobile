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

    final element1 = critere.elements
        .where((e) => e.id == config.element1Id)
        .firstOrNull;
    final element2 = critere.elements
        .where((e) => e.id == config.element2Id)
        .firstOrNull;

    if (element1 == null || element2 == null) return const SizedBox.shrink();

    final sousTotal = getNote(config.critereId, config.element1Id) +
                      getNote(config.critereId, config.element2Id);

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
                note: sousTotal,
                maxNote: 10,
                width: 60,
                height: 6,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnnotationSlider(
            critereId: config.critereId,
            elementId: element1.id,
            libelle: element1.libelle,
            value: getNote(config.critereId, element1.id),
            onChanged: (v) => setNote(config.critereId, element1.id, v),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          AnnotationSlider(
            critereId: config.critereId,
            elementId: element2.id,
            libelle: element2.libelle,
            value: getNote(config.critereId, element2.id),
            onChanged: (v) => setNote(config.critereId, element2.id, v),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
