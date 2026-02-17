import 'dart:math';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/bulletin.dart';
import '../../../theme/app_colors.dart';

/// Widget affichant un diagramme radar des competences.
/// Dessine un pentagone avec les 5 axes de competences
/// (Technique, Physique, Tactique, Mental, Esprit d'equipe).
class CompetencesRadarWidget extends StatelessWidget {
  final Competences competences;
  final Competences? competencesPrecedentes;
  final double size;

  const CompetencesRadarWidget({
    super.key,
    required this.competences,
    this.competencesPrecedentes,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final translatedLabels = [
      l10n.competenceTechnique,
      l10n.competencePhysique,
      l10n.competenceTactique,
      l10n.competenceMental,
      l10n.competenceEspritEquipe,
    ];

    return Column(
      children: [
        Text(
          l10n.radarChartTitle,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            size: Size(size, size),
            painter: _RadarPainter(
              competences: competences,
              competencesPrecedentes: competencesPrecedentes,
              isDark: isDark,
              labels: translatedLabels,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegende(isDark, l10n),
      ],
    );
  }

  Widget _buildLegende(bool isDark, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(l10n.actualLabel, AppColors.primary, isDark),
        if (competencesPrecedentes != null) ...[
          const SizedBox(width: 24),
          _buildLegendItem(
            l10n.previousLabel,
            AppColors.primary.withValues(alpha: 0.3),
            isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }
}

/// Painter personnalise pour le diagramme radar.
class _RadarPainter extends CustomPainter {
  final Competences competences;
  final Competences? competencesPrecedentes;
  final bool isDark;
  final List<String> labels;

  _RadarPainter({
    required this.competences,
    this.competencesPrecedentes,
    required this.isDark,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    final values = competences.toList();
    final nbAxes = labels.length;
    final angleStep = (2 * pi) / nbAxes;
    final startAngle = -pi / 2;

    _dessinerGrille(canvas, center, radius, nbAxes, angleStep, startAngle);
    _dessinerLabels(
      canvas,
      center,
      radius,
      labels,
      nbAxes,
      angleStep,
      startAngle,
      size,
    );

    if (competencesPrecedentes != null) {
      _dessinerZone(
        canvas,
        center,
        radius,
        competencesPrecedentes!.toList(),
        nbAxes,
        angleStep,
        startAngle,
        AppColors.primary.withValues(alpha: 0.15),
        AppColors.primary.withValues(alpha: 0.3),
      );
    }

    _dessinerZone(
      canvas,
      center,
      radius,
      values,
      nbAxes,
      angleStep,
      startAngle,
      AppColors.primary.withValues(alpha: 0.25),
      AppColors.primary,
    );

    _dessinerPoints(
      canvas,
      center,
      radius,
      values,
      nbAxes,
      angleStep,
      startAngle,
    );
  }

  void _dessinerGrille(
    Canvas canvas,
    Offset center,
    double radius,
    int nbAxes,
    double angleStep,
    double startAngle,
  ) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int level = 1; level <= 5; level++) {
      final r = radius * level / 5;
      final path = Path();
      for (int i = 0; i <= nbAxes; i++) {
        final angle = startAngle + angleStep * (i % nbAxes);
        final point = Offset(
          center.dx + r * cos(angle),
          center.dy + r * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final axisPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < nbAxes; i++) {
      final angle = startAngle + angleStep * i;
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, end, axisPaint);
    }
  }

  void _dessinerLabels(
    Canvas canvas,
    Offset center,
    double radius,
    List<String> labels,
    int nbAxes,
    double angleStep,
    double startAngle,
    Size size,
  ) {
    for (int i = 0; i < nbAxes; i++) {
      final angle = startAngle + angleStep * i;
      final labelRadius = radius + 20;
      final labelPos = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        labelPos.dx - textPainter.width / 2,
        labelPos.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  void _dessinerZone(
    Canvas canvas,
    Offset center,
    double radius,
    List<double> values,
    int nbAxes,
    double angleStep,
    double startAngle,
    Color fillColor,
    Color strokeColor,
  ) {
    final path = Path();
    for (int i = 0; i <= nbAxes; i++) {
      final angle = startAngle + angleStep * (i % nbAxes);
      final value = (values[i % nbAxes] / 10).clamp(0.0, 1.0);
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _dessinerPoints(
    Canvas canvas,
    Offset center,
    double radius,
    List<double> values,
    int nbAxes,
    double angleStep,
    double startAngle,
  ) {
    for (int i = 0; i < nbAxes; i++) {
      final angle = startAngle + angleStep * i;
      final value = (values[i] / 10).clamp(0.0, 1.0);
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );

      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.competences != competences ||
        oldDelegate.competencesPrecedentes != competencesPrecedentes ||
        oldDelegate.labels != labels;
  }
}
