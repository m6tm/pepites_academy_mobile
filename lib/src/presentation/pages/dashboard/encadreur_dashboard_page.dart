import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../injection_container.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../widgets/sync_notification_banner.dart';
import '../auth/login_page.dart';
import '../scanner/qr_scanner_page.dart';
import '../../widgets/academy_toast.dart';
import 'screens/encadreur_home_screen.dart';
import 'screens/encadreur_seances_screen.dart';
import 'screens/encadreur_annotations_screen.dart';
import 'screens/encadreur_communication_screen.dart';
import 'screens/encadreur_profile_screen.dart';
import 'widgets/encadreur_internal_widgets.dart';

/// Dashboard principal pour le profil Encadreur (Coach).
/// Optimise pour le travail terrain : seances, ateliers, annotations, scan QR.
class EncadreurDashboardPage extends StatefulWidget {
  final String userName;

  const EncadreurDashboardPage({super.key, this.userName = 'Coach'});

  @override
  State<EncadreurDashboardPage> createState() => _EncadreurDashboardPageState();
}

class _EncadreurDashboardPageState extends State<EncadreurDashboardPage>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
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
                    EncadreurHomeScreen(
                      userName: widget.userName,
                      greeting: _getGreeting(),
                      onSmsTap: () => setState(() => _selectedNavIndex = 4),
                    ),
                    const EncadreurSeancesScreen(),
                    const SizedBox(),
                    const EncadreurAnnotationsScreen(),
                    const EncadreurCommunicationScreen(),
                    EncadreurProfileScreen(
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
      floatingActionButton: _buildScanFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Verifie qu'une seance est ouverte avant de lancer le scanner.
  Future<void> _ouvrirScanner() async {
    final seanceOuverte = await DependencyInjection.seanceRepository
        .getSeanceOuverte();
    if (!mounted) return;

    if (seanceOuverte == null) {
      AcademyToast.show(
        context,
        title: 'Aucune seance en cours',
        description: 'Veuillez ouvrir une seance avant de scanner.',
        icon: Icons.warning_amber_rounded,
        isError: true,
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrScannerPage(seanceId: seanceOuverte.id),
      ),
    );
  }

  /// Bouton flottant central "Scanner QR"
  Widget _buildScanFAB() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: FloatingActionButton(
        onPressed: _ouvrirScanner,
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: const CircleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              'SCAN',
              style: GoogleFonts.montserrat(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
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

  /// Barre de navigation inferieure encadreur
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
              CoachNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Accueil',
                isSelected: _selectedNavIndex == 0,
                onTap: () => setState(() => _selectedNavIndex = 0),
              ),
              CoachNavItem(
                icon: Icons.sports_soccer_rounded,
                label: 'Seances',
                isSelected: _selectedNavIndex == 1,
                onTap: () => setState(() => _selectedNavIndex = 1),
              ),
              const Expanded(child: SizedBox()),
              CoachNavItem(
                icon: Icons.edit_note_rounded,
                label: 'Notes',
                isSelected: _selectedNavIndex == 3,
                onTap: () => setState(() => _selectedNavIndex = 3),
              ),
              CoachNavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isSelected: _selectedNavIndex == 5,
                onTap: () => setState(() => _selectedNavIndex = 5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
