import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../state/sms_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glassmorphism_card.dart';
import 'sms_recipient_selection_page.dart';

/// Page de composition d'un SMS.
/// Permet de rediger le message avec compteur de caracteres,
/// puis de passer a la selection des destinataires.
class SmsComposePage extends StatefulWidget {
  final SmsState smsState;

  const SmsComposePage({super.key, required this.smsState});

  @override
  State<SmsComposePage> createState() => _SmsComposePageState();
}

class _SmsComposePageState extends State<SmsComposePage> {
  late final TextEditingController _messageController;
  static const int _maxSmsLength = 160;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text: widget.smsState.contenuMessage,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  int get _charCount => _messageController.text.length;
  int get _smsCount => (_charCount / _maxSmsLength).ceil().clamp(1, 99);
  int get _remainingChars => (_smsCount * _maxSmsLength) - _charCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.smsComposeTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tete
              Text(
                l10n.smsComposeHeader,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.smsComposeSubHeader,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),

              // Zone de saisie du message
              Expanded(
                child: GlassmorphismCard(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: colorScheme.onSurface,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.smsComposeHint,
                            hintStyle: GoogleFonts.montserrat(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            widget.smsState.setContenuMessage(value);
                            setState(() {});
                          },
                        ),
                      ),
                      // Barre de compteur
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildCounterChip(
                              l10n.smsComposeCharCount(_charCount),
                              Icons.text_fields_rounded,
                              colorScheme,
                            ),
                            const SizedBox(width: 12),
                            _buildCounterChip(
                              l10n.smsComposeSmsCount(_smsCount),
                              Icons.sms_rounded,
                              colorScheme,
                              color: _smsCount > 1
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                            const Spacer(),
                            Text(
                              l10n.smsComposeRemainingChars(_remainingChars),
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _remainingChars < 20
                                    ? AppColors.error
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bouton suivant
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _charCount > 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SmsRecipientSelectionPage(
                                smsState: widget.smsState,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.3,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.smsComposeChooseRecipients,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterChip(
    String label,
    IconData icon,
    ColorScheme colorScheme, {
    Color? color,
  }) {
    final chipColor = color ?? const Color(0xFF3B82F6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}
