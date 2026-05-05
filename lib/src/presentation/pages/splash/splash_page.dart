import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../injection_container.dart';
import '../../../domain/entities/role.dart';
import '../../../application/services/role_service.dart';
import '../../pages/dashboard/medecin_dashboard_page.dart';
import '../../../application/services/app_preferences.dart';
import '../onboarding/onboarding_page.dart';
import '../auth/login_page.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../dashboard/encadreur_dashboard_page.dart';
import '../dashboard/supadmin_dashboard_page.dart';
import '../../theme/app_colors.dart';

/// Page de démarrage (Splash Screen) pour Pépites Academy.
/// Design premium avec effet Glassmorphism et esthétique Sports Tech.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Navigation automatique après le délai du splash
    Future.delayed(const Duration(seconds: 4), () async {
      try {
        final preferences = DependencyInjection.preferences;
        final bool isLoggedIn = await preferences.isUserLoggedIn();

        if (isLoggedIn && mounted) {
          // Verifier si l'authentification biometrique est activee
          final bool biometricEnabled = await DependencyInjection.biometricService
              .isBiometricEnabled();

          if (biometricEnabled) {
            // Demander l'authentification biometrique
            final (
              authenticated,
              error,
            ) = await DependencyInjection.biometricService.authenticate(
              localizedReason:
                  'Authentifiez-vous pour acceder a votre compte Pepites Academy',
            );

            if (!authenticated) {
              // Echec de l'authentification biometrique
              if (mounted) {
                _showBiometricFailedDialog(preferences, error);
              }
              return;
            }
          }

          // Synchroniser les referentiels et académiciens en arrière-plan (non bloquant)
          DependencyInjection.syncReferentiels();
          DependencyInjection.syncAcademiciens();

          // Envoyer le token FCM au serveur (non bloquant)
          DependencyInjection.firebasePushNotificationService
              .sendTokenToServer();

          // Synchroniser les opérations en attente (non bloquant)
          DependencyInjection.syncState.syncNow();

          final roleId = await preferences.getUserRole();
          final savedName = await preferences.getUserName();
          final photoUrl = await preferences.getUserPhoto();
          
          if (roleId != null && mounted) {
            final l10n = AppLocalizations.of(context);
            final userName = savedName ?? l10n?.defaultUser ?? 'Utilisateur';
            final role = Role.fromId(roleId);
            
            final dashboardType = DependencyInjection.roleService.getDashboardForRole(role);
            
            Widget dashboardPage;
            switch (dashboardType) {
              case DashboardType.admin:
                dashboardPage = role == Role.supAdmin 
                  ? SupAdminDashboardPage(userName: userName, photoUrl: photoUrl)
                  : AdminDashboardPage(userName: userName, photoUrl: photoUrl);
                break;
              case DashboardType.encadreur:
                dashboardPage = EncadreurDashboardPage(userName: userName, photoUrl: photoUrl);
                break;
              case DashboardType.medecin:
                dashboardPage = MedecinDashboardPage(userName: userName, photoUrl: photoUrl);
                break;
              case DashboardType.surveillant:
                dashboardPage = EncadreurDashboardPage(userName: userName, photoUrl: photoUrl, showScanner: false, showCommunication: true);
                break;
              case DashboardType.visiteur:
                dashboardPage = EncadreurDashboardPage(userName: userName, photoUrl: photoUrl, showScanner: false);
                break;
            }

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => dashboardPage),
            );
            return;
          }
        }

        final bool isOnboardingCompleted = await preferences
            .isOnboardingCompleted();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => isOnboardingCompleted
                  ? const LoginPage()
                  : const OnboardingPage(),
            ),
          );
        }
      } catch (e) {
        debugPrint('Erreur critique lors de l\'initialisation du splash: $e');
        // En cas d'erreur fatale, on tente quand même d'aller vers la page de login
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    });
  }

  /// Affiche un dialogue lors de l'echec de l'authentification biometrique.
  void _showBiometricFailedDialog(AppPreferences preferences, [String? error]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Authentification echouee',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'L\'authentification biometrique a echoue. Voulez-vous vous connecter '
              'avec vos identifiants ou reessayer ?',
              style: GoogleFonts.montserrat(),
            ),
            if (error != null && error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Raison: $error',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Desactiver la biometrie et deconnecter
              await DependencyInjection.biometricService.disableBiometric();
              await preferences.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => const LoginPage()),
                );
              }
            },
            child: Text(
              'Se connecter',
              style: GoogleFonts.montserrat(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Relancer le processus d'authentification biometrique
              _retryBiometricAuth(preferences);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Reessayer', style: GoogleFonts.montserrat()),
          ),
        ],
      ),
    );
  }

  /// Relance l'authentification biometrique.
  Future<void> _retryBiometricAuth(AppPreferences preferences) async {
    final (authenticated, error) = await DependencyInjection.biometricService
        .authenticate(
          localizedReason:
              'Authentifiez-vous pour acceder a votre compte Pepites Academy',
        );

    if (!authenticated) {
      if (mounted) {
        _showBiometricFailedDialog(preferences, error);
      }
      return;
    }

    // Authentification reussie, continuer vers le dashboard
    if (!mounted) return;

    await DependencyInjection.syncReferentiels();
    await DependencyInjection.syncAcademiciens();

    // Envoyer le token FCM au serveur (session active)
    await DependencyInjection.firebasePushNotificationService
        .sendTokenToServer();

    DependencyInjection.syncState.syncNow();

    final roleId = await preferences.getUserRole();
    final savedName = await preferences.getUserName();
    final photoUrl = await preferences.getUserPhoto();

    if (roleId != null && mounted) {
      final l10n = AppLocalizations.of(context);
      final userName = savedName ?? l10n?.defaultUser ?? 'Utilisateur';
      final role = Role.fromId(roleId);
      
      final dashboardType = DependencyInjection.roleService.getDashboardForRole(role);
      
      Widget dashboardPage;
      switch (dashboardType) {
        case DashboardType.admin:
          dashboardPage = role == Role.supAdmin 
            ? SupAdminDashboardPage(userName: userName, photoUrl: photoUrl)
            : AdminDashboardPage(userName: userName, photoUrl: photoUrl);
          break;
        case DashboardType.encadreur:
          dashboardPage = EncadreurDashboardPage(userName: userName, photoUrl: photoUrl);
          break;
        case DashboardType.medecin:
          dashboardPage = MedecinDashboardPage(userName: userName, photoUrl: photoUrl);
          break;
        case DashboardType.surveillant:
          dashboardPage = EncadreurDashboardPage(userName: userName, photoUrl: photoUrl, showScanner: false, showCommunication: true);
          break;
        case DashboardType.visiteur:
          dashboardPage = EncadreurDashboardPage(userName: userName, photoUrl: photoUrl, showScanner: false);
          break;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => dashboardPage),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background Image with high quality filters
          Positioned.fill(
            child: Image.asset(
              'assets/splash/splash_background.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              color: Colors.black.withValues(alpha: 0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Background Abstract Elements (Sport Tech Aesthetic)
          const _BackgroundPainter(),

          // Radial Glow in the center
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content with Glassmorphism
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120), // Remontée de la carte
                    // Glass Card with reduced blur
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Logo and Text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    'PÉPITES',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'ACADEMY',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),

          // Loader Positioned at the bottom
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const _CreativePulseLoader(),
            ),
          ),

          // Bottom subtle text
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                AppLocalizations.of(context)?.splashTagline ??
                    'L\'excellence du football',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loader créatif style 'Sport Tech Pulse' - Barre de progression indéterminée
