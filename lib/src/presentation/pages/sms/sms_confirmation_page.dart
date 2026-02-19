import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../../domain/entities/sms_message.dart';
import '../../state/sms_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glassmorphism_card.dart';

/// Page de previsualisation et confirmation avant envoi du SMS.
/// Affiche le recapitulatif : nombre de SMS, liste des destinataires,
/// contenu du message, et demande confirmation.
class SmsConfirmationPage extends StatelessWidget {
  final SmsState smsState;

  const SmsConfirmationPage({super.key, required this.smsState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destinataires = smsState.destinatairesSelectionnes;
    final contenu = smsState.contenuMessage;
    final nbSms = (contenu.length / 160).ceil().clamp(1, 99);
    final totalSmsUnits = nbSms * destinataires.length;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.smsConfirmationTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListenableBuilder(
        listenable: smsState,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    // En-tete
                    Text(
                      l10n.smsConfirmationSummary,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.smsConfirmationCheckInfo,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Statistiques d'envoi
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${destinataires.length}',
                            l10n.smsConfirmationRecipient(destinataires.length),
                            Icons.people_rounded,
                            const Color(0xFF3B82F6),
                            colorScheme,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            '$nbSms',
                            l10n.smsConfirmationSmsPerPerson,
                            Icons.sms_rounded,
                            const Color(0xFF8B5CF6),
                            colorScheme,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            '$totalSmsUnits',
                            l10n.smsConfirmationTotalSms,
                            Icons.send_rounded,
                            AppColors.primary,
                            colorScheme,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Contenu du message
                    _buildSectionTitle(
                      l10n.smsConfirmationMessage,
                      Icons.message_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    GlassmorphismCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contenu,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.smsConfirmationMessageInfo(
                                contenu.length,
                                nbSms,
                              ),
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Liste des destinataires
                    _buildSectionTitle(
                      l10n.smsConfirmationRecipientsCount(destinataires.length),
                      Icons.people_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    ...destinataires.map(
                      (d) => _buildDestinataireTile(d, colorScheme, isDark),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Barre d'envoi
              _buildSendBar(context, l10n, colorScheme, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinataireTile(
    Destinataire destinataire,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isAcademicien = destinataire.type == TypeDestinataire.academicien;
    final color = isAcademicien
        ? const Color(0xFF3B82F6)
        : const Color(0xFF8B5CF6);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
              isAcademicien ? Icons.school_rounded : Icons.sports_rounded,
              size: 12,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              destinataire.nom,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            destinataire.telephone,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendBar(
    BuildContext context,
    AppLocalizations l,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: smsState.isLoading
                ? null
                : () => _confirmerEnvoi(context, l),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: smsState.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        l.smsConfirmationSendSms,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _confirmerEnvoi(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final count = smsState.destinatairesSelectionnes.length;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l.smsConfirmationConfirmSend,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Text(
            l.smsConfirmationDialogBody(count),
            style: GoogleFonts.montserrat(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                l.smsConfirmationCancel,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await smsState.envoyerSms();
                if (success && context.mounted) {
                  _afficherSucces(context, l);
                } else if (context.mounted) {
                  _afficherErreur(context, l);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l.smsConfirmationConfirm,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _afficherSucces(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.smsConfirmationSuccessTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                smsState.successMessage ?? l.smsConfirmationSuccessBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Retourner au dashboard (pop toutes les pages SMS)
                  Navigator.of(context).popUntil(
                    (route) => route.isFirst || !Navigator.of(context).canPop(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l.smsConfirmationBack,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _afficherErreur(BuildContext context, AppLocalizations l) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          smsState.errorMessage ?? l.smsConfirmationError,
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
