import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../domain/entities/encadreur.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/repositories/encadreur_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';
import '../../../../l10n/app_localizations.dart';

/// Page d'inscription pour un nouvel encadreur.
/// Processus en 3 etapes : Infos personnelles, Infos sportives, Recapitulatif + QR.
class EncadreurRegistrationPage extends StatefulWidget {
  final EncadreurRepository repository;

  const EncadreurRegistrationPage({super.key, required this.repository});

  @override
  State<EncadreurRegistrationPage> createState() =>
      _EncadreurRegistrationPageState();
}

class _EncadreurRegistrationPageState extends State<EncadreurRegistrationPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  int _currentStep = 0;
  final int _totalSteps = 3;
  bool _isLoading = false;
  Encadreur? _createdEncadreur;

  final _step1Key = GlobalKey<FormState>();

  // Controleurs Step 1
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  File? _photoFile;
  final _picker = ImagePicker();

  // Data Step 2
  String? _selectedSpecialite;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> get _translatedSpecialites => [
    {
      'id': 'technique',
      'nom': l10n.specialityTechnique,
      'icon': Icons.sports_soccer_rounded,
      'description': l10n.specialityTechniqueDesc,
    },
    {
      'id': 'physique',
      'nom': l10n.specialityPhysique,
      'icon': Icons.fitness_center_rounded,
      'description': l10n.specialityPhysiqueDesc,
    },
    {
      'id': 'tactique',
      'nom': l10n.specialityTactique,
      'icon': Icons.psychology_rounded,
      'description': l10n.specialityTactiqueDesc,
    },
    {
      'id': 'gardien',
      'nom': l10n.specialityGardien,
      'icon': Icons.pan_tool_rounded,
      'description': l10n.specialityGardienDesc,
    },
    {
      'id': 'formation_jeunes',
      'nom': l10n.specialityFormationJeunes,
      'icon': Icons.child_care_rounded,
      'description': l10n.specialityFormationJeunesDesc,
    },
    {
      'id': 'preparation_mentale',
      'nom': l10n.specialityPreparationMentale,
      'icon': Icons.self_improvement_rounded,
      'description': l10n.specialityPreparationMentaleDesc,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _fadeController.dispose();
    super.dispose();
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
          description: 'Impossible d\'ouvrir la galerie.',
          isError: true,
        );
      }
    }
  }

  void _nextStep() {
    bool isValid = false;

    if (_currentStep == 0) {
      isValid = _step1Key.currentState!.validate();
    } else if (_currentStep == 1) {
      if (_selectedSpecialite == null) {
        AcademyToast.show(
          context,
          title: l10n.requiredLabel,
          description: l10n.specialtyRequiredError,
          isError: true,
        );
      } else {
        isValid = true;
      }
    }

    if (isValid && _currentStep < _totalSteps - 1) {
      if (_currentStep == 1) {
        _confirmAndCreate();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
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

  Future<void> _confirmAndCreate() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final qrCode =
          'ENC-${now.millisecondsSinceEpoch}-${_nomController.text.toUpperCase().substring(0, 2)}${_prenomController.text.toUpperCase().substring(0, 2)}';

      final encadreur = Encadreur(
        id: now.millisecondsSinceEpoch.toString(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        photoUrl: _photoFile?.path ?? '',
        specialite: _selectedSpecialite!,
        role: UserRole.encadreur,
        codeQrUnique: qrCode,
        createdAt: now,
      );

      final created = await widget.repository.create(encadreur);

      if (mounted) {
        setState(() {
          _createdEncadreur = created;
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
          title: l10n.error,
          description: l10n.coachSaveError(e.toString()),
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
          onPressed: () {
            if (_currentStep > 0 && _currentStep < _totalSteps - 1) {
              _prevStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          l10n.newCoachRegistrationTitle,
          style: GoogleFonts.montserrat(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_currentStep < _totalSteps - 1)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentStep + 1}/$_totalSteps',
                style: GoogleFonts.montserrat(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressBar(colorScheme),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStep1PersonalInfo(theme, colorScheme, isDark),
                  _buildStep2SportInfo(theme, colorScheme, isDark),
                  _buildStep3Recap(theme, colorScheme, isDark),
                ],
              ),
            ),
            if (_currentStep < _totalSteps - 1)
              _buildNavigationDock(colorScheme, isDark),
          ],
        ),
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
              gradient: const LinearGradient(
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
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.previousLabel,
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
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 1
                              ? l10n.confirm_label
                              : l10n.continue_label,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _currentStep == 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ETAPE 1 : Informations personnelles
  // ============================================================
  Widget _buildStep1PersonalInfo(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              l10n.identityLabel,
              l10n.coachPersonalDetails,
              Icons.person_rounded,
              colorScheme,
            ),
            const SizedBox(height: 32),

            // Photo de profil
            _buildPhotoPicker(isDark),
            const SizedBox(height: 32),

            // Nom
            _buildPremiumTextField(
              controller: _nomController,
              label: l10n.lastName,
              hint: l10n.enterCoachLastNameHint,
              icon: Icons.badge_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
              colorScheme: colorScheme,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Prenom
            _buildPremiumTextField(
              controller: _prenomController,
              label: l10n.firstName,
              hint: l10n.enterCoachFirstNameHint,
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
              colorScheme: colorScheme,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Telephone
            _buildPremiumTextField(
              controller: _telephoneController,
              label: l10n.phoneNumberLabel,
              hint: l10n.phoneHint,
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.phoneRequired : null,
              colorScheme: colorScheme,
              isDark: isDark,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ETAPE 2 : Informations sportives
  // ============================================================
  Widget _buildStep2SportInfo(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            l10n.specialtyLabel,
            l10n.sportExpertiseSubtitle,
            Icons.sports_rounded,
            colorScheme,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.coachSpecialtyInstructions,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Grille de specialites
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _translatedSpecialites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final spec = _translatedSpecialites[index];
              final isSelected = _selectedSpecialite == spec['nom'];
              return _buildSpecialiteCard(
                nom: spec['nom'] as String,
                description: spec['description'] as String,
                icon: spec['icon'] as IconData,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedSpecialite = spec['nom'] as String);
                },
                colorScheme: colorScheme,
                isDark: isDark,
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============================================================
  // ETAPE 3 : Recapitulatif + QR Code
  // ============================================================
  Widget _buildStep3Recap(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (_createdEncadreur == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final enc = _createdEncadreur!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icone de succes animee
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.coachRegisteredSuccess,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.qrBadgeGeneratedSuccess,
            style: GoogleFonts.montserrat(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Carte badge QR
          _buildQrBadgeCard(enc, colorScheme, isDark),
          const SizedBox(height: 24),

          // Recapitulatif des informations
          _buildRecapCard(enc, colorScheme, isDark),
          const SizedBox(height: 32),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    l10n.shareLabel,
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
                    l10n.finishLabel,
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

  // ============================================================
  // Widgets utilitaires
  // ============================================================

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
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
                              Icons.sports_rounded,
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
            l10n.academicianPhotoLabel,
            style: GoogleFonts.montserrat(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            l10n.optionalLabel,
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

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
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
            hintStyle: GoogleFonts.montserrat(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: colorScheme.onSurface.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialiteCard({
    required String nom,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : (isDark ? colorScheme.surface : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : colorScheme.onSurface.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : colorScheme.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: GoogleFonts.montserrat(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 15,
                      color: isSelected
                          ? AppColors.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : colorScheme.onSurface.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrBadgeCard(
    Encadreur enc,
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
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.coachBadgeType,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 2,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // QR Code
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: enc.codeQrUnique,
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

          // Nom
          Text(
            enc.nomComplet,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            enc.specialite,
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
              enc.codeQrUnique,
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

  Widget _buildRecapCard(Encadreur enc, ColorScheme colorScheme, bool isDark) {
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
            l10n.recapTitle,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecapRow(
            Icons.person_outline,
            l10n.fullNameLabel,
            enc.nomComplet,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.phone_android_outlined,
            l10n.phoneNumberLabel,
            enc.telephone,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.sports_rounded,
            l10n.specialtyLabel,
            enc.specialite,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.shield_outlined,
            l10n.roleLabel,
            l10n.profileCoach,
            colorScheme,
          ),
          _buildRecapRow(
            Icons.calendar_today_outlined,
            l10n.registrationDateLabel,
            '${enc.createdAt.day.toString().padLeft(2, '0')}/${enc.createdAt.month.toString().padLeft(2, '0')}/${enc.createdAt.year}',
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
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colorScheme.onSurface,
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
}
