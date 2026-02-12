import 'dart:ui';
import 'package:flutter/material.dart';

/// Carte avec effet Glassmorphism (verre dépoli).
/// Utilisable comme conteneur premium dans les dashboards.
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final double borderOpacity;
  final VoidCallback? onTap;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurSigma = 10,
    this.backgroundColor,
    this.backgroundOpacity = 0.08,
    this.borderOpacity = 0.15,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = backgroundColor ?? (isDark ? Colors.white : Colors.black);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: backgroundOpacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: baseColor.withValues(alpha: borderOpacity),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
