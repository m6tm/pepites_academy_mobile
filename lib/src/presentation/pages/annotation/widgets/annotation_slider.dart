import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import 'annotation_rating_colors.dart';

class AnnotationSlider extends StatelessWidget {
  final String critereId;
  final String elementId;
  final String libelle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final bool isDark;

  const AnnotationSlider({
    super.key,
    required this.critereId,
    required this.elementId,
    required this.libelle,
    required this.value,
    this.min = 0,
    this.max = 5,
    this.divisions = 10,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sliderColor = getRatingColor(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                libelle,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
            RatingIndicator(note: value, size: 22),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: sliderColor,
            inactiveTrackColor: sliderColor.withValues(alpha: 0.15),
            thumbColor: sliderColor,
            overlayColor: sliderColor.withValues(alpha: 0.1),
            trackHeight: 3,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
