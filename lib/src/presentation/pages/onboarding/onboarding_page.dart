import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../injection_container.dart';
import '../../../presentation/theme/app_colors.dart';
import '../auth/login_page.dart';

/// Un modèle représentant une diapositive de l'onboarding.
class OnboardingSlide {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

/// Page d'onboarding mobile premium pour Pépites Academy.
/// Utilise un design moderne, des effets de Glassmorphism et des transitions fluides.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Construit la liste des slides avec les traductions.
  List<OnboardingSlide> _buildSlides(AppLocalizations l10n) {
    return [
      OnboardingSlide(
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        imagePath: "assets/tours/tour_element_1.png",
      ),
      OnboardingSlide(
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        imagePath: "assets/tours/tour_element_2.png",
      ),
      OnboardingSlide(
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        imagePath: "assets/tours/tour_element_3.png",
      ),
      OnboardingSlide(
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
        imagePath: "assets/tours/tour_element_4.png",
      ),
      OnboardingSlide(
        title: l10n.onboardingTitle5,
        description: l10n.onboardingDesc5,
        imagePath: "assets/tours/tour_element_5.png",
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await DependencyInjection.preferences.setOnboardingCompleted();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = _buildSlides(l10n);

    return Scaffold(
      body: Stack(
        children: [
          // Carousel de fond avec effet de parallaxe discret
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page! - index);
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 1.0 + (1.0 - value) * 0.1,
                      child: _BackgroundSlide(slide: slides[index]),
                    ),
                  );
                },
              );
            },
          ),

          // Contenu superposé (Glassmorphism)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _ContentOverlay(
              slide: slides[_currentPage],
              currentPage: _currentPage,
              totalPages: slides.length,
              onNext: _onNextPage,
              onSkip: _finishOnboarding,
              nextLabel: l10n.onboardingNext,
              startLabel: l10n.onboardingStart,
            ),
          ),

          // Bouton "Passer" en haut à droite
          if (_currentPage < slides.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 20,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  l10n.onboardingSkip,
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Affiche l'image de fond plein écran avec un overlay sombre dynamique pour la lisibilité.
class _BackgroundSlide extends StatelessWidget {
  final OnboardingSlide slide;

  const _BackgroundSlide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          slide.imagePath,
          fit: BoxFit.cover, // Couvre toute la page
          filterQuality: FilterQuality.high,
        ),
        // Overlay dégradé sombre multicouche pour une lisibilité premium
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.5),
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte de contenu avec effet Glassmorphism.
class _ContentOverlay extends StatelessWidget {
  final OnboardingSlide slide;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;
  final String startLabel;

  const _ContentOverlay({
    required this.slide,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
    required this.nextLabel,
    required this.startLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = currentPage == totalPages - 1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Indicateurs de pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalPages,
                  (index) => _PageIndicator(isActive: index == currentPage),
                ),
              ),
              const SizedBox(height: 32),

              // Titre
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Bouton d'action
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isLastPage ? startLabel : nextLabel,
                      key: ValueKey(isLastPage),
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Petit point indicateur de page.
class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }
}
