import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

/// Statut visuel d'une séance.
enum SeanceCardStatus { enCours, terminee, aVenir }

/// Carte de séance d'entraînement avec statut et informations clés.
class SeanceCard extends StatelessWidget {
  final String title;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String encadreur;
  final int nbPresents;
  final int nbAteliers;
  final SeanceCardStatus status;
  final VoidCallback? onTap;

  const SeanceCard({
    super.key,
    required this.title,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.encadreur,
    required this.nbPresents,
    required this.nbAteliers,
    required this.status,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case SeanceCardStatus.enCours:
        return AppColors.success;
      case SeanceCardStatus.terminee:
        return AppColors.textMutedLight;
      case SeanceCardStatus.aVenir:
        return const Color(0xFF3B82F6);
    }
  }

  String get _statusLabel {
    switch (status) {
      case SeanceCardStatus.enCours:
        return 'En cours';
      case SeanceCardStatus.terminee:
        return 'Terminee';
      case SeanceCardStatus.aVenir:
        return 'A venir';
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case SeanceCardStatus.enCours:
        return Icons.play_circle_outline_rounded;
      case SeanceCardStatus.terminee:
        return Icons.check_circle_outline_rounded;
      case SeanceCardStatus.aVenir:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: status == SeanceCardStatus.enCours
                ? _statusColor.withValues(alpha: 0.3)
                : colorScheme.onSurface.withValues(alpha: 0.06),
            width: status == SeanceCardStatus.enCours ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: status == SeanceCardStatus.enCours
                  ? _statusColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Badge de statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  date,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              encadreur,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 14),
            // Barre d'informations
            Row(
              children: [
                _InfoChip(
                  icon: Icons.access_time_rounded,
                  label: '$heureDebut - $heureFin',
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.people_outline_rounded,
                  label: '$nbPresents presents',
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.sports_soccer_rounded,
                  label: '$nbAteliers ateliers',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
