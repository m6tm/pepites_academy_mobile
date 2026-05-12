import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class AnnotationActionBar extends StatelessWidget {
  final bool tousNotes;
  final bool isSaving;
  final bool isApplique;
  final bool showRecapitulatif;
  final String? errorMessage;
  final VoidCallback onEnregistrer;
  final VoidCallback onAfficherRecap;
  final VoidCallback onModifier;
  final bool isDark;

  const AnnotationActionBar({
    super.key,
    required this.tousNotes,
    required this.isSaving,
    required this.isApplique,
    required this.showRecapitulatif,
    this.errorMessage,
    required this.onEnregistrer,
    required this.onAfficherRecap,
    required this.onModifier,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorMessage != null) _buildErrorMessage(),
          if (!isApplique) _buildAppliqueWarning(),
          if (!tousNotes && !showRecapitulatif && isApplique)
            _buildNotesWarning(),
          Row(
            children: [
              if (showRecapitulatif)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onModifier,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Modifier',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              if (showRecapitulatif) const SizedBox(width: 12),
              Expanded(
                flex: showRecapitulatif ? 2 : 1,
                child: ElevatedButton.icon(
                  onPressed: tousNotes && !isSaving && isApplique
                      ? (showRecapitulatif ? onEnregistrer : onAfficherRecap)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.3),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          showRecapitulatif
                              ? Icons.save_rounded
                              : Icons.preview_rounded,
                          size: 20,
                        ),
                  label: Text(
                    isSaving
                        ? 'Enregistrement...'
                        : showRecapitulatif
                            ? 'Confirmer'
                            : 'Recapitulatif',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        errorMessage!,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildAppliqueWarning() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Veuillez appliquer cet element pour commencer les annotations.',
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: AppColors.warning,
        ),
      ),
    );
  }

  Widget _buildNotesWarning() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Veuillez noter tous les elements avant de continuer.',
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: AppColors.warning,
        ),
      ),
    );
  }
}

class AnnotationScoreHeader extends StatelessWidget {
  final double scoreTotal;
  final String scoreMax;
  final bool isDark;

  const AnnotationScoreHeader({
    super.key,
    required this.scoreTotal,
    this.scoreMax = '50',
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Score total',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          Text(
            '${scoreTotal.toStringAsFixed(1)} / $scoreMax',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class AnnotationHistoriqueSection extends StatelessWidget {
  final List<dynamic> historique;
  final bool isDark;
  final int maxItems;
  final Widget Function(dynamic annotation) itemBuilder;

  const AnnotationHistoriqueSection({
    super.key,
    required this.historique,
    required this.isDark,
    this.maxItems = 3,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 18,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
            const SizedBox(width: 8),
            Text(
              historique.isEmpty
                  ? 'Aucune annotation precedente'
                  : '${historique.length} annotation(s) precedente(s)',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (historique.isEmpty)
          _buildEmptyState()
        else
          ...historique.take(maxItems).map((a) => itemBuilder(a)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Premiere annotation pour cet academicien',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }
}