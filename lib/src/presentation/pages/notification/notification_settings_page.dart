import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';

/// Page de reglages des notifications.
/// Permet d'activer/desactiver les differents types de notifications.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsGlobales = true;
  bool _notifSeances = true;
  bool _notifPresences = true;
  bool _notifAnnotations = true;
  bool _notifMessages = true;
  bool _notifRappels = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerPreferences();
  }

  Future<void> _chargerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsGlobales = prefs.getBool('notif_globales') ?? true;
        _notifSeances = prefs.getBool('notif_seances') ?? true;
        _notifPresences = prefs.getBool('notif_presences') ?? true;
        _notifAnnotations = prefs.getBool('notif_annotations') ?? true;
        _notifMessages = prefs.getBool('notif_messages') ?? true;
        _notifRappels = prefs.getBool('notif_rappels') ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _sauvegarderPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _toggleGlobal(bool value) {
    setState(() {
      _notificationsGlobales = value;
      if (!value) {
        _notifSeances = false;
        _notifPresences = false;
        _notifAnnotations = false;
        _notifMessages = false;
        _notifRappels = false;
      } else {
        _notifSeances = true;
        _notifPresences = true;
        _notifAnnotations = true;
        _notifMessages = true;
        _notifRappels = true;
      }
    });
    _sauvegarderPreference('notif_globales', value);
    _sauvegarderPreference('notif_seances', _notifSeances);
    _sauvegarderPreference('notif_presences', _notifPresences);
    _sauvegarderPreference('notif_annotations', _notifAnnotations);
    _sauvegarderPreference('notif_messages', _notifMessages);
    _sauvegarderPreference('notif_rappels', _notifRappels);
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
          l10n.notifications,
          style: GoogleFonts.montserrat(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGlobalToggle(colorScheme, isDark, l10n),
                  const SizedBox(height: 24),
                  _buildSectionLabel(l10n.categories, colorScheme),
                  const SizedBox(height: 12),
                  _buildCategoryCard(colorScheme, isDark, l10n),
                  const SizedBox(height: 24),
                  _buildInfoCard(colorScheme, isDark, l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildGlobalToggle(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _notificationsGlobales
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              )
            : null,
        color: _notificationsGlobales
            ? null
            : (isDark ? colorScheme.surface : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: _notificationsGlobales
            ? null
            : Border.all(color: colorScheme.onSurface.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _notificationsGlobales
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                  : colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _notificationsGlobales
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: _notificationsGlobales
                  ? const Color(0xFFF59E0B)
                  : colorScheme.onSurface.withValues(alpha: 0.4),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notifications,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _notificationsGlobales
                        ? Colors.white
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _notificationsGlobales
                      ? l10n.notificationsEnabled
                      : l10n.notificationsDisabled,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: _notificationsGlobales
                        ? Colors.white.withValues(alpha: 0.5)
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _notificationsGlobales,
            onChanged: _toggleGlobal,
            activeTrackColor: const Color(0xFFF59E0B),
            activeThumbColor: Colors.white,
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

  Widget _buildCategoryCard(
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
          _buildNotifToggle(
            icon: Icons.event_rounded,
            label: l10n.sessions,
            description: l10n.notifSeancesDesc,
            color: const Color(0xFF3B82F6),
            value: _notifSeances,
            onChanged: _notificationsGlobales
                ? (v) {
                    setState(() => _notifSeances = v);
                    _sauvegarderPreference('notif_seances', v);
                  }
                : null,
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildNotifToggle(
            icon: Icons.qr_code_scanner_rounded,
            label: l10n.attendance,
            description: l10n.notifPresencesDesc,
            color: const Color(0xFF10B981),
            value: _notifPresences,
            onChanged: _notificationsGlobales
                ? (v) {
                    setState(() => _notifPresences = v);
                    _sauvegarderPreference('notif_presences', v);
                  }
                : null,
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildNotifToggle(
            icon: Icons.edit_note_rounded,
            label: l10n.annotations,
            description: l10n.notifAnnotationsDesc,
            color: const Color(0xFF8B5CF6),
            value: _notifAnnotations,
            onChanged: _notificationsGlobales
                ? (v) {
                    setState(() => _notifAnnotations = v);
                    _sauvegarderPreference('notif_annotations', v);
                  }
                : null,
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildNotifToggle(
            icon: Icons.message_rounded,
            label: l10n.communication,
            description: l10n.notifMessagesDesc,
            color: const Color(0xFFEC4899),
            value: _notifMessages,
            onChanged: _notificationsGlobales
                ? (v) {
                    setState(() => _notifMessages = v);
                    _sauvegarderPreference('notif_messages', v);
                  }
                : null,
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildNotifToggle(
            icon: Icons.alarm_rounded,
            label: l10n.notifRappels,
            description: l10n.notifRappelsDesc,
            color: const Color(0xFFF59E0B),
            value: _notifRappels,
            onChanged: _notificationsGlobales
                ? (v) {
                    setState(() => _notifRappels = v);
                    _sauvegarderPreference('notif_rappels', v);
                  }
                : null,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifToggle({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required bool value,
    required void Function(bool)? onChanged,
    required ColorScheme colorScheme,
  }) {
    final isEnabled = _notificationsGlobales;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled
                  ? color.withValues(alpha: 0.1)
                  : colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? color
                  : colorScheme.onSurface.withValues(alpha: 0.25),
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
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value && isEnabled,
            onChanged: onChanged,
            activeTrackColor: color,
            activeThumbColor: Colors.white,
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

  Widget _buildInfoCard(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.notifStorageInfo,
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
