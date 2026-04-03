import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../injection_container.dart';
import '../../widgets/sync_notification_banner.dart';
import '../auth/login_page.dart';
import 'screens/medecin_home_screen.dart';
import 'screens/medecin_academy_screen.dart';
import 'screens/medecin_consultations_screen.dart';
import 'screens/medecin_profile_screen.dart';
import 'widgets/medecin_internal_widgets.dart';

/// Dashboard principal pour le profil Médecin Chef.
/// Gère le suivi sanitaire, les dossiers médicaux et les consultations.
class MedecinDashboardPage extends StatefulWidget {
  final String userName;
  final String? photoUrl;

  const MedecinDashboardPage({
    super.key,
    this.userName = 'Docteur',
    this.photoUrl,
  });

  @override
  State<MedecinDashboardPage> createState() => _MedecinDashboardPageState();
}

class _MedecinDashboardPageState extends State<MedecinDashboardPage>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _fullName;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
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
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  Future<bool> _handleBackPress() async {
    if (_selectedNavIndex != 0) {
      setState(() => _selectedNavIndex = 0);
      return false;
    }

    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.logoutConfirmation),
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
        if (shouldPop && mounted) {
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
                      MedecinHomeScreen(
                        userName: widget.userName,
                        greeting: _getGreeting(),
                        photoUrl: widget.photoUrl,
                        onProfileTap: () => setState(() => _selectedNavIndex = 3),
                      ),
                      const MedecinAcademyScreen(),
                      const MedecinConsultationsScreen(),
                      MedecinProfileScreen(
                        userName: widget.userName,
                        fullName: _fullName,
                        onLogout: _handleLogout,
                        photoUrl: widget.photoUrl,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(colorScheme),
      ),
    );
  }

  Widget _buildBottomNav(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;

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
              MedecinNavItem(
                icon: Icons.dashboard_rounded,
                label: l10n.home,
                isSelected: _selectedNavIndex == 0,
                onTap: () => setState(() => _selectedNavIndex = 0),
              ),
              MedecinNavItem(
                icon: Icons.folder_shared_rounded,
                label: l10n.medicalFiles,
                isSelected: _selectedNavIndex == 1,
                onTap: () => setState(() => _selectedNavIndex = 1),
              ),
              MedecinNavItem(
                icon: Icons.medical_services_rounded,
                label: l10n.consultations,
                isSelected: _selectedNavIndex == 2,
                onTap: () => setState(() => _selectedNavIndex = 2),
              ),
              MedecinNavItem(
                icon: Icons.person_rounded,
                label: l10n.profile,
                isSelected: _selectedNavIndex == 3,
                onTap: () => setState(() => _selectedNavIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await DependencyInjection.authService.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(l10n.logoutButton, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
