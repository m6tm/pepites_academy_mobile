import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/permission.dart';
import '../../injection_container.dart';
import 'glassmorphism_card.dart';
import 'permission_guard.dart';

/// Carte de gestion des saisons pour le dashboard admin.
///
/// Permet d'ouvrir une nouvelle saison ou de fermer la saison en cours.
/// Les actions sont protegees par permissions [Permission.seasonOpen] et
/// [Permission.seasonClose].
class SeasonManagementCard extends StatefulWidget {
  /// La saison en cours (ou null si aucune).
  final Season? currentSeason;

  /// Callback appele apres une action reussie (ouverture/fermeture).
  final VoidCallback? onActionComplete;

  const SeasonManagementCard({
    super.key,
    this.currentSeason,
    this.onActionComplete,
  });

  @override
  State<SeasonManagementCard> createState() => _SeasonManagementCardState();
}

class _SeasonManagementCardState extends State<SeasonManagementCard> {
  bool _isLoading = false;

  /// Indique si une saison est active.
  bool get _hasActiveSeason =>
      widget.currentSeason != null &&
      widget.currentSeason!.status == SeasonStatus.open;

  /// Ouvre une nouvelle saison.
  Future<void> _openSeason() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await _showOpenSeasonDialog(l10n);
    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final failure = await DependencyInjection.dashboardService.openSeason(
        name: result['name'],
        startDate: result['startDate'],
      );

      if (mounted) {
        if (failure != null) {
          _showErrorSnackBar(failure.message ?? l10n.seasonOpenError);
        } else {
          _showSuccessSnackBar(l10n.seasonOpenedSuccess);
          widget.onActionComplete?.call();
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Ferme la saison en cours.
  Future<void> _closeSeason() async {
    if (widget.currentSeason == null) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showCloseSeasonConfirmation(l10n);
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final failure = await DependencyInjection.dashboardService.closeSeason(
        seasonId: widget.currentSeason!.id,
        endDate: DateTime.now(),
      );

      if (mounted) {
        if (failure != null) {
          _showErrorSnackBar(failure.message ?? l10n.seasonCloseError);
        } else {
          _showSuccessSnackBar(l10n.seasonClosedSuccess);
          widget.onActionComplete?.call();
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Affiche le dialogue d'ouverture de saison.
  Future<Map<String, dynamic>?> _showOpenSeasonDialog(
    AppLocalizations l10n,
  ) async {
    final nameController = TextEditingController();
    final date = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.openNewSeason,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.seasonName,
                hintText: l10n.seasonNameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.seasonStartDate, style: GoogleFonts.poppins()),
              subtitle: Text(
                dateFormat.format(date),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelAction, style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.seasonNameRequired)),
                );
                return;
              }
              Navigator.pop(context, {'name': name, 'startDate': date});
            },
            child: Text(l10n.seasonOpen, style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  /// Affiche la confirmation de fermeture de saison.
  Future<bool> _showCloseSeasonConfirmation(AppLocalizations l10n) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.closeSeasonTitle,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  l10n.closeSeasonConfirmation(
                    widget.currentSeason?.name ?? '',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.closeSeasonWarning,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancelAction, style: GoogleFonts.poppins()),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(l10n.seasonClose, style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Affiche un SnackBar de succes.
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Affiche un SnackBar d'erreur.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final l10n = AppLocalizations.of(context)!;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tete
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.seasonManagement,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Statut actuel
          if (widget.currentSeason != null) ...[
            _buildStatusChip(context, l10n),
            const SizedBox(height: 12),
            Text(
              widget.currentSeason!.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.seasonStartDate}: ${dateFormat.format(widget.currentSeason!.startDate)}',
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ] else
            Text(
              l10n.noActiveSeason,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),

          const SizedBox(height: 20),

          // Boutons d'action
          Row(
            children: [
              // Bouton ouvrir saison
              Expanded(
                child: PermissionGuard(
                  permission: Permission.seasonOpen,
                  child: Opacity(
                    opacity: _hasActiveSeason ? 0.5 : 1.0,
                    child: FilledButton.icon(
                      onPressed: _hasActiveSeason || _isLoading
                          ? null
                          : _openSeason,
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(
                        l10n.seasonOpen,
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Bouton fermer saison
              Expanded(
                child: PermissionGuard(
                  permission: Permission.seasonClose,
                  child: Opacity(
                    opacity: _hasActiveSeason ? 1.0 : 0.5,
                    child: FilledButton.tonalIcon(
                      onPressed: _hasActiveSeason && !_isLoading
                          ? _closeSeason
                          : null,
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(
                        l10n.seasonClose,
                        style: GoogleFonts.poppins(),
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

  /// Construit le chip de statut.
  Widget _buildStatusChip(BuildContext context, AppLocalizations l10n) {
    Color color;
    String label;
    IconData icon;

    switch (widget.currentSeason?.status) {
      case SeasonStatus.open:
        color = Colors.green;
        label = l10n.seasonStatusOpen;
        icon = Icons.check_circle;
        break;
      case SeasonStatus.closed:
        color = Colors.grey;
        label = l10n.seasonStatusClosed;
        icon = Icons.lock;
        break;
      case SeasonStatus.pending:
        color = Colors.orange;
        label = l10n.seasonStatusPending;
        icon = Icons.schedule;
        break;
      default:
        color = Colors.grey;
        label = l10n.seasonStatusNone;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
