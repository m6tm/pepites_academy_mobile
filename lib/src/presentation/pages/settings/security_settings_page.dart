import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../../injection_container.dart';
import '../../../application/services/biometric_service.dart';
import '../../../application/services/security_service.dart';

/// Page de parametres de securite.
/// Permet de gerer le mot de passe, l'authentification biometrique
/// et les sessions actives.
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _biometricEnabled = false;
  bool _isLoading = false;
  bool _biometricAvailable = false;
  String _biometricTypeName = 'biometrie';
  List<PasswordHistoryEntry> _passwordHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final availability = await DependencyInjection.biometricService
        .checkAvailability();
    final isEnabled = await DependencyInjection.biometricService
        .isBiometricEnabled();
    final typeName = await DependencyInjection.biometricService
        .getPrimaryBiometricTypeName();

    if (mounted) {
      setState(() {
        _biometricAvailable = availability == BiometricAvailability.available;
        _biometricEnabled = isEnabled;
        _biometricTypeName = typeName;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_biometricAvailable) {
      _showBiometricUnavailableDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (value) {
        final (success, error) = await DependencyInjection.biometricService
            .enableBiometric();
        if (mounted) {
          if (success) {
            setState(() {
              _biometricEnabled = true;
            });
            _showSuccessSnackBar('Authentification biometrique activee');
          } else {
            _showErrorSnackBar(error ?? 'Erreur lors de l\'activation');
          }
        }
      } else {
        final (success, error) = await DependencyInjection.biometricService
            .disableBiometric();
        if (mounted) {
          if (success) {
            setState(() {
              _biometricEnabled = false;
            });
            _showSuccessSnackBar('Authentification biometrique desactivee');
          } else {
            _showErrorSnackBar(error ?? 'Erreur lors de la desactivation');
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showBiometricUnavailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Biomitrie non disponible',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Votre appareil ne supporte pas l\'authentification biometrique '
          'ou aucune biomitrie n\'est configuree. Veuillez verifier '
          'les paramitres de votre appareil.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.security,
          style: GoogleFonts.montserrat(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(colorScheme, isDark, l10n),
            const SizedBox(height: 28),
            _buildSectionLabel(l10n.authentication, colorScheme),
            const SizedBox(height: 12),
            _buildBiometricTile(colorScheme, l10n),
            const SizedBox(height: 24),
            _buildSectionLabel(l10n.passwordManagement, colorScheme),
            const SizedBox(height: 12),
            _buildPasswordSection(colorScheme, l10n),
            const SizedBox(height: 24),
            _buildSectionLabel(l10n.activeSessions, colorScheme),
            const SizedBox(height: 12),
            _buildSessionsSection(colorScheme, l10n),
            const SizedBox(height: 24),
            _buildSecurityTipsCard(colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFDC2626), const Color(0xFF991B1B)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shield_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.securityTitle,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.securitySubtitle,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.35),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildBiometricTile(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.biometricAuth,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _biometricAvailable
                        ? 'Utiliser $_biometricTypeName pour vous connecter'
                        : 'Non disponible sur cet appareil',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(
                        alpha: _biometricAvailable ? 0.4 : 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_biometricAvailable)
              Switch(
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
                activeThumbColor: const Color(0xFF10B981),
              )
            else
              Icon(
                Icons.info_outline_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            icon: Icons.password_rounded,
            label: l10n.changePassword,
            description: l10n.changePasswordDesc,
            color: const Color(0xFF8B5CF6),
            onTap: () => _showChangePasswordDialog(colorScheme, l10n),
            colorScheme: colorScheme,
          ),
          Divider(
            height: 1,
            indent: 60,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          _buildNavigationTile(
            icon: Icons.history_rounded,
            label: l10n.passwordHistory,
            description: l10n.passwordHistoryDesc,
            color: const Color(0xFFF59E0B),
            onTap: () => _showPasswordHistorySheet(colorScheme, l10n),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsSection(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _buildSessionTile(
            icon: Icons.phone_android_rounded,
            label: l10n.thisDevice,
            description: l10n.currentSessionActive,
            color: const Color(0xFF10B981),
            isActive: true,
            colorScheme: colorScheme,
          ),
          Divider(
            height: 1,
            indent: 60,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          _buildNavigationTile(
            icon: Icons.devices_rounded,
            label: l10n.connectedDevices,
            description: l10n.connectedDevicesDesc,
            color: const Color(0xFF3B82F6),
            onTap: () => _showConnectedDevicesSheet(colorScheme, l10n),
            colorScheme: colorScheme,
          ),
          Divider(
            height: 1,
            indent: 60,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          _buildNavigationTile(
            icon: Icons.logout_rounded,
            label: l10n.signOutAllDevices,
            description: l10n.signOutAllDevicesDesc,
            color: AppColors.error,
            onTap: () => _showSignOutAllDialog(colorScheme, l10n),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required bool isActive,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ACTIF',
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTipsCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: const Color(0xFF10B981).withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.securityTips,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(l10n.securityTip1, colorScheme),
          const SizedBox(height: 8),
          _buildTipItem(l10n.securityTip2, colorScheme),
          const SizedBox(height: 8),
          _buildTipItem(l10n.securityTip3, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isPasswordVisible = false;
    bool isNewPasswordVisible = false;
    double passwordStrength = 0;

    void updatePasswordStrength(String password) {
      double strength = 0;
      if (password.isEmpty) {
        strength = 0;
      } else {
        if (password.length >= 8) strength += 0.25;
        if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
        if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
        if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
          strength += 0.25;
        }
      }
      passwordStrength = strength;
    }

    Color getStrengthColor() {
      if (passwordStrength <= 0.25) return Colors.red;
      if (passwordStrength <= 0.5) return Colors.orange;
      if (passwordStrength <= 0.75) return Colors.blue;
      return Colors.green;
    }

    String getStrengthText() {
      if (passwordStrength <= 0.25) return l10n.passwordStrengthWeak;
      if (passwordStrength <= 0.5) return l10n.passwordStrengthMedium;
      if (passwordStrength <= 0.75) return l10n.passwordStrengthStrong;
      return l10n.passwordStrengthExcellent;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.changePassword,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                      ),
                      onPressed: () {
                        setDialogState(
                          () => isPasswordVisible = !isPasswordVisible,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: !isNewPasswordVisible,
                  onChanged: (value) {
                    setDialogState(() {
                      updatePasswordStrength(value);
                    });
                  },
                  decoration: InputDecoration(
                    labelText: l10n.newPasswordLabel,
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isNewPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                      ),
                      onPressed: () {
                        setDialogState(
                          () => isNewPasswordVisible = !isNewPasswordVisible,
                        );
                      },
                    ),
                  ),
                ),
                // Indicateur de force du mot de passe
                if (newPasswordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: passwordStrength,
                            backgroundColor: colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              getStrengthColor(),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getStrengthText(),
                        style: GoogleFonts.montserrat(
                          color: getStrengthColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Checklist des criteres de securite
                  _buildPasswordRequirement(
                    l10n.passwordMinChars,
                    newPasswordController.text.length >= 8,
                    colorScheme,
                  ),
                  _buildPasswordRequirement(
                    l10n.passwordUppercase,
                    newPasswordController.text.contains(RegExp(r'[A-Z]')),
                    colorScheme,
                  ),
                  _buildPasswordRequirement(
                    l10n.passwordDigit,
                    newPasswordController.text.contains(RegExp(r'[0-9]')),
                    colorScheme,
                  ),
                  _buildPasswordRequirement(
                    l10n.passwordSpecialChar,
                    newPasswordController.text.contains(
                      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                    ),
                    colorScheme,
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      // Validation des champs
                      if (currentPasswordController.text.isEmpty ||
                          newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        _showErrorSnackBar('Veuillez remplir tous les champs');
                        return;
                      }

                      if (passwordStrength < 0.75) {
                        _showErrorSnackBar(
                          'Le mot de passe doit repondre aux criteres minimaux',
                        );
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        _showErrorSnackBar(
                          'Les mots de passe ne correspondent pas',
                        );
                        return;
                      }

                      Navigator.pop(context);
                      setState(() => _isLoading = true);

                      final (success, error) = await DependencyInjection
                          .securityService
                          .changePassword(
                            oldPassword: currentPasswordController.text,
                            newPassword: newPasswordController.text,
                          );

                      if (mounted) {
                        setState(() => _isLoading = false);
                        if (success) {
                          _showSuccessSnackBar(l10n.passwordChangedSuccess);
                        } else {
                          _showErrorSnackBar(
                            error ?? 'Erreur lors du changement',
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(
    String text,
    bool isMet,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14,
            color: isMet
                ? Colors.green
                : colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.montserrat(
              color: isMet
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordHistorySheet(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) async {
    final history = await DependencyInjection.securityService
        .getPasswordHistory();

    if (mounted) {
      setState(() {
        _passwordHistory = history;
      });
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.passwordHistory,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_passwordHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Aucun historique disponible',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              ..._passwordHistory.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHistoryItem(
                    entry.action,
                    _formatDate(entry.date),
                    entry.action.toLowerCase().contains('creation')
                        ? Icons.info_rounded
                        : Icons.check_circle_rounded,
                    entry.action.toLowerCase().contains('creation')
                        ? const Color(0xFF3B82F6)
                        : AppColors.success,
                    colorScheme,
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Janvier',
      'Fevrier',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Aout',
      'Septembre',
      'Octobre',
      'Novembre',
      'Decembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildHistoryItem(
    String title,
    String date,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectedDevicesSheet(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.connectedDevices,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDeviceItem(
              Icons.phone_android_rounded,
              l10n.thisDevice,
              'Dakar, Senegal',
              true,
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildDeviceItem(
              Icons.tablet_rounded,
              'Tablette Android',
              'Dakar, Senegal',
              false,
              colorScheme,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(
    IconData icon,
    String name,
    String location,
    bool isCurrent,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.success.withValues(alpha: 0.06)
            : colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? AppColors.success.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isCurrent
                ? AppColors.success
                : colorScheme.onSurface.withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ACTIF',
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  location,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            TextButton(
              onPressed: () {},
              child: Text(
                'Deconnecter',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSignOutAllDialog(ColorScheme colorScheme, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.signOutAllDevices,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.signOutAllConfirmation,
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.allDevicesSignedOut),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
