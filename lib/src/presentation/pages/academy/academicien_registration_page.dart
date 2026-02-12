import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';
import '../../../domain/entities/poste_football.dart';
import '../../../domain/entities/niveau_scolaire.dart';

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

  // Mock data for dropdowns (will be fetched from repos later)
  final List<PosteFootball> _postes = [
    PosteFootball(id: '1', nom: 'Gardien', icone: Icons.pan_tool_rounded),
    PosteFootball(
      id: '2',
      nom: 'Défenseur central',
      icone: Icons.security_rounded,
    ),
    PosteFootball(id: '3', nom: 'Latéral', icone: Icons.directions_run_rounded),
    PosteFootball(id: '4', nom: 'Milieu défensif', icone: Icons.anchor_rounded),
    PosteFootball(
      id: '5',
      nom: 'Milieu offensif',
      icone: Icons.auto_awesome_rounded,
    ),
    PosteFootball(id: '6', nom: 'Ailier', icone: Icons.flash_on_rounded),
    PosteFootball(
      id: '7',
      nom: 'Avant-centre',
      icone: Icons.sports_soccer_rounded,
    ),
  ];

  final List<NiveauScolaire> _niveaux = [
    NiveauScolaire(id: '1', nom: 'CM1', ordre: 1),
    NiveauScolaire(id: '2', nom: 'CM2', ordre: 2),
    NiveauScolaire(id: '3', nom: '6ème', ordre: 3),
    NiveauScolaire(id: '4', nom: '5ème', ordre: 4),
    NiveauScolaire(id: '5', nom: '4ème', ordre: 5),
    NiveauScolaire(id: '6', nom: '3ème', ordre: 6),
  ];

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
    if (_currentStep == 0)
      isValid = _step1Key.currentState!.validate();
    else if (_currentStep == 1) {
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
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStep == _totalSteps - 2 ? 'Confirmer' : 'Continuer',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
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
                    icon: p.icone ?? Icons.sports_soccer_rounded,
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
                icon: '🦶',
                isSelected: _selectedPiedFort == 'Droitier',
                onSelected: (s) =>
                    setState(() => _selectedPiedFort = s ? 'Droitier' : null),
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 12),
              _buildChoiceChip(
                label: 'Gaucher',
                icon: '🦶',
                isSelected: _selectedPiedFort == 'Gaucher',
                onSelected: (s) =>
                    setState(() => _selectedPiedFort = s ? 'Gaucher' : null),
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 12),
              _buildChoiceChip(
                label: 'Ambi.',
                icon: '👣',
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
  Widget _buildStep4(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF10B981),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Inscription réussie !',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Le badge QR de l\'académicien a été généré.',
            style: GoogleFonts.montserrat(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Badge QR Simulé
          Container(
            padding: const EdgeInsets.all(20),
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
                Text(
                  'PEPITES ACADEMY',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                // Placeholder pour le QR Code
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.qr_code_2_rounded, size: 140),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${_nomController.text} ${_prenomController.text}',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _postes.firstWhere((p) => p.id == _selectedPosteId).nom,
                  style: GoogleFonts.montserrat(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: const Text('Partager le badge'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Terminer'),
                ),
              ),
            ],
          ),
        ],
      ),
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
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required dynamic icon,
    required bool isSelected,
    required Function(bool) onSelected,
    required ColorScheme colorScheme,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon is IconData)
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : colorScheme.onSurface,
            )
          else
            Text(icon.toString()),
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
