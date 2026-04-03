import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ecran gérant les consultations et examens médicaux.
class MedecinConsultationsScreen extends StatelessWidget {
  const MedecinConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_rounded, size: 64, color: colorScheme.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 24),
          Text(
            l10n.noConsultationInProgress,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.selectAcademicianToStart,
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Ouvrir sélecteur d'académicien
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.medicalVisit),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
