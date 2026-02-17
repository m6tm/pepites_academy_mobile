import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/bulletin.dart';
import '../../../theme/app_colors.dart';

/// Widget de selection de la periode pour le bulletin.
/// Permet de choisir entre mois, trimestre et saison,
/// et de naviguer entre les periodes via un calendrier visuel.
class PeriodeSelectorWidget extends StatelessWidget {
  final PeriodeType typePeriode;
  final DateTime dateReference;
  final ValueChanged<PeriodeType> onTypePeriodeChanged;
  final ValueChanged<DateTime> onDateReferenceChanged;

  const PeriodeSelectorWidget({
    super.key,
    required this.typePeriode,
    required this.dateReference,
    required this.onTypePeriodeChanged,
    required this.onDateReferenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.periodTitle,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 12),
        _buildTypeSelector(isDark, l10n),
        const SizedBox(height: 16),
        _buildNavigateurPeriode(isDark, l10n),
      ],
    );
  }

  Widget _buildTypeSelector(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: PeriodeType.values.map((type) {
          final isSelected = type == typePeriode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTypePeriodeChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  _typeLabel(type, l10n),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigateurPeriode(bool isDark, AppLocalizations l10n) {
    final label = _periodeLabel(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _naviguerPeriode(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.primary,
            iconSize: 28,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _sousLabel(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _peutAvancer() ? () => _naviguerPeriode(1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: _peutAvancer()
                ? AppColors.primary
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  String _typeLabel(PeriodeType type, AppLocalizations l10n) {
    switch (type) {
      case PeriodeType.mois:
        return l10n.periodMonth;
      case PeriodeType.trimestre:
        return l10n.periodQuarter;
      case PeriodeType.saison:
        return l10n.periodSeason;
    }
  }

  String _periodeLabel(AppLocalizations l10n) {
    switch (typePeriode) {
      case PeriodeType.mois:
        return DateFormat('MMMM yyyy', l10n.localeName).format(dateReference);
      case PeriodeType.trimestre:
        final t = ((dateReference.month - 1) ~/ 3) + 1;
        return l10n.quarterLabel(t, dateReference.year);
      case PeriodeType.saison:
        final annee = dateReference.month >= 9
            ? dateReference.year
            : dateReference.year - 1;
        return l10n.seasonLabel(annee, annee + 1);
    }
  }

  String _sousLabel() {
    final dates = _calculerDates();
    return '${_formatDate(dates.$1)} - ${_formatDate(dates.$2)}';
  }

  String _formatDate(DateTime d) {
    return DateFormat('dd/MM/yyyy').format(d);
  }

  (DateTime, DateTime) _calculerDates() {
    switch (typePeriode) {
      case PeriodeType.mois:
        final debut = DateTime(dateReference.year, dateReference.month, 1);
        final fin = DateTime(dateReference.year, dateReference.month + 1, 0);
        return (debut, fin);
      case PeriodeType.trimestre:
        final t = ((dateReference.month - 1) ~/ 3) * 3 + 1;
        final debut = DateTime(dateReference.year, t, 1);
        final fin = DateTime(dateReference.year, t + 3, 0);
        return (debut, fin);
      case PeriodeType.saison:
        final annee = dateReference.month >= 9
            ? dateReference.year
            : dateReference.year - 1;
        return (DateTime(annee, 9, 1), DateTime(annee + 1, 6, 30));
    }
  }

  void _naviguerPeriode(int direction) {
    DateTime newDate;
    switch (typePeriode) {
      case PeriodeType.mois:
        newDate = DateTime(
          dateReference.year,
          dateReference.month + direction,
          1,
        );
        break;
      case PeriodeType.trimestre:
        newDate = DateTime(
          dateReference.year,
          dateReference.month + (3 * direction),
          1,
        );
        break;
      case PeriodeType.saison:
        newDate = DateTime(
          dateReference.year + direction,
          dateReference.month,
          1,
        );
        break;
    }
    onDateReferenceChanged(newDate);
  }

  bool _peutAvancer() {
    final now = DateTime.now();
    switch (typePeriode) {
      case PeriodeType.mois:
        return dateReference.year < now.year ||
            (dateReference.year == now.year && dateReference.month < now.month);
      case PeriodeType.trimestre:
        final tRef = ((dateReference.month - 1) ~/ 3);
        final tNow = ((now.month - 1) ~/ 3);
        return dateReference.year < now.year ||
            (dateReference.year == now.year && tRef < tNow);
      case PeriodeType.saison:
        return dateReference.year < now.year - 1;
    }
  }
}
