import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../injection_container.dart';
import '../../widgets/sync_notification_banner.dart';
import '../auth/login_page.dart';
import 'screens/supadmin_home_screen.dart';
import '../academy/academicien_list_page.dart';
import 'screens/admin_seances_screen.dart';
import 'screens/admin_communication_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'widgets/admin_internal_widgets.dart';

/// Dashboard principal pour le profil Super Administrateur.
/// Offre une vue d'ensemble complete de l'academie avec acces a toutes les fonctionnalites.
class SupAdminDashboardPage extends StatefulWidget {
  final String userName;
  final String? photoUrl;

  const SupAdminDashboardPage({
    super.key,
    this.userName = 'Super Admin',
    this.photoUrl,
  });

  @override
  State<SupAdminDashboardPage> createState() => _SupAdminDashboardPageState();
}

class _SupAdminDashboardPageState extends State<SupAdminDashboardPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedNavIndex = 0;
  final _academyKey = GlobalKey<AcademicienListPageState>();
  final _homeKey = GlobalKey<SupAdminHomeScreenState>();
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
    if (state == AppLifecycleState.resumed) {
      _checkBiometricOnResume();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() => _biometricAuthenticated = false);
    }
  }

  Future<void> _checkBiometricOnResume() async {
    if (_isCheckingBiometric || _biometricAuthenticated) return;

    final biometricEnabled = await DependencyInjection.biometricService
        .isBiometricEnabled();
    if (!biometricEnabled) return;

    _isCheckingBiometric = true;
    try {
      final (authenticated, _) = await DependencyInjection.biometricService
          .authenticate(
            localizedReason: 'Deverrouillez pour acceder a l\'application',
          );
      if (mounted) {
        setState(() => _biometricAuthenticated = authenticated);
        if (!authenticated) {
          _handleLogout();
        }
      }
    } finally {
      _isCheckingBiometric = false;
    }
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

  /// Gestion du double appui pour quitter
  Future<bool> _handleWillPop() async {
    if (_selectedNavIndex != 0) {
      setState(() => _selectedNavIndex = 0);
      return false;
    }

    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pressAgainToExit),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _handleWillPop();
          if (shouldPop && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Bandeau de synchronisation
            SyncNotificationBanner(
              connectivityState: DependencyInjection.connectivityState,
              syncState: DependencyInjection.syncState,
            ),
            // Contenu principal
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: IndexedStack(
                  index: _selectedNavIndex,
                  children: [
                    SupAdminHomeScreen(
                      key: _homeKey,
                      userName: widget.userName,
                      greeting: _getGreeting(),
                      photoUrl: widget.photoUrl,
                      onNavigateToAcademy: () {
                        setState(() => _selectedNavIndex = 1);
                        _academyKey.currentState?.reload();
                      },
                      onNavigateToSeances: () {
                        setState(() => _selectedNavIndex = 2);
                      },
                      onNavigateToCommunication: () {
                        setState(() => _selectedNavIndex = 3);
                      },
                    ),
                    AcademicienListPage(
                      key: _academyKey,
                      repository: DependencyInjection.academicienRepository,
                    ),
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
        bottomNavigationBar: _buildBottomNav(colorScheme, l10n),
      ),
    );
  }

  /// Retourne le message de salutation selon l'heure.
  String _getGreeting() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return 'Bonjour';

    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
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
