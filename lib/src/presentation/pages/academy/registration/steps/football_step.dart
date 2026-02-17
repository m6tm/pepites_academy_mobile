import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/domain/entities/poste_football.dart';
import 'package:pepites_academy_mobile/src/presentation/state/academy_registration_state.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/glass_dropdown.dart';

class FootballStep extends StatelessWidget {
  final AcademyRegistrationState state;
  final List<PosteFootball> postes;

  const FootballStep({super.key, required this.state, this.postes = const []});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Valeurs techniques stockées dans le state
    final pieds = ['Droitier', 'Gaucher', 'Ambidextre'];

    // Libellés traduits pour l'affichage
    final String labelDroitier = l10n.rightFooted;
    final String labelGaucher = l10n.leftFooted;
    final String labelAmbidextre = l10n.ambidextrous;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sportProfile,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sportProfileDesc,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          GlassDropdown<String>(
            label: l10n.preferredPositionLabel,
            hint: l10n.selectPositionHint,
            value: state.posteFootballId,
            prefixIcon: Icons.sports_soccer,
            items: postes.map((p) {
              return DropdownMenuItem(value: p.id, child: Text(p.nom));
            }).toList(),
            onChanged: (val) => state.setFootballInfo(posteId: val),
          ),
          const SizedBox(height: 24),
          GlassDropdown<String>(
            label: l10n.strongFootLabel,
            hint: l10n.selectFootHint,
            value: state.piedFort,
            prefixIcon: Icons.ads_click,
            items: pieds.map((p) {
              String label = p;
              if (p == 'Droitier') label = labelDroitier;
              if (p == 'Gaucher') label = labelGaucher;
              if (p == 'Ambidextre') label = labelAmbidextre;
              return DropdownMenuItem(value: p, child: Text(label));
            }).toList(),
            onChanged: (val) => state.setFootballInfo(piedFort: val),
          ),
        ],
      ),
    );
  }
}
