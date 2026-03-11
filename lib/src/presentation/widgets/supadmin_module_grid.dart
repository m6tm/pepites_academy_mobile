import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/role.dart';
import '../../injection_container.dart';
import 'permission_guard.dart';
import '../theme/app_colors.dart';

/// Definition d'un module pour la grille SupAdmin.
class ModuleItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Permission? permission;
  final Role? minimumRole;
  final VoidCallback onTap;

  const ModuleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.permission,
    this.minimumRole,
    required this.onTap,
  });
}

/// Grille de modules pour le Super Administrateur.
///
/// Affiche tous les modules de l'application avec:
/// - Icônes pour chaque module
/// - Badge indiquant le nombre d'operations en attente de synchronisation
/// - Indicateur d'acces autorise via [PermissionGuard]
class SupAdminModuleGrid extends StatefulWidget {
  /// Callback pour naviguer vers l'onglet Academie (index 1).
  final VoidCallback? onNavigateToAcademy;

  /// Callback pour naviguer vers l'onglet Seances (index 2).
  final VoidCallback? onNavigateToSeances;

  /// Callback pour naviguer vers l'onglet Communication (index 3).
  final VoidCallback? onNavigateToCommunication;

  /// Callback pour naviguer vers la liste des encadreurs.
  final VoidCallback? onNavigateToEncadreurs;

  /// Callback pour naviguer vers les ateliers.
  final VoidCallback? onNavigateToAteliers;

  /// Callback pour naviguer vers les bulletins.
  final VoidCallback? onNavigateToBulletins;

  /// Callback pour naviguer vers les referentiels.
  final VoidCallback? onNavigateToReferentiels;

  const SupAdminModuleGrid({
    super.key,
    this.onNavigateToAcademy,
    this.onNavigateToSeances,
    this.onNavigateToCommunication,
    this.onNavigateToEncadreurs,
    this.onNavigateToAteliers,
    this.onNavigateToBulletins,
    this.onNavigateToReferentiels,
  });

  @override
  State<SupAdminModuleGrid> createState() => _SupAdminModuleGridState();
}

class _SupAdminModuleGridState extends State<SupAdminModuleGrid> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final modules = _buildModules(context, l10n);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, l10n),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return _buildModuleCard(context, module);
            },
          ),
        ],
      ),
    );
  }

  /// Construit l'en-tete de la grille avec le compteur de synchronisation.
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.modulesTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.modulesSubtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        // Badge de synchronisation
        ListenableBuilder(
          listenable: DependencyInjection.syncState,
          builder: (context, _) {
            final pendingCount = DependencyInjection.syncState.pendingCount;
            if (pendingCount == 0) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync_rounded, size: 14, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    l10n.pendingSyncCount(pendingCount),
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Construit la liste des modules avec leurs actions de navigation.
  List<ModuleItem> _buildModules(BuildContext context, AppLocalizations l10n) {
    return [
      // Academiciens
      ModuleItem(
        title: l10n.academicians,
        description: l10n.academiciansList,
        icon: Icons.school_rounded,
        color: const Color(0xFF3B82F6),
        permission: Permission.academicienView,
        onTap: () => widget.onNavigateToAcademy?.call(),
      ),
      // Encadreurs
      ModuleItem(
        title: l10n.coaches,
        description: l10n.coachManagement,
        icon: Icons.sports_rounded,
        color: const Color(0xFF8B5CF6),
        permission: Permission.encadreurView,
        onTap: () => widget.onNavigateToEncadreurs?.call(),
      ),
      // Seances
      ModuleItem(
        title: l10n.sessions,
        description: l10n.sessionsManagement,
        icon: Icons.sports_soccer_rounded,
        color: AppColors.primary,
        permission: Permission.seanceView,
        onTap: () => widget.onNavigateToSeances?.call(),
      ),
      // Ateliers
      ModuleItem(
        title: l10n.workshopsLabel,
        description: l10n.workshopsManagement,
        icon: Icons.extension_rounded,
        color: const Color(0xFFF59E0B),
        permission: Permission.atelierView,
        onTap: () => widget.onNavigateToAteliers?.call(),
      ),
      // Bulletins
      ModuleItem(
        title: l10n.bulletinsLabel,
        description: l10n.bulletinsManagement,
        icon: Icons.description_rounded,
        color: const Color(0xFF10B981),
        permission: Permission.bulletinView,
        onTap: () => widget.onNavigateToBulletins?.call(),
      ),
      // SMS
      ModuleItem(
        title: l10n.smsLabel,
        description: l10n.smsManagement,
        icon: Icons.sms_rounded,
        color: const Color(0xFFEC4899),
        permission: Permission.smsSend,
        onTap: () => widget.onNavigateToCommunication?.call(),
      ),
      // Referentiels
      ModuleItem(
        title: l10n.referentials,
        description: l10n.referentialsSubtitle,
        icon: Icons.tune_rounded,
        color: const Color(0xFF6366F1),
        permission: Permission.referentielView,
        onTap: () => widget.onNavigateToReferentiels?.call(),
      ),
    ];
  }

  /// Construit une carte de module avec PermissionGuard.
  Widget _buildModuleCard(BuildContext context, ModuleItem module) {
    Widget card = _ModuleCard(module: module);

    // Appliquer le PermissionGuard si une permission est definie
    if (module.permission != null) {
      return PermissionGuard(
        permission: module.permission,
        minimumRole: module.minimumRole ?? Role.supAdmin,
        fallback: _buildDisabledCard(context, module),
        child: card,
      );
    }

    // Appliquer le PermissionGuard si seul un role minimum est defini
    if (module.minimumRole != null) {
      return PermissionGuard.role(
        minimumRole: module.minimumRole!,
        fallback: _buildDisabledCard(context, module),
        child: card,
      );
    }

    return card;
  }

  /// Construit une carte desactivee pour les modules sans acces.
  Widget _buildDisabledCard(BuildContext context, ModuleItem module) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Opacity(
        opacity: 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(module.icon, color: Colors.grey, size: 24),
                ),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              module.title,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              module.description,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de module individuelle avec animation au tap.
class _ModuleCard extends StatefulWidget {
  final ModuleItem module;

  const _ModuleCard({required this.module});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.module.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.module.color.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.module.color.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.module.color.withValues(alpha: 0.15),
                          widget.module.color.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.module.icon,
                      color: widget.module.color,
                      size: 24,
                    ),
                  ),
                  // Indicateur d'acces autorise
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.module.title,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.module.description,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
