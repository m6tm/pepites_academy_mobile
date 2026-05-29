import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../domain/entities/annotation.dart';
import '../../../theme/app_colors.dart';
import 'annotation_rating_colors.dart';

class AnnotationHistoriqueItem extends StatelessWidget {
  final Annotation annotation;
  final bool isDark;
  final bool showDate;
  final bool showCommentaire;

  const AnnotationHistoriqueItem({
    super.key,
    required this.annotation,
    required this.isDark,
    this.showDate = true,
    this.showCommentaire = true,
  });

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(annotation.horodate, context);
    final scoreTotal = annotation.scoreTotal;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showDate) ...[
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
              const Spacer(),
              RatingBar(
                note: scoreTotal,
                maxNote: 5,
                width: 60,
                height: 6,
              ),
            ],
          ),
          if (showCommentaire && annotation.contenu.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              annotation.contenu,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = intl.DateFormat('d MMM yyyy', locale).format(date);
    final heure = intl.DateFormat('HH:mm', locale).format(date);
    return '$dateStr - $heure';
  }
}