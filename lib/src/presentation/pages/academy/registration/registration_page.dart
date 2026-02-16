import 'package:flutter/material.dart';
// ListenableBuilder is used instead of provider
import 'package:pepites_academy_mobile/src/domain/entities/niveau_scolaire.dart';
import 'package:pepites_academy_mobile/src/domain/entities/poste_football.dart';
import 'package:pepites_academy_mobile/src/injection_container.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/step_progress_indicator.dart';
import 'package:pepites_academy_mobile/src/presentation/state/academy_registration_state.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/academy/registration/steps/identity_step.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/academy/registration/steps/football_step.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/academy/registration/steps/school_step.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/academy/registration/steps/recap_step.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/academy/registration/registration_success_page.dart';

class AcademyRegistrationPage extends StatefulWidget {
  const AcademyRegistrationPage({super.key});

  @override
  State<AcademyRegistrationPage> createState() =>
      _AcademyRegistrationPageState();
}

class _AcademyRegistrationPageState extends State<AcademyRegistrationPage> {
  late AcademyRegistrationState _state;
  late PageController _pageController;
  List<PosteFootball> _postes = [];
  List<NiveauScolaire> _niveaux = [];

  @override
  void initState() {
    super.initState();
    _state = AcademyRegistrationState();
    _pageController = PageController();
    _state.addListener(_onStateChanged);
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

  void _onStateChanged() {
    if (_pageController.hasClients &&
        _pageController.page?.round() != _state.currentStep) {
      _pageController.animateToPage(
        _state.currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("INSCRIPTION"),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: StepProgressIndicator(
                  currentStep: _state.currentStep,
                  totalSteps: 4,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    IdentityStep(state: _state),
                    FootballStep(state: _state, postes: _postes),
                    SchoolStep(state: _state, niveaux: _niveaux),
                    RecapStep(
                      state: _state,
                      postes: _postes,
                      niveaux: _niveaux,
                    ),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    bool isLastStep = _state.currentStep == 3;
    bool canGoNext = true;

    if (_state.currentStep == 0) canGoNext = _state.isStep1Valid;
    if (_state.currentStep == 1) canGoNext = _state.isStep2Valid;
    if (_state.currentStep == 2) canGoNext = _state.isStep3Valid;
    if (_state.currentStep == 3) canGoNext = _state.canConfirm;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_state.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _state.previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("PRÉCÉDENT"),
              ),
            ),
          if (_state.currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canGoNext
                  ? () {
                      if (isLastStep) {
                        _handleFinalValidation();
                      } else {
                        _state.nextStep();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
                minimumSize: const Size(0, 56),
              ),
              child: Text(isLastStep ? "CONFIRMER L'INSCRIPTION" : "CONTINUER"),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFinalValidation() {
    // Generate a pseudo-unique QR (In real app, this would come from backend)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final qrData =
        "ACAD-${_state.nom?.substring(0, 2).toUpperCase()}-$timestamp";

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RegistrationSuccessPage(
          academicienName: "${_state.prenom} ${_state.nom}",
          qrData: qrData,
          photoPath: _state.photoPath,
        ),
      ),
    );
  }
}