class _CreativePulseLoader extends StatefulWidget {
  const _CreativePulseLoader();

  @override
  State<_CreativePulseLoader> createState() => _CreativePulseLoaderState();
}

class _CreativePulseLoaderState extends State<_CreativePulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _progressAnimation = Tween<double>(begin: -0.4, end: 1.4).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Barre de progression avec dégradé qui se déplace
            SizedBox(
              width: 180,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    // Fond de la barre
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Barre de progression animée
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.5,
                      child: Transform.translate(
                        offset: Offset(_progressAnimation.value * 180 - 90, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary.withValues(alpha: 0.8),
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Peintre personnalisé pour les éléments de fond abstraits (lignes de terrain, etc.)
class _BackgroundPainter extends StatelessWidget {
  const _BackgroundPainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _FieldLinesPainter());
  }
}

class _FieldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Dessiner des arcs de cercle pour simuler des zones de terrain
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.1, size.height * 0.1),
        radius: 150,
      ),
      0,
      1.5,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.9, size.height * 0.8),
        radius: 200,
      ),
      3,
      1.5,
      false,
      paint,
    );

    // Lignes de mouvement cinétiques
    for (var i = 0; i < 8; i++) {
      final y = size.height * (0.1 + (i * 0.12));
      final opacity = (0.02 + (i * 0.005)).clamp(0.0, 0.05);

      canvas.drawLine(
        Offset(-20, y),
        Offset(size.width * 0.4, y + 20),
        paint..color = Colors.white.withValues(alpha: opacity),
      );
    }

    // Lignes d'énergie accentuées avec la couleur primaire
    final energyPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Path energyPath = Path();
    energyPath.moveTo(size.width * 0.7, 0);
    energyPath.lineTo(size.width * 0.3, size.height);

    canvas.drawPath(energyPath, energyPaint);

    canvas.drawPath(
      energyPath.shift(const Offset(15, 0)),
      energyPaint..color = AppColors.primary.withValues(alpha: 0.04),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
