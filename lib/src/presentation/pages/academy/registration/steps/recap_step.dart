import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/domain/entities/niveau_scolaire.dart';
import 'package:pepites_academy_mobile/src/domain/entities/poste_football.dart';
import 'package:pepites_academy_mobile/src/presentation/state/academy_registration_state.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/glassmorphism_card.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';
import 'package:intl/intl.dart';

class RecapStep extends StatelessWidget {
  final AcademyRegistrationState state;
  final List<PosteFootball> postes;
  final List<NiveauScolaire> niveaux;

  const RecapStep({
    super.key,
    required this.state,
    this.postes = const [],
    this.niveaux = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recapTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.recapSubtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          GlassmorphismCard(
            blurSigma: 15,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfileHeader(l10n),
                const SizedBox(height: 32),
                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 24),
                _buildInfoRow(
                  Icons.calendar_today,
                  l10n.birthDateLabel,
                  state.dateNaissance != null
                      ? DateFormat('dd/MM/yyyy').format(state.dateNaissance!)
                      : l10n.notSpecified,
                ),
                _buildInfoRow(
                  Icons.phone,
                  l10n.parentPhoneLabel,
                  state.telephoneParent ?? l10n.notProvided,
                ),
                _buildInfoRow(
                  Icons.sports_soccer,
                  l10n.posteLabel,
                  _getPosteName(state.posteFootballId, l10n),
                ),
                _buildInfoRow(
                  Icons.ads_click,
                  l10n.strongFootLabel,
                  state.piedFort ?? l10n.notSpecified,
                ),
                _buildInfoRow(
                  Icons.school,
                  l10n.schoolingLabel,
                  _getNiveauName(state.niveauScolaireId, l10n),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildWarningBox(l10n),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AppLocalizations l10n) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: state.photoPath != null
              ? FileImage(File(state.photoPath!))
              : null,
          child: state.photoPath == null
              ? const Icon(Icons.person, size: 40, color: AppColors.primary)
              : null,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${state.nom?.toUpperCase()} ${state.prenom}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.futureAcademician,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            "$label :",
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.qrBadgeValidationWarning,
              style: const TextStyle(fontSize: 13, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  String _getPosteName(String? id, AppLocalizations l10n) {
    if (id == null) return l10n.notSpecified;
    try {
      return postes.firstWhere((p) => p.id == id).nom;
    } catch (_) {
      return l10n.notSpecified;
    }
  }

  String _getNiveauName(String? id, AppLocalizations l10n) {
    if (id == null) return l10n.notSpecified;
    try {
      return niveaux.firstWhere((n) => n.id == id).nom;
    } catch (_) {
      return l10n.notSpecified;
    }
  }
}
