import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/niveau_scolaire.dart';
import '../../../domain/entities/poste_football.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';

/// Page d'inscription pour un nouvel académicien.
/// Processus étape par étape (Step-by-Step) avec design premium.
class AcademicienRegistrationPage extends StatefulWidget {
  const AcademicienRegistrationPage({super.key});

  @override
  State<AcademicienRegistrationPage> createState() =>
      _AcademicienRegistrationPageState();
}

class _AcademicienRegistrationPageState
    extends State<AcademicienRegistrationPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isLoading = false;
  Academicien? _createdAcademicien;

  // Photo
  File? _photoFile;
  final _picker = ImagePicker();

  // Form keys
  final _step1Key = GlobalKey<FormState>();

  // Data Controllers - Step 1
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _telephoneParentController = TextEditingController();
  DateTime? _selectedDate;

  // Data - Step 2
  String? _selectedPosteId;
  String? _selectedPiedFort;

  // Data - Step 3
  String? _selectedNiveauId;

  // Donnees chargees dynamiquement depuis les referentiels
  List<PosteFootball> _postes = [];
  List<NiveauScolaire> _niveaux = [];

  @override
  void initState() {
    super.initState();
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
    _pageController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _telephoneParentController.dispose();
    super.dispose();
  }

  void _nextStep() {
    bool isValid = false;
    if (_currentStep == 0) {
      isValid = _step1Key.currentState!.validate();
    } else if (_currentStep == 1) {
      if (_selectedPosteId == null || _selectedPiedFort == null) {
        AcademyToast.show(
          context,
          title: 'Champs requis',
          description: 'Veuillez sélectionner un poste et un pied fort',
          isError: true,
        );
      } else {
        isValid = true;
      }
    } else if (_currentStep == 2) {
      if (_selectedNiveauId == null) {
        AcademyToast.show(
          context,
          title: 'Champ requis',
          description: 'Veuillez sélectionner un niveau scolaire',
          isError: true,
        );
      } else {
        isValid = true;
      }
    }

    if (isValid && _currentStep < _totalSteps - 1) {
      if (_currentStep == 2) {
        _confirmAndCreate();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _confirmAndCreate() async {
    setState(() => _isLoading = true);

    try {
      final qrCode = _generateQrCode();

      final academicien = Academicien(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        dateNaissance: _selectedDate!,
        photoUrl: _photoFile?.path ?? '',
        telephoneParent: _telephoneParentController.text.trim(),
        posteFootballId: _selectedPosteId!,
        niveauScolaireId: _selectedNiveauId!,
        codeQrUnique: qrCode,
        piedFort: _selectedPiedFort,
      );

      final created = await DependencyInjection.academicienRepository.create(
        academicien,
      );

      if (mounted) {
        setState(() {
          _createdAcademicien = created;
          _isLoading = false;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AcademyToast.show(
          context,
          title: 'Erreur',
          description: 'Impossible d\'enregistrer l\'academicien : $e',
          isError: true,
        );
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
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
          onPressed: () {
            if (_currentStep > 0 && _currentStep < _totalSteps - 1) {
              _prevStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Inscription Académicien',
          style: GoogleFonts.montserrat(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barre de progression custom
          _buildProgressBar(colorScheme),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1(theme, colorScheme),
                _buildStep2(theme, colorScheme),
                _buildStep3(theme, colorScheme),
                _buildStep4(theme, colorScheme),
              ],
            ),
          ),

          // Navigation dock
          if (_currentStep < _totalSteps - 1)
            _buildNavigationDock(colorScheme, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        children: [
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 6,
            width:
                MediaQuery.of(context).size.width *
                    ((_currentStep + 1) / _totalSteps) -
                48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDock(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Précédent',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == _totalSteps - 2
                              ? 'Confirmer'
                              : 'Continuer',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker(bool isDark) {
    final baseColor = isDark ? Colors.white : Colors.black;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(57),
                      child: _photoFile != null
                          ? Image.file(_photoFile!, fit: BoxFit.cover)
                          : Icon(
                              Icons.person_outline_rounded,
                              size: 50,
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Photo de l\'academicien',
            style: GoogleFonts.montserrat(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '(Optionnel)',
            style: GoogleFonts.montserrat(
              color: isDark
                  ? AppColors.textMutedDark.withValues(alpha: 0.6)
                  : AppColors.textMutedLight.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 1: Identité ---
  Widget _buildStep1(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Identité',
              'Informations personnelles de l\'académicien',
            ),
            const SizedBox(height: 32),

            _buildPhotoPicker(theme.brightness == Brightness.dark),
            const SizedBox(height: 32),

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
              label: 'Prénom',
              hint: 'Saisir le prénom',
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
              label: 'Téléphone Parent',
              hint: '+221 -- --- -- --',
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 2: Sport ---
  Widget _buildStep2(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Football', 'Profil sportif sur le terrain'),
          const SizedBox(height: 32),
          Text(
            'Poste de prédilection',
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
                      setState(() => _selectedPosteId = selected ? p.id : null);
                    },
                    colorScheme: colorScheme,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'Pied fort',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChoiceChip(
                label: 'Droitier',
                isSelected: _selectedPiedFort == 'Droitier',
                onSelected: (s) =>
                    setState(() => _selectedPiedFort = s ? 'Droitier' : null),
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 12),
              _buildChoiceChip(
                label: 'Gaucher',
                isSelected: _selectedPiedFort == 'Gaucher',
                onSelected: (s) =>
                    setState(() => _selectedPiedFort = s ? 'Gaucher' : null),
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 12),
              _buildChoiceChip(
                label: 'Ambidextre',
                isSelected: _selectedPiedFort == 'Ambidextre',
                onSelected: (s) =>
                    setState(() => _selectedPiedFort = s ? 'Ambidextre' : null),
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Step 3: Scolaire ---
  Widget _buildStep3(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Scolarité', 'Niveau académique actuel'),
          const SizedBox(height: 32),
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
        ],
      ),
    );
  }

  // --- Step 4: Recap & QR ---

  String? _generatedQrCode;

  String _generateQrCode() {
    if (_generatedQrCode != null) return _generatedQrCode!;
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final code =
        'PA-ACA-${timestamp.toString().substring(5)}-${random.nextInt(9999).toString().padLeft(4, '0')}';
    _generatedQrCode = code;
    return code;
  }

  String _getPosteName() {
    if (_selectedPosteId == null) return 'Non specifie';
    return _postes
        .firstWhere(
          (p) => p.id == _selectedPosteId,
          orElse: () => PosteFootball(id: '', nom: 'Non specifie'),
        )
        .nom;
  }

  String _getNiveauName() {
    if (_selectedNiveauId == null) return 'Non specifie';
    return _niveaux
        .firstWhere(
          (n) => n.id == _selectedNiveauId,
          orElse: () => NiveauScolaire(id: '', nom: 'Non specifie', ordre: 0),
        )
        .nom;
  }

  Widget _buildStep4(ThemeData theme, ColorScheme colorScheme) {
    if (_createdAcademicien == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = theme.brightness == Brightness.dark;
    final aca = _createdAcademicien!;
    final qrCode = aca.codeQrUnique;
    final nomComplet = '${aca.prenom} ${aca.nom}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Animation de succes
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 56,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Inscription reussie !',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Le badge QR unique de l\'academicien a ete genere\navec succes. Vous pouvez le partager ou le telecharger.',
            style: GoogleFonts.montserrat(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Badge QR premium
          _buildQrBadgeCard(qrCode, nomComplet, colorScheme, isDark),
          const SizedBox(height: 24),

          // Recapitulatif detaille
          _buildRecapCard(nomComplet, colorScheme, isDark),
          const SizedBox(height: 32),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    'Partager',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    'Terminer',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQrBadgeCard(
    String qrCode,
    String nomComplet,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tete badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PEPITES ACADEMY',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ACADEMICIEN',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 2,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // QR Code reel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: qrCode,
              version: QrVersions.auto,
              size: 180,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1C1C1C),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1C1C1C),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nom complet
          Text(
            nomComplet,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getPosteName(),
            style: GoogleFonts.montserrat(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Code QR texte
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              qrCode,
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapCard(
    String nomComplet,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final dateInscription = DateTime.now();
    final dateStr =
        '${dateInscription.day.toString().padLeft(2, '0')}/${dateInscription.month.toString().padLeft(2, '0')}/${dateInscription.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recapitulatif',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecapRow(
            Icons.person_outline,
            'Nom complet',
            nomComplet,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.cake_outlined,
            'Date de naissance',
            _dateNaissanceController.text.isNotEmpty
                ? _dateNaissanceController.text
                : 'Non renseignee',
            colorScheme,
          ),
          _buildRecapRow(
            Icons.phone_android_outlined,
            'Telephone parent',
            _telephoneParentController.text.isNotEmpty
                ? _telephoneParentController.text
                : 'Non renseigne',
            colorScheme,
          ),
          _buildRecapRow(
            Icons.sports_soccer_rounded,
            'Poste',
            _getPosteName(),
            colorScheme,
          ),
          _buildRecapRow(
            Icons.directions_run_rounded,
            'Pied fort',
            _selectedPiedFort ?? 'Non specifie',
            colorScheme,
          ),
          _buildRecapRow(
            Icons.school_outlined,
            'Niveau scolaire',
            _getNiveauName(),
            colorScheme,
          ),
          _buildRecapRow(
            Icons.calendar_today_outlined,
            'Date d\'inscription',
            dateStr,
            colorScheme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRecapRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            height: 1,
          ),
      ],
    );
  }

  // --- Widgets Utilitaires ---

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
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
