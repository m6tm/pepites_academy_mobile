import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/state/academy_registration_state.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/glassmorphism_card.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';

class RecapStep extends StatelessWidget {
  final AcademyRegistrationState state;
  const RecapStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Récapitulatif",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Vérifiez les informations avant la validation finale.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          GlassmorphismCard(
            blurSigma: 15,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 32),
                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 24),
                _buildInfoRow(
                  Icons.calendar_today,
                  "Naissance",
                  "${state.dateNaissance?.day}/${state.dateNaissance?.month}/${state.dateNaissance?.year}",
                ),
                _buildInfoRow(
                  Icons.phone,
                  "Parent",
                  state.telephoneParent ?? "",
                ),
                _buildInfoRow(
                  Icons.sports_soccer,
                  "Poste",
                  _getPosteName(state.posteFootballId),
                ),
                _buildInfoRow(Icons.ads_click, "Pied", state.piedFort ?? ""),
                _buildInfoRow(
                  Icons.school,
                  "Scolarité",
                  _getNiveauName(state.niveauScolaireId),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildWarningBox(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
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
              const Text(
                "Futur Académicien",
                style: TextStyle(
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

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.qr_code, color: Colors.orange),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "La validation générera automatiquement un Badge QR unique pour cet élève.",
              style: TextStyle(fontSize: 13, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  String _getPosteName(String? id) {
    // Serait idéalement récupéré via un repository
    final map = {
      '1': 'Gardien',
      '2': 'Défenseur Central',
      '3': 'Défenseur Latéral',
      '4': 'Milieu Défensif',
      '5': 'Milieu Relayeur',
      '6': 'Attaquant',
      '7': 'Ailier',
    };
    return map[id] ?? "Non spécifié";
  }

  String _getNiveauName(String? id) {
    final map = {
      '1': 'Primaire - CM1',
      '2': 'Primaire - CM2',
      '3': 'Secondaire - 6ème',
      '4': 'Secondaire - 5ème',
      '5': 'Secondaire - 4ème',
      '6': 'Secondaire - 3ème',
    };
    return map[id] ?? "Non spécifié";
  }
}
