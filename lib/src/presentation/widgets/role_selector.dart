import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/permission.dart';
import '../../injection_container.dart';
import '../theme/app_colors.dart';
import 'role_badge.dart';

/// Sélecteur de rôle pour les formulaires.
///
/// Ce widget affiche un dropdown stylisé permettant de sélectionner un rôle.
/// Il peut filtrer les rôles selon les permissions de l'utilisateur actuel
/// (ex: un admin ne peut attribuer que des rôles de niveau inférieur ou égal).
class RoleSelector extends StatelessWidget {
  /// Le rôle actuellement sélectionné.
  final Role? selectedRole;

  /// Callback appelé lors du changement de rôle.
  final void Function(Role?)? onChanged;

  /// Label affiché au-dessus du sélecteur.
  final String label;

  /// Texte d'indication affiché quand aucun rôle n'est sélectionné.
  final String? hint;

  /// Validateur pour le champ.
  final String? Function(Role?)? validator;

  /// Si true, filtre les rôles pour n'afficher que ceux attribuables
  /// par l'utilisateur actuel (rôles de niveau inférieur ou égal).
  final bool filterByAssignable;

  /// Si true, le sélecteur est désactivé.
  final bool enabled;

  /// Liste personnalisée de rôles à afficher (remplace le filtrage automatique).
  final List<Role>? availableRoles;

  const RoleSelector({
    super.key,
    this.selectedRole,
    this.onChanged,
    this.label = 'Rôle',
    this.hint,
    this.validator,
    this.filterByAssignable = true,
    this.enabled = true,
    this.availableRoles,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final hintColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final baseColor = isDark ? Colors.white : Colors.black;

    final roles = _getAvailableRoles();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
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
              child: DropdownButtonFormField<Role>(
                initialValue: selectedRole,
                items: roles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              _getRoleIcon(role),
                              size: 18,
                              color: _getRoleColor(role, isDark),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _getRoleDisplayName(role),
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: enabled ? onChanged : null,
                validator: validator,
                dropdownColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                style: GoogleFonts.montserrat(color: textColor),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: enabled ? AppColors.primary : AppColors.textMutedLight,
                ),
                decoration: InputDecoration(
                  hintText: hint ?? 'Sélectionner un rôle',
                  hintStyle: GoogleFonts.montserrat(color: hintColor),
                  prefixIcon: Icon(
                    Icons.admin_panel_settings,
                    color: enabled ? AppColors.primary : hintColor,
                  ),
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

  /// Retourne la liste des rôles disponibles selon le contexte.
  List<Role> _getAvailableRoles() {
    // Si une liste personnalisée est fournie, l'utiliser
    if (availableRoles != null) {
      return availableRoles!;
    }

    // Si le filtrage par attribution est activé
    if (filterByAssignable) {
      // Vérifier si l'utilisateur a la permission d'attribuer des rôles
      final canAssignRole = DependencyInjection.roleService.hasPermission(
        Permission.userAssignRole,
      );

      if (!canAssignRole) {
        // Sans permission, retourner une liste vide ou le rôle actuel uniquement
        return selectedRole != null ? [selectedRole!] : [];
      }

      // Récupérer le rôle actuel de l'utilisateur
      // Note: Cette opération est synchrone via le cache
      try {
        final currentRole = DependencyInjection.roleRepository.cachedRole;
        if (currentRole != null) {
          // L'utilisateur ne peut attribuer que des rôles de niveau inférieur ou égal
          return currentRole.lowerOrEqualRoles;
        }
      } catch (_) {
        // En cas d'erreur, retourner tous les rôles
      }
    }

    // Par défaut, retourner tous les rôles
    return Role.values;
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

  /// Retourne la couleur associée au rôle.
  Color _getRoleColor(Role role, bool isDark) {
    switch (role) {
      case Role.supAdmin:
        return isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9);
      case Role.admin:
        return AppColors.primary;
      case Role.encadreurChef:
        return isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669);
      case Role.medecinChef:
        return isDark ? const Color(0xFF67E8F9) : const Color(0xFF0891B2);
      case Role.encadreur:
        return isDark ? const Color(0xFFFDE047) : const Color(0xFFCA8A04);
      case Role.surveillantGeneral:
        return isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
      case Role.visiteur:
        return isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280);
    }
  }

  /// Retourne le nom d'affichage du rôle.
  String _getRoleDisplayName(Role role) {
    switch (role) {
      case Role.supAdmin:
        return 'Super Administrateur';
      case Role.admin:
        return 'Administrateur';
      case Role.encadreurChef:
        return 'Chef des Encadreurs';
      case Role.medecinChef:
        return 'Chef Médical';
      case Role.encadreur:
        return 'Encadreur';
      case Role.surveillantGeneral:
        return 'Surveillant Général';
      case Role.visiteur:
        return 'Visiteur';
    }
  }
}

/// Widget compact pour afficher et changer un rôle avec un badge.
///
/// Combine le RoleBadge avec un menu dropdown pour une sélection rapide.
class RoleSelectorCompact extends StatelessWidget {
  /// Le rôle actuellement sélectionné.
  final Role selectedRole;

  /// Callback appelé lors du changement de rôle.
  final void Function(Role)? onChanged;

  /// Si true, filtre les rôles attribuables.
  final bool filterByAssignable;

  /// Taille du badge.
  final RoleBadgeSize badgeSize;

  const RoleSelectorCompact({
    super.key,
    required this.selectedRole,
    this.onChanged,
    this.filterByAssignable = true,
    this.badgeSize = RoleBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final roles = _getAvailableRoles();

    return PopupMenuButton<Role>(
      onSelected: onChanged,
      itemBuilder: (context) => roles
          .map(
            (role) => PopupMenuItem(
              value: role,
              child: Row(
                children: [
                  RoleBadge(role: role, size: RoleBadgeSize.small),
                  const SizedBox(width: 8),
                  Text(
                    _getRoleDescription(role),
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: RoleBadge(role: selectedRole, size: badgeSize),
    );
  }

  /// Retourne la liste des rôles disponibles.
  List<Role> _getAvailableRoles() {
    if (filterByAssignable) {
      try {
        final currentRole = DependencyInjection.roleRepository.cachedRole;
        if (currentRole != null) {
          return currentRole.lowerOrEqualRoles;
        }
      } catch (_) {}
    }
    return Role.values;
  }

  /// Retourne une description courte du rôle.
  String _getRoleDescription(Role role) {
    switch (role) {
      case Role.supAdmin:
        return 'Accès complet';
      case Role.admin:
        return 'Gestion complète';
      case Role.encadreurChef:
        return 'Structuration';
      case Role.medecinChef:
        return 'Suivi médical';
      case Role.encadreur:
        return 'Application terrain';
      case Role.surveillantGeneral:
        return 'Logistique & discipline';
      case Role.visiteur:
        return 'Lecture seule';
    }
  }
}
