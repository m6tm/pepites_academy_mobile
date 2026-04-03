import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/connectivity_indicator.dart';

/// En-tete personnalise pour les dashboards.
/// Affiche l'avatar de l'utilisateur, un message de bienvenue,
/// l'indicateur de connectivite et des actions.
class DashboardHeader extends StatelessWidget {
  final String userName;
  final String role;
  final String greeting;
  final String? photoUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSmsTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSyncTap;
  final int notificationCount;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.role,
    required this.greeting,
    this.photoUrl,
    this.onNotificationTap,
    this.onSmsTap,
    this.onSearchTap,
    this.onProfileTap,
    this.onSyncTap,
    this.notificationCount = 0,
  });

  /// Construit l'image avatar en gérant les chemins locaux et URLs distantes.
  Widget _buildAvatarImage() {
    final fallback = Center(
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (photoUrl == null || photoUrl!.isEmpty) return fallback;

    final isRemote = photoUrl!.startsWith('http');
    if (isRemote) {
      return Image.network(
        photoUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, o, st) => fallback,
      );
    }

    // Chemin local
    final file = File(photoUrl!);
    if (!file.existsSync()) return fallback;
    return Image.file(file, width: 50, height: 50, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildAvatarImage(),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Texte de bienvenue
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Indicateur de connectivite
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: onSyncTap,
              child: ConnectivityIndicator(
                connectivityState: DependencyInjection.connectivityState,
                syncState: DependencyInjection.syncState,
                compact: true,
              ),
            ),
          ),
          // Bouton Recherche
          if (onSearchTap != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: onSearchTap,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                icon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
            ),
          // Bouton SMS
          if (onSmsTap != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: onSmsTap,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                icon: Icon(
                  Icons.sms_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
            ),
          // Bouton de notification
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                icon: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
