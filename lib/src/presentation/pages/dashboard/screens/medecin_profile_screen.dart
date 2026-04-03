import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ecran de profil spécifique pour le rôle médecin chef.
class MedecinProfileScreen extends StatelessWidget {
  final String userName;
  final String? fullName;
  final String? photoUrl;
  final VoidCallback onLogout;

  const MedecinProfileScreen({
    super.key,
    required this.userName,
    this.fullName,
    this.photoUrl,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                ? NetworkImage(photoUrl!)
                : null,
            child: photoUrl == null || photoUrl!.isEmpty
                ? const Icon(Icons.person_rounded, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            fullName ?? userName,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l10n.chiefMedicalOfficer,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
