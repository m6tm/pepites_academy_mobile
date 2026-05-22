import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../domain/entities/encadreur.dart';
import '../../../domain/repositories/encadreur_repository.dart';
import '../../../infrastructure/services/upload_service.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../../utils/image_compressor.dart';
import '../../utils/image_cropper_helper.dart';
import '../../widgets/academy_toast.dart';

/// Page d'edition du profil d'un encadreur existant.
class EncadreurEditPage extends StatefulWidget {
  final Encadreur encadreur;
  final EncadreurRepository repository;

  const EncadreurEditPage({
    super.key,
    required this.encadreur,
    required this.repository,
  });

  @override
  State<EncadreurEditPage> createState() => _EncadreurEditPageState();
}

class _EncadreurEditPageState extends State<EncadreurEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _telephoneController;
  late String _specialite;
  File? _photoFile;
  String? _photoUrl;
  bool _isLoading = false;

  final List<String> _specialites = const [
    'Technique',
    'Physique',
    'Tactique',
    'Gardien',
    'Formation jeunes',
    'Preparation mentale',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.encadreur;
    _nomController = TextEditingController(text: e.nom);
    _prenomController = TextEditingController(text: e.prenom);
    _telephoneController = TextEditingController(text: e.telephone);
    _specialite = e.specialite;
    _photoUrl = e.photoUrl.isNotEmpty ? e.photoUrl : null;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final pickedFile = File(picked.path);
    // ignore: use_build_context_synchronously
    final cropped = await ImageCropperHelper.cropImage(
      imageFile: pickedFile, context: context);
    if (cropped == null) return;

    final compressed = await ImageCompressor.compress(imageFile: cropped);
    if (compressed == null) return;

    setState(() {
      _photoFile = File(compressed.path);
      _photoUrl = null;
    });
  }

  Future<String?> _uploadPhotoIfNeeded() async {
    if (_photoFile == null) return _photoUrl;

    setState(() => _isLoading = true);
    try {
      final result = await DependencyInjection.uploadService.uploadImage(
        _photoFile!,
        UploadType.portrait,
      );
      if (!result.success) {
        if (mounted) {
          AcademyToast.show(
            context,
            title: 'Erreur',
            description: result.error ?? 'Echec de l\'upload photo',
            isError: true,
          );
        }
        return null;
      }
      return result.url;
    } catch (e) {
      if (mounted) {
        AcademyToast.show(
          context,
          title: 'Erreur',
          description: 'Exception upload: $e',
          isError: true,
        );
      }
      return null;
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final photoUrl = await _uploadPhotoIfNeeded();
    if (_photoFile != null && photoUrl == null) {
      setState(() => _isLoading = false);
      return;
    }

    final updated = widget.encadreur.copyWith(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      specialite: _specialite,
      photoUrl: photoUrl ?? widget.encadreur.photoUrl,
    );

    try {
      await widget.repository.update(updated);
      if (mounted) {
        AcademyToast.show(
          context,
          title: 'Profil mis à jour',
          description: 'Les informations de l\'encadreur ont été enregistrées.',
          isSuccess: true,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AcademyToast.show(
          context,
          title: l10n.error,
          description: '$e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Modifier le profil',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    l10n.save,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: _buildPhoto(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nom
              _buildTextField(
                controller: _nomController,
                label: l10n.lastName,
                icon: Icons.person_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Prenom
              _buildTextField(
                controller: _prenomController,
                label: l10n.firstName,
                icon: Icons.person_outline_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Telephone
              _buildTextField(
                controller: _telephoneController,
                label: l10n.phoneLabel,
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Specialite
              Text(
                l10n.specialtyLabel,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _specialites.map((s) {
                  final isSelected = _specialite == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _specialite = s),
                    selectedColor: AppColors.primary,
                    labelStyle: GoogleFonts.montserrat(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                      color: isSelected ? Colors.white : colorScheme.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    if (_photoFile != null) {
      return Image.file(_photoFile!, fit: BoxFit.cover);
    }
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      if (_photoUrl!.startsWith('http')) {
        return Image.network(_photoUrl!, fit: BoxFit.cover);
      }
      final file = File(_photoUrl!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    final initials =
        '${_prenomController.text.isNotEmpty ? _prenomController.text[0] : ''}'
        '${_nomController.text.isNotEmpty ? _nomController.text[0] : ''}';
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 13,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        filled: true,
        fillColor: colorScheme.onSurface.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
