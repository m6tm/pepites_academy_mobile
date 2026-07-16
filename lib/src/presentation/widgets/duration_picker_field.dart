import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';

/// Champ de saisie d'une duree au format HH:MM.
/// Champ en lecture seule qui ouvre un [showTimePicker] au toucher.
/// La valeur est stockee en minutes totales.
class DurationPickerField extends StatelessWidget {
  final String label;
  final String hint;
  final int? dureeMinutes;
  final ValueChanged<int?> onChanged;
  final IconData prefixIcon;

  const DurationPickerField({
    super.key,
    required this.label,
    this.hint = '--:--',
    required this.dureeMinutes,
    required this.onChanged,
    this.prefixIcon = Icons.schedule_rounded,
  });

  /// Formate une duree en minutes vers une chaine HH:MM.
  static String format(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickDuration(BuildContext context) async {
    final current = dureeMinutes;
    final initial = current != null
        ? TimeOfDay(hour: (current ~/ 60).clamp(0, 23), minute: current % 60)
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        // Force le format 24h pour une saisie de duree.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      onChanged(picked.hour * 60 + picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final hintColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final hasValue = dureeMinutes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: baseColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: () => _pickDuration(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(prefixIcon, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasValue ? format(dureeMinutes!) : hint,
                          style: TextStyle(
                            color: hasValue ? textColor : hintColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (hasValue)
                        GestureDetector(
                          onTap: () => onChanged(null),
                          child: Icon(
                            Icons.close_rounded,
                            color: hintColor,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
