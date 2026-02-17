import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/domain/entities/niveau_scolaire.dart';
import 'package:pepites_academy_mobile/src/presentation/state/academy_registration_state.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/glass_dropdown.dart';

class SchoolStep extends StatelessWidget {
  final AcademyRegistrationState state;
  final List<NiveauScolaire> niveaux;

  const SchoolStep({super.key, required this.state, this.niveaux = const []});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.academicLevelTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.academicStepDesc,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          GlassDropdown<String>(
            label: l10n.schoolLevels,
            hint: l10n.selectSchoolLevelHint,
            value: state.niveauScolaireId,
            prefixIcon: Icons.school_outlined,
            items: niveaux.map((n) {
              return DropdownMenuItem(value: n.id, child: Text(n.nom));
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
                Expanded(
                  child: Text(
                    l10n.academicStepInfo,
                    style: const TextStyle(fontSize: 13, color: Colors.blue),
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
