import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../notification/notification_settings_page.dart';
import '../../referentiel/referentiel_hub_page.dart';
import '../../settings/about_page.dart';
import '../../settings/theme_settings_page.dart';
import '../../settings/language_settings_page.dart';
import '../../settings/security_settings_page.dart';
import '../../../../injection_container.dart';
import '../widgets/encadreur_internal_widgets.dart';

/// Ecran Profil du dashboard encadreur.
/// Informations personnelles, statistiques et parametres.
class EncadreurProfileScreen extends StatelessWidget {
  final String userName;
  final String? fullName;
  final String? photoUrl;
  final VoidCallback onLogout;

  const EncadreurProfileScreen({
    super.key,
    required this.userName,
    this.fullName,
    this.photoUrl,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myProfile,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _buildProfileImage(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  fullName ?? userName,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'coach@pepites.com',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.roleWithSpeciality(
                      l10n.coach.toUpperCase(),
                      l10n.specialityTechnique,
                    ),
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: _buildCoachSettings(context, colorScheme, isDark, l10n),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                l10n.logout,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildCoachSettings(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            SettingsTile(
              icon: Icons.language_rounded,
              label: l10n.language,
              value: DependencyInjection.languageState.label,
              color: const Color(0xFF3B82F6),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LanguageSettingsPage(
                    languageState: DependencyInjection.languageState,
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              indent: 60,
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            SettingsTile(
              icon: Icons.dark_mode_rounded,
              label: l10n.theme,
              value: DependencyInjection.themeState.label,
              color: const Color(0xFF8B5CF6),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ThemeSettingsPage(
                    themeState: DependencyInjection.themeState,
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              indent: 60,
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              label: l10n.notifications,
              value: l10n.notificationsEnabled,
              color: const Color(0xFFF59E0B),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              ),
            ),
            Divider(
              height: 1,
              indent: 60,
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            SettingsTile(
              icon: Icons.shield_rounded,
              label: l10n.security,
              value: l10n.securitySubtitle,
              color: const Color(0xFFDC2626),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecuritySettingsPage()),
              ),
            ),
            Divider(
              height: 1,
              indent: 60,
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            SettingsTile(
              icon: Icons.tune_rounded,
              label: l10n.referentials,
              value: l10n.referentialsSubtitle,
              color: const Color(0xFF10B981),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReferentielHubPage()),
              ),
            ),
            Divider(
              height: 1,
              indent: 60,
              color: colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            SettingsTile(
              icon: Icons.info_outline_rounded,
              label: l10n.about,
              value: l10n.version('1.12.0'),
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      final isLocal = !photoUrl!.startsWith('http');
      if (isLocal && File(photoUrl!).existsSync()) {
        return Image.file(
          File(photoUrl!),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      } else if (!isLocal) {
        return Image.network(
          photoUrl!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.transparent,
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'C',
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
