import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';

class GlassDropdown<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  const GlassDropdown({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.items = const [],
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final hintColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

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
              child: DropdownButtonFormField<T>(
                initialValue: value,
                items: items,
                onChanged: onChanged,
                validator: validator,
                dropdownColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                style: TextStyle(color: textColor),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: hintColor),
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon, color: AppColors.primary)
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  errorStyle: const TextStyle(
                    color: AppColors.error,
                    height: 0.8,
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
