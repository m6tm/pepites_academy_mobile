import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// Page A propos de l'application Pepites Academy.
/// Affiche les informations de version, l'equipe et les mentions legales.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
          'A propos',
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
          children: [
            const SizedBox(height: 16),
            _buildAppHeader(colorScheme),
            const SizedBox(height: 32),
            _buildInfoSection(colorScheme, isDark),
            const SizedBox(height: 16),
            _buildTeamSection(colorScheme, isDark),
            const SizedBox(height: 16),
            _buildLegalSection(colorScheme, isDark),
            const SizedBox(height: 32),
            _buildFooter(colorScheme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        Image.asset('assets/logo.png', width: 110, height: 110),
        const SizedBox(height: 20),
        Text(
          'Pepites Academy',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Version 1.3.0',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Plateforme de gestion et de suivi\ndes academiciens de football',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.update_rounded,
            label: 'Version',
            value: '1.3.0',
            color: const Color(0xFF3B82F6),
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildInfoRow(
            icon: Icons.phone_android_rounded,
            label: 'Plateforme',
            value: 'Flutter / Dart',
            color: const Color(0xFF10B981),
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Derniere mise a jour',
            value: 'Fevrier 2026',
            color: const Color(0xFFF59E0B),
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildInfoRow(
            icon: Icons.storage_rounded,
            label: 'Stockage',
            value: 'Local (hors-ligne)',
            color: const Color(0xFF8B5CF6),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'EQUIPE',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Developpe par',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'I-Tech Solutions',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                height: 1,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sports_soccer_rounded,
                      color: Color(0xFF3B82F6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Concu pour',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pepites Academy',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'INFORMATIONS LEGALES',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pepites Academy - Tous droits reserves.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cette application est destinee a un usage interne pour la gestion '
                'des academiciens, des seances d\'entrainement, des ateliers et du '
                'suivi de performance au sein de l\'academie de football Pepites Academy.',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Les donnees sont stockees localement sur l\'appareil. '
                'Aucune information personnelle n\'est transmise a des tiers.',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
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
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      indent: 60,
      color: colorScheme.onSurface.withValues(alpha: 0.05),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Fait avec passion pour le football',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
