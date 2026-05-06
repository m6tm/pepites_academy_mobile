import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';

/// Ecran de profil spécifique pour le rôle médecin chef.
class MedecinProfileScreen extends StatefulWidget {
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
  State<MedecinProfileScreen> createState() => _MedecinProfileScreenState();
}

class _MedecinProfileScreenState extends State<MedecinProfileScreen> {
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await DependencyInjection.preferences.getUserEmail();
    if (mounted) {
      setState(() {
        _userEmail = email;
      });
    }
  }

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
            backgroundImage:
                widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                ? NetworkImage(widget.photoUrl!)
                : null,
            child: widget.photoUrl == null || widget.photoUrl!.isEmpty
                ? const Icon(Icons.person_rounded, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            widget.fullName ?? widget.userName,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_userEmail != null && _userEmail!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _userEmail!,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.chiefMedicalOfficer,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: widget.onLogout,
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
