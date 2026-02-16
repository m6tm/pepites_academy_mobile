import 'package:flutter/material.dart';
import '../state/connectivity_state.dart';
import '../state/sync_state.dart';
import '../theme/app_colors.dart';
import '../../domain/entities/connectivity_status.dart';

/// Indicateur visuel permanent du statut reseau dans la barre d'application.
/// Affiche l'etat de la connexion (connecte / hors-ligne / synchronisation)
/// ainsi que le nombre d'operations en attente.
class ConnectivityIndicator extends StatelessWidget {
  final ConnectivityState connectivityState;
  final SyncState syncState;

  /// Si true, affiche une version compacte (icone seule).
  final bool compact;

  const ConnectivityIndicator({
    super.key,
    required this.connectivityState,
    required this.syncState,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([connectivityState, syncState]),
      builder: (context, _) {
        return _buildIndicator(context);
      },
    );
  }

  Widget _buildIndicator(BuildContext context) {
    final status = connectivityState.status;
    final pendingCount = syncState.pendingCount;
    final isSyncing = syncState.isSyncing;

    if (compact) {
      return _buildCompactIndicator(status, pendingCount, isSyncing);
    }

    return _buildFullIndicator(context, status, pendingCount, isSyncing);
  }

  Widget _buildCompactIndicator(
    ConnectivityStatus status,
    int pendingCount,
    bool isSyncing,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildStatusIcon(status, isSyncing),
        if (pendingCount > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                pendingCount > 99 ? '99+' : '$pendingCount',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFullIndicator(
    BuildContext context,
    ConnectivityStatus status,
    int pendingCount,
    bool isSyncing,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSyncDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _getBackgroundColor(status, isSyncing).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBackgroundColor(status, isSyncing).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(status, isSyncing),
            const SizedBox(width: 6),
            Text(
              _getStatusLabel(status, isSyncing),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
              ),
            ),
            if (pendingCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$pendingCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ConnectivityStatus status, bool isSyncing) {
    if (isSyncing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return Icon(
      _getStatusIcon(status),
      size: 16,
      color: _getIconColor(status),
    );
  }

  IconData _getStatusIcon(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return Icons.wifi;
      case ConnectivityStatus.disconnected:
        return Icons.wifi_off;
      case ConnectivityStatus.syncing:
        return Icons.sync;
    }
  }

  Color _getIconColor(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return AppColors.success;
      case ConnectivityStatus.disconnected:
        return AppColors.error;
      case ConnectivityStatus.syncing:
        return AppColors.primary;
    }
  }

  Color _getBackgroundColor(ConnectivityStatus status, bool isSyncing) {
    if (isSyncing) return AppColors.primary;
    switch (status) {
      case ConnectivityStatus.connected:
        return AppColors.success;
      case ConnectivityStatus.disconnected:
        return AppColors.error;
      case ConnectivityStatus.syncing:
        return AppColors.primary;
    }
  }

  String _getStatusLabel(ConnectivityStatus status, bool isSyncing) {
    if (isSyncing) return 'Synchronisation...';
    switch (status) {
      case ConnectivityStatus.connected:
        return 'Connecte';
      case ConnectivityStatus.disconnected:
        return 'Hors-ligne';
      case ConnectivityStatus.syncing:
        return 'Synchronisation...';
    }
  }

  void _showSyncDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SyncDetailsSheet(
        connectivityState: connectivityState,
        syncState: syncState,
      ),
    );
  }
}

/// Feuille de details de synchronisation affichee en bas de l'ecran.
class _SyncDetailsSheet extends StatelessWidget {
  final ConnectivityState connectivityState;
  final SyncState syncState;

  const _SyncDetailsSheet({
    required this.connectivityState,
    required this.syncState,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: Listenable.merge([connectivityState, syncState]),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Statut de synchronisation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusRow(
                icon: connectivityState.isConnected
                    ? Icons.wifi
                    : Icons.wifi_off,
                label: 'Connexion',
                value: connectivityState.isConnected
                    ? 'Connecte'
                    : 'Hors-ligne',
                color: connectivityState.isConnected
                    ? AppColors.success
                    : AppColors.error,
              ),
              const SizedBox(height: 12),
              _buildStatusRow(
                icon: Icons.pending_actions,
                label: 'Operations en attente',
                value: '${syncState.pendingCount}',
                color: syncState.hasPendingOperations
                    ? AppColors.warning
                    : AppColors.success,
              ),
              if (syncState.lastSyncResult != null) ...[
                const SizedBox(height: 12),
                _buildStatusRow(
                  icon: Icons.check_circle_outline,
                  label: 'Derniere synchronisation',
                  value:
                      '${syncState.lastSyncResult!.successCount} reussie(s), '
                      '${syncState.lastSyncResult!.failureCount} echec(s)',
                  color: syncState.lastSyncResult!.failureCount > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ],
              const SizedBox(height: 20),
              if (syncState.hasPendingOperations &&
                  connectivityState.isConnected)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: syncState.isSyncing ? null : syncState.syncNow,
                    icon: syncState.isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      syncState.isSyncing
                          ? 'Synchronisation en cours...'
                          : 'Synchroniser maintenant',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
