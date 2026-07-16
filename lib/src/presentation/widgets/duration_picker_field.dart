import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';

import '../../../l10n/app_localizations.dart';

/// Champ de saisie d'une duree (de quelques minutes a plusieurs heures).
/// Champ en lecture seule qui ouvre un bottom sheet avec des raccourcis
/// (10 min a 2 h) et deux molettes heures/minutes (pas de 5 min).
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
    this.hint = 'Sélectionner une durée',
    required this.dureeMinutes,
    required this.onChanged,
    this.prefixIcon = Icons.schedule_rounded,
  });

  /// Durees frequentes proposees en raccourci (en minutes).
  static const List<int> _presets = [10, 15, 20, 30, 45, 60, 90, 120];

  /// Formate une duree en minutes vers une chaine lisible (ex. "30 min", "1 h 30").
  static String format(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h ${m.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDuration(BuildContext context) async {
    final current = dureeMinutes ?? 30;
    var hours = (current ~/ 60).clamp(0, 12);
    var minuteIndex = ((current % 60) / 5).round().clamp(0, 11);
    final hoursController = FixedExtentScrollController(initialItem: hours);
    final minutesController = FixedExtentScrollController(
      initialItem: minuteIndex,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final hintColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final total = hours * 60 + minuteIndex * 5;

            void selectTotal(int minutes) {
              setSheetState(() {
                hours = (minutes ~/ 60).clamp(0, 12);
                minuteIndex = ((minutes % 60) / 5).round().clamp(0, 11);
              });
              hoursController.jumpToItem(hours);
              minutesController.jumpToItem(minuteIndex);
            }

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: hintColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        format(total),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _presets.map((preset) {
                          final selected = total == preset;
                          return ChoiceChip(
                            label: Text(format(preset)),
                            selected: selected,
                            onSelected: (_) => selectTotal(preset),
                            selectedColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            labelStyle: TextStyle(
                              color: selected ? AppColors.primary : textColor,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildWheel(
                                controller: hoursController,
                                childCount: 13,
                                selectedIndex: hours,
                                suffix: 'h',
                                textColor: textColor,
                                hintColor: hintColor,
                                onSelected: (i) =>
                                    setSheetState(() => hours = i),
                              ),
                            ),
                            Expanded(
                              child: _buildWheel(
                                controller: minutesController,
                                childCount: 12,
                                selectedIndex: minuteIndex,
                                suffix: 'min',
                                step: 5,
                                textColor: textColor,
                                hintColor: hintColor,
                                onSelected: (i) =>
                                    setSheetState(() => minuteIndex = i),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.of(sheetContext).pop(),
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: TextStyle(color: hintColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: total == 0
                                  ? null
                                  : () => Navigator.of(
                                      sheetContext,
                                    ).pop(total),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.confirm,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    hoursController.dispose();
    minutesController.dispose();

    if (result != null) {
      onChanged(result);
    }
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int childCount,
    required int selectedIndex,
    required String suffix,
    required Color textColor,
    required Color hintColor,
    required ValueChanged<int> onSelected,
    int step = 1,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: childCount,
        builder: (context, index) {
          final selected = index == selectedIndex;
          return Center(
            child: Text(
              '${index * step} $suffix',
              style: TextStyle(
                color: selected ? AppColors.primary : hintColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: selected ? 18 : 15,
              ),
            ),
          );
        },
      ),
    );
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
