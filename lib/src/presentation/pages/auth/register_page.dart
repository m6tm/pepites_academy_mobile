import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../injection_container.dart';

/// Page d'inscription pour Pépites Academy.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
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

    setState(() => _passwordStrength = strength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 0.25) return Colors.red;
    if (_passwordStrength <= 0.5) return Colors.orange;
    if (_passwordStrength <= 0.75) return Colors.blue;
    return Colors.green;
  }

  String _getStrengthText(AppLocalizations l10n) {
    if (_passwordStrength <= 0.25) return l10n.passwordStrengthWeak;
    if (_passwordStrength <= 0.5) return l10n.passwordStrengthMedium;
    if (_passwordStrength <= 0.75) return l10n.passwordStrengthStrong;
    return l10n.passwordStrengthExcellent;
  }

  void _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final failure = await DependencyInjection.authService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message ?? l10n.error),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.registrationSuccessTitle),
              backgroundColor: Colors.green,
            ),
          );
          // Redirection vers la page de connexion ou le dashboard
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.createAccount,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.registerSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _lastNameController,
                      label: l10n.lastName,
                      hint: l10n.lastNameHint,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.lastNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _firstNameController,
                      label: l10n.firstName,
                      hint: l10n.firstNameHint,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.firstNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 8),
                    // Indicateur de force du mot de passe
                    if (_passwordController.text.isNotEmpty)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _passwordStrength,
                                    backgroundColor: colorScheme.onSurface
                                        .withValues(alpha: 0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getStrengthColor(),
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStrengthText(l10n),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getStrengthColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                    // Checklist des critères de sécurité
                    if (_passwordController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          children: [
                            _buildRequirementItem(
                              l10n.passwordMinChars,
                              _passwordController.text.length >= 8,
                            ),
                            _buildRequirementItem(
                              l10n.passwordUppercase,
                              _passwordController.text.contains(
                                RegExp(r'[A-Z]'),
                              ),
                            ),
                            _buildRequirementItem(
                              l10n.passwordDigit,
                              _passwordController.text.contains(
                                RegExp(r'[0-9]'),
                              ),
                            ),
                            _buildRequirementItem(
                              l10n.passwordSpecialChar,
                              _passwordController.text.contains(
                                RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: l10n.confirmPassword,
                      hint: '••••••••',
                      prefixIcon: Icons.lock_reset_outlined,
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                                l10n.createMyAccount,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.signIn,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un élément de la checklist des critères de sécurité.
  Widget _buildRequirementItem(String text, bool isMet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            style: theme.textTheme.bodySmall?.copyWith(
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

  /// Construit un champ de texte stylisé conforme à la charte graphique.
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
          onChanged: (_) => setState(
            () {},
          ), // Pour mettre à jour l'UI en temps réel (indicateur)
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
