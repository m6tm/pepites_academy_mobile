import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/niveau_scolaire.dart';
import '../../../domain/entities/poste_football.dart';
import '../../../infrastructure/repositories/academicien_repository_impl.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';

/// Page de modification des informations d'un academicien.
/// Formulaire pre-rempli avec les donnees actuelles.
class AcademicienEditPage extends StatefulWidget {
  final Academicien academicien;
  final AcademicienRepositoryImpl repository;
  final Map<String, PosteFootball> postesMap;
  final Map<String, NiveauScolaire> niveauxMap;

  const AcademicienEditPage({
    super.key,
    required this.academicien,
    required this.repository,
    required this.postesMap,
    required this.niveauxMap,
  });

  @override
  State<AcademicienEditPage> createState() => _AcademicienEditPageState();
}

class _AcademicienEditPageState extends State<AcademicienEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _telephoneParentController;

  DateTime? _selectedDate;
  String? _selectedPosteId;
  String? _selectedPiedFort;
  String? _selectedNiveauId;
  File? _photoFile;
  final _picker = ImagePicker();

  List<PosteFootball> _postes = [];
  List<NiveauScolaire> _niveaux = [];

  @override
  void initState() {
    super.initState();
    final a = widget.academicien;
    _nomController = TextEditingController(text: a.nom);
    _prenomController = TextEditingController(text: a.prenom);
    _selectedDate = a.dateNaissance;
    _dateNaissanceController = TextEditingController(
      text:
          '${a.dateNaissance.day.toString().padLeft(2, '0')}/${a.dateNaissance.month.toString().padLeft(2, '0')}/${a.dateNaissance.year}',
    );
    _telephoneParentController = TextEditingController(text: a.telephoneParent);
    _selectedPosteId = a.posteFootballId;
    _selectedPiedFort = a.piedFort;
    _selectedNiveauId = a.niveauScolaireId;

    if (a.photoUrl.isNotEmpty && File(a.photoUrl).existsSync()) {
      _photoFile = File(a.photoUrl);
    }

    _chargerReferentiels();
  }

  Future<void> _chargerReferentiels() async {
    final postes = await DependencyInjection.referentielService.getAllPostes();
    final niveaux = await DependencyInjection.referentielService
        .getAllNiveaux();
    if (mounted) {
      setState(() {
        _postes = postes;
        _niveaux = niveaux;
      });
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _telephoneParentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2012),
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textMainLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateNaissanceController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() => _photoFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Erreur selection image: $e');
      if (mounted) {
        AcademyToast.show(
          context,
          title: 'Erreur',
          description: 'Impossible d\'ouvrir la galerie',
          isError: true,
        );
      }
    }
  }

  Future<void> _enregistrerModifications() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPosteId == null || _selectedPiedFort == null) {
      AcademyToast.show(
        context,
        title: 'Champs requis',
        description: 'Veuillez selectionner un poste et un pied fort',
        isError: true,
      );
      return;
    }

    if (_selectedNiveauId == null) {
      AcademyToast.show(
        context,
        title: 'Champ requis',
        description: 'Veuillez selectionner un niveau scolaire',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updated = Academicien(
        id: widget.academicien.id,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        dateNaissance: _selectedDate!,
        photoUrl: _photoFile?.path ?? widget.academicien.photoUrl,
        telephoneParent: _telephoneParentController.text.trim(),
        posteFootballId: _selectedPosteId!,
        niveauScolaireId: _selectedNiveauId!,
        codeQrUnique: widget.academicien.codeQrUnique,
        piedFort: _selectedPiedFort,
      );

      await widget.repository.update(updated);

      if (mounted) {
        AcademyToast.show(
          context,
          title: 'Modifications enregistrees',
          description:
              '${updated.prenom} ${updated.nom} a ete mis a jour avec succes.',
        );
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AcademyToast.show(
          context,
          title: 'Erreur',
          description: 'Impossible de mettre a jour : $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Modifier le profil',
          style: GoogleFonts.montserrat(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppColors.primary),
              onPressed: _enregistrerModifications,
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoPicker(isDark),
              const SizedBox(height: 32),
              _buildSectionTitle('Identite', Icons.person_rounded),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nomController,
                label: 'Nom',
                hint: 'Saisir le nom',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _prenomController,
                label: 'Prenom',
                hint: 'Saisir le prenom',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dateNaissanceController,
                    label: 'Date de naissance',
                    hint: 'JJ/MM/AAAA',
                    icon: Icons.calendar_today_outlined,
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _telephoneParentController,
                label: 'Telephone Parent',
                hint: '+221 -- --- -- --',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Football', Icons.sports_soccer_rounded),
              const SizedBox(height: 16),
              Text(
                'Poste de predilection',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _postes
                    .map(
                      (p) => _buildChoiceChip(
                        label: p.nom,
                        icon: Icons.sports_soccer_rounded,
                        isSelected: _selectedPosteId == p.id,
                        onSelected: (selected) {
                          setState(
                            () => _selectedPosteId = selected ? p.id : null,
                          );
                        },
                        colorScheme: colorScheme,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Pied fort',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildChoiceChip(
                    label: 'Droitier',
                    isSelected: _selectedPiedFort == 'Droitier',
                    onSelected: (s) => setState(
                      () => _selectedPiedFort = s ? 'Droitier' : null,
                    ),
                    colorScheme: colorScheme,
                  ),
                  _buildChoiceChip(
                    label: 'Gaucher',
                    isSelected: _selectedPiedFort == 'Gaucher',
                    onSelected: (s) => setState(
                      () => _selectedPiedFort = s ? 'Gaucher' : null,
                    ),
                    colorScheme: colorScheme,
                  ),
                  _buildChoiceChip(
                    label: 'Ambidextre',
                    isSelected: _selectedPiedFort == 'Ambidextre',
                    onSelected: (s) => setState(
                      () => _selectedPiedFort = s ? 'Ambidextre' : null,
                    ),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Scolarite', Icons.school_rounded),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _niveaux.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final n = _niveaux[index];
                  final isSelected = _selectedNiveauId == n.id;
                  return InkWell(
                    onTap: () => setState(() => _selectedNiveauId = n.id),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : colorScheme.onSurface.withValues(alpha: 0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            color: isSelected
                                ? AppColors.primary
                                : colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            n.nom,
                            style: GoogleFonts.montserrat(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enregistrerModifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Enregistrer les modifications',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: _photoFile != null && _photoFile!.existsSync()
                    ? Image.file(_photoFile!, fit: BoxFit.cover)
                    : Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
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
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required Function(bool) onSelected,
    required ColorScheme colorScheme,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : colorScheme.onSurface,
            ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: colorScheme.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : colorScheme.onSurface.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      labelStyle: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primary : colorScheme.onSurface,
      ),
      showCheckmark: false,
    );
  }
}
