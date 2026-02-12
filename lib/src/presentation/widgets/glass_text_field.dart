import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';

class GlassTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final TextInputAction? textInputAction;

  const GlassTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.textInputAction,
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
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                style: TextStyle(color: textColor),
                validator: validator,
                onChanged: onChanged,
                maxLines: maxLines,
                textInputAction: textInputAction,
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
