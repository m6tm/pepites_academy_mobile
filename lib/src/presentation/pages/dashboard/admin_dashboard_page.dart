import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../injection_container.dart';
import '../../widgets/sync_notification_banner.dart';
import '../auth/login_page.dart';
import 'screens/admin_home_screen.dart';
import 'screens/admin_academy_screen.dart';
import '../academy/academicien_list_page.dart';
import 'screens/admin_seances_screen.dart';
import 'screens/admin_communication_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'widgets/admin_internal_widgets.dart';

/// Dashboard principal pour le profil Administrateur.
/// Offre une vue d'ensemble complete de l'academie avec acces a toutes les fonctionnalites.
class AdminDashboardPage extends StatefulWidget {
  final String userName;
  final String? photoUrl;

  const AdminDashboardPage({
    super.key,
    this.userName = 'Administrateur',
    this.photoUrl,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedNavIndex = 0;
  final _academyKey = GlobalKey<AcademicienListPageState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _fullName;
  DateTime? _lastPressedAt;
  bool _isCheckingBiometric = false;
  bool _biometricAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _loadFullName();
  }

  Future<void> _loadFullName() async {
    final fullName = await DependencyInjection.preferences.getUserFullName();
    if (mounted && fullName.isNotEmpty) {
      setState(() => _fullName = fullName);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[BiometricCheck] AppLifecycleState changed: $state');
    if (state == AppLifecycleState.resumed) {
      _checkBiometricOnResume();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Reinitialiser pour la prochaine verification
      _biometricAuthenticated = false;
    }
  }

  /// Verifie la biometrie au retour dans l'app si une session utilisateur est en cours
  Future<void> _checkBiometricOnResume() async {
    // Eviter les appels multiples et la re-verification apres authentification
    if (_isCheckingBiometric || _biometricAuthenticated) return;
    _isCheckingBiometric = true;

    debugPrint('[BiometricCheck] Verification au retour...');

    try {
      final biometricEnabled = await DependencyInjection.biometricService
          .isBiometricEnabled();
      debugPrint('[BiometricCheck] Biometrie activee: $biometricEnabled');
      if (!biometricEnabled) return;

      // Verifier si une session utilisateur est en cours
      final isLoggedIn = await DependencyInjection.preferences.isUserLoggedIn();
      debugPrint('[BiometricCheck] Session utilisateur: $isLoggedIn');
      if (!isLoggedIn) return;

      if (!mounted) return;

      debugPrint('[BiometricCheck] Demande authentification biometrique...');
      // Demander l'authentification biometrique
      final (authenticated, _) = await DependencyInjection.biometricService
          .authenticate(
            localizedReason: 'Authentifiez-vous pour reprendre votre session',
          );
      debugPrint('[BiometricCheck] Authentifie: $authenticated');

      if (authenticated) {
        _biometricAuthenticated = true;
      } else if (mounted) {
        // Quitter l'application si echec biometrique
        SystemNavigator.pop();
      }
    } finally {
      _isCheckingBiometric = false;
    }
  }

  String _getGreeting() {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  /// Gere le comportement du bouton retour
  Future<bool> _handleBackPress() async {
    // Si on est sur un autre tab que Accueil, rediriger vers Accueil
    if (_selectedNavIndex != 0) {
      setState(() => _selectedNavIndex = 0);
      return false;
    }

    // Si on est sur Accueil, verifier le double appui pour quitter
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pressAgainToExit),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBackPress();
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SyncNotificationBanner(
                connectivityState: DependencyInjection.connectivityState,
                syncState: DependencyInjection.syncState,
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: IndexedStack(
                    index: _selectedNavIndex,
                    children: [
                      AdminHomeScreen(
                        userName: widget.userName,
                        greeting: _getGreeting(),
                        photoUrl: widget.photoUrl,
                        onNavigateToTab: (index) {
                          setState(() => _selectedNavIndex = index);
                          if (index == 1) {
                            _academyKey.currentState?.reload();
                          }
                        },
                      ),
                      AdminAcademyScreen(academyListKey: _academyKey),
                      const AdminSeancesScreen(),
                      const AdminCommunicationScreen(),
                      AdminSettingsScreen(
                        userName: widget.userName,
                        fullName: _fullName,
                        photoUrl: widget.photoUrl,
                        onLogout: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(
          colorScheme,
          AppLocalizations.of(context)!,
        ),
      ),
    );
  }

  /// Gestion de la deconnexion avec confirmation
  void _handleLogout() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.logoutTitle,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.logoutConfirmation,
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel, style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop();
                // Désactiver la biométrie sur le backend avant déconnexion
                await DependencyInjection.biometricService.disableBiometric();
                await DependencyInjection.authService.logout();
                if (mounted) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                l10n.logoutButton,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Barre de navigation inferieure
  Widget _buildBottomNav(ColorScheme colorScheme, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              AdminNavItem(
                icon: Icons.dashboard_rounded,
                label: l10n.home,
                isSelected: _selectedNavIndex == 0,
                onTap: () => setState(() => _selectedNavIndex = 0),
              ),
              AdminNavItem(
                icon: Icons.school_rounded,
                label: l10n.academy,
                isSelected: _selectedNavIndex == 1,
                onTap: () {
                  setState(() => _selectedNavIndex = 1);
                  _academyKey.currentState?.reload();
                },
              ),
              AdminNavItem(
                icon: Icons.sports_soccer_rounded,
                label: l10n.sessions,
                isSelected: _selectedNavIndex == 2,
                onTap: () => setState(() => _selectedNavIndex = 2),
              ),
              AdminNavItem(
                icon: Icons.sms_rounded,
                label: l10n.communication,
                isSelected: _selectedNavIndex == 3,
                onTap: () => setState(() => _selectedNavIndex = 3),
              ),
              AdminNavItem(
                icon: Icons.settings_rounded,
                label: l10n.settings,
                isSelected: _selectedNavIndex == 4,
                onTap: () => setState(() => _selectedNavIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
