import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/state/academy_registration_state.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/glass_dropdown.dart';

class FootballStep extends StatelessWidget {
  final AcademyRegistrationState state;
  const FootballStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Mock data for Postes
    final postes = [
      {'id': '1', 'nom': 'Gardien'},
      {'id': '2', 'nom': 'Défenseur Central'},
      {'id': '3', 'nom': 'Défenseur Latéral'},
      {'id': '4', 'nom': 'Milieu Défensif'},
      {'id': '5', 'nom': 'Milieu Relayeur'},
      {'id': '6', 'nom': 'Attaquant'},
      {'id': '7', 'nom': 'Ailier'},
    ];

    final pieds = ['Droitier', 'Gaucher', 'Ambidextre'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profil Sportif",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Définissez le rôle de l'élève sur le terrain.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          GlassDropdown<String>(
            label: "Poste de formation",
            hint: "Sélectionnez un poste",
            value: state.posteFootballId,
            prefixIcon: Icons.sports_soccer,
            items: postes.map((p) {
              return DropdownMenuItem(value: p['id'], child: Text(p['nom']!));
            }).toList(),
            onChanged: (val) => state.setFootballInfo(posteId: val),
          ),
          const SizedBox(height: 24),
          GlassDropdown<String>(
            label: "Pied Fort",
            hint: "Sélectionnez le pied",
            value: state.piedFort,
            prefixIcon: Icons.ads_click,
            items: pieds.map((p) {
              return DropdownMenuItem(value: p, child: Text(p));
            }).toList(),
            onChanged: (val) => state.setFootballInfo(piedFort: val),
          ),
        ],
      ),
    );
  }
}
