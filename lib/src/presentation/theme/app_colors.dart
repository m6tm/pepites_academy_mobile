import 'package:flutter/material.dart';

/// Classe regroupant toutes les constantes de couleurs de l'application
/// Basé sur la charte graphique de Pépites Academy.
class AppColors {
  // Couleurs de base (Brand Colors)
  static const Color primary = Color(0xFFC8102E); // Rouge vif académie
  static const Color secondary = Color(0xFFE3425C); // Rouge clair / Hover
  static const Color accent = Color(0xFF1C1C1C); // Anthracite pour le contraste

  // Mode Clair (Light Mode)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F8F8);
  static const Color surfaceHighlightLight = Color(0xFFF0F0F0);
  static const Color textMainLight = Color(0xFF1C1C1C);
  static const Color textMutedLight = Color(0xFF666666);

  // Mode Sombre (Dark Mode)
  static const Color backgroundDark = Color(0xFF1C1C1C);
  static const Color surfaceDark = Color(0xFF262626);
  static const Color surfaceHighlightDark = Color(0xFF333333);
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textMutedDark = Color(0xFFA3A3A3);

  // Status Colors (Approximations OKLCH)
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF1C40F);
  static const Color error = Color(0xFFE74C3C);
}
