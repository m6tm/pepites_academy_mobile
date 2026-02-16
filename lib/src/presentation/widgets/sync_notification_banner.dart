import 'package:flutter/material.dart';
import '../state/connectivity_state.dart';
import '../state/sync_state.dart';
import '../theme/app_colors.dart';
import '../../domain/entities/connectivity_status.dart';

/// Banniere de notification affichee en haut de l'ecran lors des
/// changements de connectivite ou apres une synchronisation.
/// Se masque automatiquement apres quelques secondes.
class SyncNotificationBanner extends StatelessWidget {
  final ConnectivityState connectivityState;
  final SyncState syncState;

  const SyncNotificationBanner({
    super.key,
    required this.connectivityState,
    required this.syncState,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([connectivityState, syncState]),
      builder: (context, _) {
        final showOfflineBanner = connectivityState.isDisconnected;
        final syncMessage = syncState.lastSyncMessage;

        if (!showOfflineBanner && syncMessage == null) {
          return const SizedBox.shrink();
        }

        if (showOfflineBanner) {
          return _buildBanner(
            context,
            icon: Icons.wifi_off,
            message: 'Mode hors-ligne actif',
            subtitle: syncState.hasPendingOperations
                ? '${syncState.pendingCount} operation(s) en attente'
                : 'Les donnees seront synchronisees au retour du reseau',
            color: AppColors.error,
          );
        }

        if (syncMessage != null) {
          return _buildBanner(
            context,
            icon: Icons.check_circle,
            message: syncMessage,
            color: AppColors.success,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required IconData icon,
    required String message,
    String? subtitle,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border(
            bottom: BorderSide(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: color.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
              if (connectivityState.status == ConnectivityStatus.disconnected &&
                  syncState.hasPendingOperations)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${syncState.pendingCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
