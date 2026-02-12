import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/state/academy_registration_state.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/glass_dropdown.dart';

class SchoolStep extends StatelessWidget {
  final AcademyRegistrationState state;
  const SchoolStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Mock data for Niveaux Scolaires
    final niveaux = [
      {'id': '1', 'nom': 'Primaire - CM1'},
      {'id': '2', 'nom': 'Primaire - CM2'},
      {'id': '3', 'nom': 'Secondaire - 6ème'},
      {'id': '4', 'nom': 'Secondaire - 5ème'},
      {'id': '5', 'nom': 'Secondaire - 4ème'},
      {'id': '6', 'nom': 'Secondaire - 3ème'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Niveau Académique",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Suivi de la scolarité de l'académicien.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          GlassDropdown<String>(
            label: "Niveau Scolaire",
            hint: "Sélectionnez le niveau",
            value: state.niveauScolaireId,
            prefixIcon: Icons.school_outlined,
            items: niveaux.map((n) {
              return DropdownMenuItem(value: n['id'], child: Text(n['nom']!));
            }).toList(),
            onChanged: (val) => state.setSchoolInfo(niveauId: val),
          ),
          const SizedBox(height: 32),
          // Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Ces informations permettent de filtrer les communications SMS et d'adapter les rapports.",
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
