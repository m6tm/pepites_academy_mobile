import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/role.dart';
import '../theme/app_colors.dart';

/// Badge visuel pour afficher le rôle d'un utilisateur.
///
/// Ce widget affiche un badge coloré avec le nom du rôle,
/// adapté au thème clair/sombre de l'application.
class RoleBadge extends StatelessWidget {
  /// Le rôle à afficher.
  final Role role;

  /// Taille du badge.
  final RoleBadgeSize size;

  /// Si true, affiche uniquement l'icône sans le texte.
  final bool iconOnly;

  /// Callback optionnel lors du clic sur le badge.
  final VoidCallback? onTap;

  const RoleBadge({
    super.key,
    required this.role,
    this.size = RoleBadgeSize.medium,
    this.iconOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getRoleColors(role, isDark);
    final textStyle = _getTextStyle();
    final padding = _getPadding();
    final iconSize = _getIconSize();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(color: colors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: colors.background.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getRoleIcon(role),
              size: iconSize,
              color: colors.foreground,
            ),
            if (!iconOnly) ...[
              SizedBox(width: size == RoleBadgeSize.small ? 4 : 6),
              Text(
                _getRoleDisplayName(role),
                style: textStyle.copyWith(color: colors.foreground),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Retourne le nom d'affichage du rôle.
  String _getRoleDisplayName(Role role) {
    switch (role) {
      case Role.supAdmin:
        return 'SupAdmin';
      case Role.admin:
        return 'Admin';
      case Role.encadreurChef:
        return 'Enc. Chef';
      case Role.medecinChef:
        return 'Med. Chef';
      case Role.encadreur:
        return 'Encadreur';
      case Role.surveillantGeneral:
        return 'Surveillant';
      case Role.visiteur:
        return 'Visiteur';
    }
  }

  /// Retourne l'icône associée au rôle.
  IconData _getRoleIcon(Role role) {
    switch (role) {
      case Role.supAdmin:
        return Icons.admin_panel_settings;
      case Role.admin:
        return Icons.admin_panel_settings;
      case Role.encadreurChef:
        return Icons.sports_soccer;
      case Role.medecinChef:
        return Icons.medical_services;
      case Role.encadreur:
        return Icons.sports;
      case Role.surveillantGeneral:
        return Icons.security;
      case Role.visiteur:
        return Icons.visibility;
    }
  }

  /// Retourne les couleurs associées au rôle.
  _RoleColors _getRoleColors(Role role, bool isDark) {
    switch (role) {
      case Role.supAdmin:
        return _RoleColors(
          background: isDark
              ? const Color(0xFF7C3AED).withValues(alpha: 0.2)
              : const Color(0xFF7C3AED).withValues(alpha: 0.15),
          foreground: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
          border: isDark
              ? const Color(0xFF7C3AED).withValues(alpha: 0.4)
              : const Color(0xFF7C3AED).withValues(alpha: 0.3),
        );
      case Role.admin:
        return _RoleColors(
          background: isDark
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.12),
          foreground: isDark ? const Color(0xFFFCA5A5) : AppColors.primary,
          border: isDark
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.3),
        );
      case Role.encadreurChef:
        return _RoleColors(
          background: isDark
              ? const Color(0xFF059669).withValues(alpha: 0.2)
              : const Color(0xFF059669).withValues(alpha: 0.12),
          foreground: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
          border: isDark
              ? const Color(0xFF059669).withValues(alpha: 0.4)
              : const Color(0xFF059669).withValues(alpha: 0.3),
        );
      case Role.medecinChef:
        return _RoleColors(
          background: isDark
              ? const Color(0xFF0891B2).withValues(alpha: 0.2)
              : const Color(0xFF0891B2).withValues(alpha: 0.12),
          foreground: isDark ? const Color(0xFF67E8F9) : const Color(0xFF0891B2),
          border: isDark
              ? const Color(0xFF0891B2).withValues(alpha: 0.4)
              : const Color(0xFF0891B2).withValues(alpha: 0.3),
        );
      case Role.encadreur:
        return _RoleColors(
          background: isDark
              ? const Color(0xFFCA8A04).withValues(alpha: 0.2)
              : const Color(0xFFCA8A04).withValues(alpha: 0.12),
          foreground: isDark ? const Color(0xFFFDE047) : const Color(0xFFCA8A04),
          border: isDark
              ? const Color(0xFFCA8A04).withValues(alpha: 0.4)
              : const Color(0xFFCA8A04).withValues(alpha: 0.3),
        );
      case Role.surveillantGeneral:
        return _RoleColors(
          background: isDark
              ? const Color(0xFFDC2626).withValues(alpha: 0.2)
              : const Color(0xFFDC2626).withValues(alpha: 0.12),
          foreground: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
          border: isDark
              ? const Color(0xFFDC2626).withValues(alpha: 0.4)
              : const Color(0xFFDC2626).withValues(alpha: 0.3),
        );
      case Role.visiteur:
        return _RoleColors(
          background: isDark
              ? const Color(0xFF6B7280).withValues(alpha: 0.2)
              : const Color(0xFF6B7280).withValues(alpha: 0.12),
          foreground: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
          border: isDark
              ? const Color(0xFF6B7280).withValues(alpha: 0.4)
              : const Color(0xFF6B7280).withValues(alpha: 0.3),
        );
    }
  }

  /// Retourne le style de texte selon la taille.
  TextStyle _getTextStyle() {
    switch (size) {
      case RoleBadgeSize.small:
        return GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        );
      case RoleBadgeSize.medium:
        return GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );
      case RoleBadgeSize.large:
        return GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
    }
  }

  /// Retourne le padding selon la taille.
  EdgeInsets _getPadding() {
    switch (size) {
      case RoleBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
      case RoleBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
      case RoleBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
    }
  }

  /// Retourne la taille de l'icône selon la taille du badge.
  double _getIconSize() {
    switch (size) {
      case RoleBadgeSize.small:
        return 12;
      case RoleBadgeSize.medium:
        return 16;
      case RoleBadgeSize.large:
        return 20;
    }
  }

  /// Retourne le rayon de la bordure selon la taille.
  double _getBorderRadius() {
    switch (size) {
      case RoleBadgeSize.small:
        return 6;
      case RoleBadgeSize.medium:
        return 8;
      case RoleBadgeSize.large:
        return 12;
    }
  }
}

/// Tailles disponibles pour le badge de rôle.
enum RoleBadgeSize {
  /// Petit badge pour les listes compactes.
  small,

  /// Badge moyen pour les cartes et listes standard.
  medium,

  /// Grand badge pour les profils et en-têtes.
  large,
}

/// Classe interne pour les couleurs du badge.
class _RoleColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _RoleColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
