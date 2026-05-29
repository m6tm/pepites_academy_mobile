import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/atelier.dart';
import '../../domain/entities/critere_evaluation.dart';
import '../theme/app_colors.dart';

/// Widget permettant a l'encadreur de selectionner N elements (min 1)
/// par critere d'evaluation lors de la configuration d'un atelier.
class EvaluationConfigurationSelector extends StatefulWidget {
  final List<CritereEvaluation> criteres;
  final List<ConfigurationElementEvaluation>? configurationInitiale;
  final ValueChanged<List<ConfigurationElementEvaluation>> onConfigurationChanged;

  const EvaluationConfigurationSelector({
    super.key,
    required this.criteres,
    this.configurationInitiale,
    required this.onConfigurationChanged,
  });

  @override
  State<EvaluationConfigurationSelector> createState() =>
      _EvaluationConfigurationSelectorState();
}

class _EvaluationConfigurationSelectorState
    extends State<EvaluationConfigurationSelector> {
  // Map critereId -> Set d'elementIds selectionnes
  final Map<String, Set<String>> _selections = {};

  @override
  void initState() {
    super.initState();
    _initFromConfiguration();
  }

  void _initFromConfiguration() {
    if (widget.configurationInitiale != null) {
      for (final config in widget.configurationInitiale!) {
        _selections.putIfAbsent(config.critereId, () => {});
        for (final elementId in config.elementIds) {
          _selections[config.critereId]!.add(elementId);
        }
      }
    }
  }

  void _toggleElement(String critereId, String elementId) {
    setState(() {
      _selections.putIfAbsent(critereId, () => {});
      final set = _selections[critereId]!;

      if (set.contains(elementId)) {
        set.remove(elementId);
      } else {
        set.add(elementId);
      }
    });
    _emitConfiguration();
  }

  void _emitConfiguration() {
    final config = <ConfigurationElementEvaluation>[];
    for (final critere in widget.criteres) {
      final selected = _selections[critere.id];
      if (selected != null && selected.isNotEmpty) {
        config.add(ConfigurationElementEvaluation(
          critereId: critere.id,
          elementIds: selected.toList(),
        ));
      }
    }
    widget.onConfigurationChanged(config);
  }

  bool get isComplete {
    for (final critere in widget.criteres) {
      final selected = _selections[critere.id];
      if (selected == null || selected.isEmpty) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final subtitleColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assessment_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Configuration d\'evaluation',
                style: GoogleFonts.montserrat(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _buildCompletionBadge(textColor),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Selectionnez au moins 1 element par critere',
          style: GoogleFonts.montserrat(
            color: subtitleColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.criteres.map((critere) => _buildCritereSection(
              critere, textColor, subtitleColor, isDark)),
      ],
    );
  }

  Widget _buildCompletionBadge(Color textColor) {
    final completedCount = widget.criteres.where((c) {
      final s = _selections[c.id];
      return s != null && s.isNotEmpty;
    }).length;

    final color = completedCount == widget.criteres.length
        ? Colors.green
        : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$completedCount/${widget.criteres.length}',
        style: GoogleFonts.montserrat(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCritereSection(
    CritereEvaluation critere,
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    final selected = _selections[critere.id] ?? {};
    final nbSelected = selected.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: nbSelected >= 1
              ? Colors.green.withValues(alpha: 0.5)
              : isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  critere.nom,
                  style: GoogleFonts.montserrat(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: nbSelected >= 1
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$nbSelected',
                  style: GoogleFonts.montserrat(
                    color: nbSelected >= 1 ? Colors.green : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: critere.elements.map((element) {
              final isSelected = selected.contains(element.id);

              return _buildElementChip(
                element: element,
                isSelected: isSelected,
                critereId: critere.id,
                isDark: isDark,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildElementChip({
    required ElementEvaluation element,
    required bool isSelected,
    required String critereId,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _toggleElement(critereId, element.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.1)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            Text(
              element.libelle,
              style: GoogleFonts.montserrat(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
