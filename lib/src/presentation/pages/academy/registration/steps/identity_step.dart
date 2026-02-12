import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/src/presentation/state/academy_registration_state.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/glass_text_field.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/profile_image_picker.dart';

class IdentityStep extends StatefulWidget {
  final AcademyRegistrationState state;
  const IdentityStep({super.key, required this.state});

  @override
  State<IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<IdentityStep> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.state.nom);
    _prenomController = TextEditingController(text: widget.state.prenom);
    _phoneController = TextEditingController(
      text: widget.state.telephoneParent,
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileImagePicker(
            initialImage: widget.state.photoPath,
            onImageSelected: (path) {
              widget.state.setPersonalInfo(photoPath: path);
            },
          ),
          const SizedBox(height: 32),
          GlassTextField(
            label: "Nom",
            hint: "Entrez le nom",
            controller: _nomController,
            prefixIcon: Icons.person_outline,
            onChanged: (val) => widget.state.setPersonalInfo(nom: val),
          ),
          const SizedBox(height: 20),
          GlassTextField(
            label: "Prénom",
            hint: "Entrez le prénom",
            controller: _prenomController,
            prefixIcon: Icons.person_outline,
            onChanged: (val) => widget.state.setPersonalInfo(prenom: val),
          ),
          const SizedBox(height: 20),
          _buildDatePicker(context),
          const SizedBox(height: 20),
          GlassTextField(
            label: "Téléphone Parent",
            hint: "Ex: +237 6XX XXX XXX",
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            onChanged: (val) =>
                widget.state.setPersonalInfo(telephoneParent: val),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: widget.state.dateNaissance ?? DateTime(2010),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          widget.state.setPersonalInfo(dateNaissance: date);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date de naissance",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: baseColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.state.dateNaissance == null
                      ? "Sélectionner une date"
                      : "${widget.state.dateNaissance!.day}/${widget.state.dateNaissance!.month}/${widget.state.dateNaissance!.year}",
                  style: TextStyle(
                    color: widget.state.dateNaissance == null
                        ? (isDark ? Colors.white54 : Colors.black54)
                        : (isDark ? Colors.white : Colors.black),
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
