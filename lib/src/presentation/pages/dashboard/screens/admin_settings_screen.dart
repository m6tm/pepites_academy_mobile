import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../notification/notification_settings_page.dart';
import '../../referentiel/referentiel_hub_page.dart';
import '../../settings/about_page.dart';
import '../../settings/theme_settings_page.dart';
import '../../settings/language_settings_page.dart';
import '../../../../injection_container.dart';
import '../widgets/admin_internal_widgets.dart';

/// Ecran Parametres du dashboard administrateur.
/// Configuration de l'application, profil et deconnexion.
class AdminSettingsScreen extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const AdminSettingsScreen({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  l10n.settings,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.settingsSubtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildProfileCard(context, colorScheme, l10n),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: _buildSettingsSection(
            l10n.general,
            [
              SettingsItemData(
                Icons.language_rounded,
                l10n.language,
                DependencyInjection.languageState.label,
                const Color(0xFF3B82F6),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageSettingsPage(
                      languageState: DependencyInjection.languageState,
                    ),
                  ),
                ),
              ),
              SettingsItemData(
                Icons.dark_mode_rounded,
                l10n.theme,
                DependencyInjection.themeState.label,
                const Color(0xFF8B5CF6),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ThemeSettingsPage(
                      themeState: DependencyInjection.themeState,
                    ),
                  ),
                ),
              ),
              SettingsItemData(
                Icons.notifications_outlined,
                l10n.notifications,
                l10n.notificationsEnabled,
                const Color(0xFFF59E0B),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage(),
                  ),
                ),
              ),
            ],
            context,
            colorScheme,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: _buildSettingsSection(
            l10n.administration,
            [
              SettingsItemData(
                Icons.tune_rounded,
                l10n.referentials,
                l10n.referentialsSubtitle,
                const Color(0xFF10B981),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReferentielHubPage()),
                ),
              ),
              SettingsItemData(
                Icons.info_outline_rounded,
                l10n.about,
                l10n.version('1.5.0'),
                colorScheme.onSurface.withValues(alpha: 0.5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
            ],
            context,
            colorScheme,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF2D1215)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Center(
              child: Text(
                userName[0].toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'admin@pepites.com',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.administrator.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    List<SettingsItemData> items,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == items.length - 1;
                return Column(
                  children: [
                    ListTile(
                      onTap: item.onTap,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      title: Text(
                        item.label,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        item.value,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 60,
                        color: colorScheme.onSurface.withValues(alpha: 0.05),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
