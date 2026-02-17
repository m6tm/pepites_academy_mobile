import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../state/theme_state.dart';

/// Page de selection du theme de l'application.
/// Permet de choisir entre Clair, Sombre et Systeme.
class ThemeSettingsPage extends StatefulWidget {
  final ThemeState themeState;

  const ThemeSettingsPage({super.key, required this.themeState});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  @override
  void initState() {
    super.initState();
    widget.themeState.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.themeState.removeListener(_onChanged);
    super.dispose();
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
          l10n.theme,
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
            _buildPreview(colorScheme, isDark, l10n),
            const SizedBox(height: 28),
            _buildSectionLabel(l10n.appearance, colorScheme),
            const SizedBox(height: 12),
            _buildThemeOptions(colorScheme, isDark, l10n),
            const SizedBox(height: 24),
            _buildInfoCard(colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 48,
            color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 14),
          Text(
            isDark ? l10n.darkMode : l10n.lightMode,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.themeActiveLabel(widget.themeState.label),
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.35),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildThemeOptions(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            icon: Icons.light_mode_rounded,
            label: l10n.lightMode,
            description: l10n.lightModeDesc,
            color: const Color(0xFFF59E0B),
            mode: ThemeMode.light,
            colorScheme: colorScheme,
          ),
          Divider(
            height: 1,
            indent: 60,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          _buildThemeOption(
            icon: Icons.dark_mode_rounded,
            label: l10n.darkMode,
            description: l10n.darkModeDesc,
            color: const Color(0xFF8B5CF6),
            mode: ThemeMode.dark,
            colorScheme: colorScheme,
          ),
          Divider(
            height: 1,
            indent: 60,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          _buildThemeOption(
            icon: Icons.settings_brightness_rounded,
            label: l10n.systemMode,
            description: l10n.systemModeDesc,
            color: const Color(0xFF3B82F6),
            mode: ThemeMode.system,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required ThemeMode mode,
    required ColorScheme colorScheme,
  }) {
    final isSelected = widget.themeState.themeMode == mode;

    return InkWell(
      onTap: () => widget.themeState.setThemeMode(mode),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? color
                    : colorScheme.onSurface.withValues(alpha: 0.35),
                size: 20,
              ),
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
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
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
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.themeInfo,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
