import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../injection_container.dart';
import '../../../application/services/biometric_service.dart';
import '../../../application/services/device_info_service.dart';
import '../../../application/services/role_service.dart';
import '../../../domain/entities/role.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/academy_toast.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../dashboard/encadreur_dashboard_page.dart';
import '../../theme/app_colors.dart';

/// Page de connexion pour Pépites Academy.
/// Design premium, minimaliste et high-end pour le secteur sportif.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final l10n = AppLocalizations.of(context)!;

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Recuperer les infos de l'appareil
      final deviceInfoService = DeviceInfoService();
      final deviceInfo = await deviceInfoService.getDeviceInfo();

      final failure = await DependencyInjection.authService.login(
        email: email,
        password: password,
        deviceType: deviceInfo.deviceType,
        deviceName: deviceInfo.deviceName,
        model: deviceInfo.model,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (failure == null) {
        // Succès - synchroniser les referentiels et académiciens depuis le backend
        await DependencyInjection.syncReferentiels();
        await DependencyInjection.syncAcademiciens();

        // Envoyer le token FCM au serveur maintenant que la session est active
        await DependencyInjection.firebasePushNotificationService
            .sendTokenToServer();

        // Synchroniser les opérations en attente (présences, etc.)
        DependencyInjection.syncState.syncNow();

        // Récupérer le rôle via le RoleService (avec cache local pour hors-ligne)
        final role = await DependencyInjection.roleService.getCurrentUserRole();
        final userName =
            await DependencyInjection.preferences.getUserName() ?? email;
        final photoUrl = await DependencyInjection.preferences.getUserPhoto();

        if (!mounted) return;

        AcademyToast.show(
          context,
          title: l10n.welcomeBack,
          description: l10n.connectedAs(role.displayName),
          isSuccess: true,
        );

        // Proposer l'activation biométrique si disponible
        final shouldNavigate = await _proposeBiometricActivation();

        if (!mounted) return;

        // Navigation vers le dashboard selon le rôle
        if (shouldNavigate) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _navigateToDashboard(role, userName, photoUrl);
          }
        }
      } else {
        // Erreur
        AcademyToast.show(
          context,
          title: l10n.loginFailed,
          description: failure.message ?? l10n.loginFailedDescription,
          isError: true,
        );
      }
    }
  }

  /// Propose l'activation de l'authentification biometrique apres une connexion reussie.
  /// Retourne true si la navigation vers le dashboard doit continuer.
  Future<bool> _proposeBiometricActivation() async {
    // Verifier si la biometrie est disponible sur l'appareil
    final availability = await DependencyInjection.biometricService
        .checkAvailability();

    if (availability != BiometricAvailability.available) {
      // Biometrie non disponible, continuer normalement
      return true;
    }

    // Verifier si la biometrie est deja activee
    final alreadyEnabled = await DependencyInjection.biometricService
        .isBiometricEnabled();

    if (alreadyEnabled) {
      // Deja activee, continuer normalement
      return true;
    }

    // Proposer l'activation via un dialogue
    if (!mounted) return true;

    final typeName = await DependencyInjection.biometricService
        .getPrimaryBiometricTypeName();

    if (!mounted) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Activer la biomitrie',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voulez-vous activer la connexion par $typeName ?',
              style: GoogleFonts.montserrat(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Cela vous permettra de vous connecter rapidement et securisement '
              'sans saisir vos identifiants.',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Non, merci',
              style: GoogleFonts.montserrat(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Activer',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return true;

    if (result == true) {
      // L'utilisateur accepte - activer la biometrie
      final (success, error) = await DependencyInjection.biometricService
          .enableBiometric();

      if (success) {
        if (mounted) {
          AcademyToast.show(
            context,
            title: 'Biomitrie activee',
            description:
                'Vous pouvez maintenant vous connecter avec votre $typeName',
            isSuccess: true,
          );
        }
      } else {
        if (mounted) {
          AcademyToast.show(
            context,
            title: 'Erreur',
            description: error ?? 'Impossible d\'activer la biomitrie',
            isError: true,
          );
        }
      }
    } else {
      // L'utilisateur refuse - desactiver et synchroniser avec le backend
      await DependencyInjection.biometricService.disableBiometric();
    }

    return true;
  }

  /// Navigation vers le dashboard approprié selon le rôle de l'utilisateur.
  void _navigateToDashboard(Role role, String userName, String? photoUrl) {
    final dashboardType = DependencyInjection.roleService.getDashboardForRole(
      role,
    );

    Widget dashboardPage;
    switch (dashboardType) {
      case DashboardType.admin:
        // Les rôles admin (supAdmin, admin) vont vers le dashboard admin
        dashboardPage = AdminDashboardPage(
          userName: userName,
          photoUrl: photoUrl,
        );
        break;
      case DashboardType.encadreur:
        // Les rôles encadreur (encadreurChef, encadreur) vont vers le dashboard encadreur
        dashboardPage = EncadreurDashboardPage(
          userName: userName,
          photoUrl: photoUrl,
        );
        break;
      case DashboardType.medecin:
        // Le rôle medecinChef utilise le dashboard encadreur pour l'instant
        // TODO: Créer un dashboard spécifique pour les médecins
        dashboardPage = EncadreurDashboardPage(
          userName: userName,
          photoUrl: photoUrl,
        );
        break;
      case DashboardType.surveillant:
        // Le rôle surveillantGeneral utilise le dashboard encadreur pour l'instant
        // TODO: Créer un dashboard spécifique pour les surveillants
        dashboardPage = EncadreurDashboardPage(
          userName: userName,
          photoUrl: photoUrl,
        );
        break;
      case DashboardType.visiteur:
        // Le rôle visiteur a un accès limité, utilise le dashboard encadreur en lecture seule
        dashboardPage = EncadreurDashboardPage(
          userName: userName,
          photoUrl: photoUrl,
        );
        break;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => dashboardPage));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Logo de l'application
                Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PÉPITES',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'ACADEMY',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 4,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Titre et Sous-titre
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.login,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        label: l10n.email,
                        hint: l10n.emailHint,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.emailRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.passwordRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Mot de passe oublié
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            l10n.forgotPassword,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Bouton de connexion
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: colorScheme.primary.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.signIn,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Créer un compte
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.noAccount,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              l10n.createAccount,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit un champ de texte stylisé avec les couleurs du thème.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(prefixIcon, color: colorScheme.primary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
