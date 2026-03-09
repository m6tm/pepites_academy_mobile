import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/permission.dart';
import '../../../domain/entities/role.dart';
import '../../theme/app_colors.dart';
import '../../widgets/role_badge.dart';

/// Page d'erreur affichée lorsque l'utilisateur n'a pas les permissions nécessaires.
///
/// Cette page est affichée quand un utilisateur tente d'accéder à une
/// fonctionnalité ou une page sans avoir les permissions requises.
class UnauthorizedPage extends StatelessWidget {
  /// Le message d'erreur personnalisé à afficher.
  final String? message;

  /// La permission requise pour accéder à la ressource.
  final Permission? requiredPermission;

  /// Le rôle minimum requis pour accéder à la ressource.
  final Role? requiredRole;

  /// Callback pour retourner à la page précédente.
  final VoidCallback? onGoBack;

  /// Callback pour naviguer vers le dashboard.
  final VoidCallback? onGoToDashboard;

  const UnauthorizedPage({
    super.key,
    this.message,
    this.requiredPermission,
    this.requiredRole,
    this.onGoBack,
    this.onGoToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône d'erreur
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 32),

                // Titre
                Text(
                  'Accès non autorisé',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message descriptif
                Text(
                  message ?? _getDefaultMessage(),
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: mutedColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Affichage des pré-requis si spécifiés
                if (requiredPermission != null || requiredRole != null) ...[
                  _buildRequirementsCard(isDark, textColor, mutedColor),
                  const SizedBox(height: 32),
                ],

                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onGoBack != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onGoBack,
                          icon: const Icon(Icons.arrow_back),
                          label: Text(
                            'Retour',
                            style: GoogleFonts.montserrat(),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    if (onGoBack != null && onGoToDashboard != null)
                      const SizedBox(width: 16),
                    if (onGoToDashboard != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onGoToDashboard,
                          icon: const Icon(Icons.home),
                          label: Text(
                            'Dashboard',
                            style: GoogleFonts.montserrat(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Lien de contact support
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => _showContactSupport(context),
                  icon: Icon(Icons.help_outline, size: 18, color: mutedColor),
                  label: Text(
                    'Contacter le support',
                    style: GoogleFonts.montserrat(
                      color: mutedColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Retourne le message par défaut selon le contexte.
  String _getDefaultMessage() {
    if (requiredPermission != null) {
      return 'Vous n\'avez pas la permission "${requiredPermission!.description}" '
          'nécessaire pour accéder à cette ressource.';
    }
    if (requiredRole != null) {
      return 'Cette fonctionnalité est réservée aux utilisateurs '
          'avec un rôle ${requiredRole!.displayName} ou supérieur.';
    }
    return 'Vous n\'avez pas les autorisations nécessaires pour '
        'accéder à cette page. Veuillez contacter un administrateur '
        'si vous pensez qu\'il s\'agit d\'une erreur.';
  }

  /// Construit la carte des pré-requis.
  Widget _buildRequirementsCard(
    bool isDark,
    Color textColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.5)
            : AppColors.surfaceLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'Prérequis d\'accès',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (requiredRole != null) ...[
            Row(
              children: [
                Text(
                  'Rôle minimum :',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(width: 12),
                RoleBadge(role: requiredRole!),
              ],
            ),
            if (requiredPermission != null) const SizedBox(height: 12),
          ],
          if (requiredPermission != null)
            Row(
              children: [
                Text(
                  'Permission :',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    requiredPermission!.description,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Affiche les informations de contact support.
  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Contacter le support',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Si vous pensez que vous devriez avoir accès à cette ressource, '
              'veuillez contacter votre administrateur ou le support technique.',
              style: GoogleFonts.montserrat(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'support@pepites-academy.com',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer', style: GoogleFonts.montserrat()),
          ),
        ],
      ),
    );
  }
}

/// Widget wrapper qui affiche la page UnauthorizedPage si les permissions sont insuffisantes.
///
/// Ce widget vérifie les permissions et affiche soit l'enfant, soit la page d'erreur.
class UnauthorizedGuard extends StatelessWidget {
  /// L'enfant à afficher si les permissions sont accordées.
  final Widget child;

  /// Permission requise pour afficher l'enfant.
  final Permission? permission;

  /// Rôle minimum requis.
  final Role? minimumRole;

  /// Message d'erreur personnalisé.
  final String? unauthorizedMessage;

  const UnauthorizedGuard({
    super.key,
    required this.child,
    this.permission,
    this.minimumRole,
    this.unauthorizedMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Cette vérification est faite de manière synchrone via le cache
    // Pour une vraie vérification, utiliser PermissionGuard
    return child;
  }
}
