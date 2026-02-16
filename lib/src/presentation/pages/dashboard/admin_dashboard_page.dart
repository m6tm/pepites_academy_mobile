import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  const AdminDashboardPage({super.key, this.userName = 'Administrateur'});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  final _academyKey = GlobalKey<AcademicienListPageState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon apres-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                      onLogout: _handleLogout,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(colorScheme),
    );
  }

  /// Gestion de la deconnexion avec confirmation
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Deconnexion',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Etes-vous sur de vouloir vous deconnecter ?',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop();
                await DependencyInjection.preferences.logout();
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
                'Deconnecter',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Barre de navigation inferieure
  Widget _buildBottomNav(ColorScheme colorScheme) {
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
                label: 'Accueil',
                isSelected: _selectedNavIndex == 0,
                onTap: () => setState(() => _selectedNavIndex = 0),
              ),
              AdminNavItem(
                icon: Icons.school_rounded,
                label: 'Academie',
                isSelected: _selectedNavIndex == 1,
                onTap: () {
                  setState(() => _selectedNavIndex = 1);
                  _academyKey.currentState?.reload();
                },
              ),
              AdminNavItem(
                icon: Icons.sports_soccer_rounded,
                label: 'Seances',
                isSelected: _selectedNavIndex == 2,
                onTap: () => setState(() => _selectedNavIndex = 2),
              ),
              AdminNavItem(
                icon: Icons.sms_rounded,
                label: 'SMS',
                isSelected: _selectedNavIndex == 3,
                onTap: () => setState(() => _selectedNavIndex = 3),
              ),
              AdminNavItem(
                icon: Icons.settings_rounded,
                label: 'Reglages',
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
