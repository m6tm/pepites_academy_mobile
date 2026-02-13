import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/bulletin.dart';
import '../../../theme/app_colors.dart';

/// Widget affichant les courbes d'evolution des competences
/// sur plusieurs periodes. Compare la periode actuelle
/// aux periodes precedentes.
class EvolutionChartWidget extends StatelessWidget {
  final List<Bulletin> bulletins;
  final double height;

  const EvolutionChartWidget({
    super.key,
    required this.bulletins,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (bulletins.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final sorted = List<Bulletin>.from(bulletins)
      ..sort((a, b) => a.dateDebutPeriode.compareTo(b.dateDebutPeriode));

    final maxBulletins = sorted.length > 6 ? sorted.sublist(sorted.length - 6) : sorted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evolution des competences',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: height,
          child: CustomPaint(
            size: Size(double.infinity, height),
            painter: _EvolutionPainter(
              bulletins: maxBulletins,
              isDark: isDark,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildLegende(isDark),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Pas assez de donnees pour afficher l\'evolution.\nGenerez plusieurs bulletins pour voir les courbes.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }

  Widget _buildLegende(bool isDark) {
    final items = [
      ('Technique', const Color(0xFFC8102E)),
      ('Physique', const Color(0xFF2196F3)),
      ('Tactique', const Color(0xFF4CAF50)),
      ('Mental', const Color(0xFFFF9800)),
      ('Esprit eq.', const Color(0xFF9C27B0)),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 3,
              decoration: BoxDecoration(
                color: item.$2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.$1,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Painter pour les courbes d'evolution.
class _EvolutionPainter extends CustomPainter {
  final List<Bulletin> bulletins;
  final bool isDark;

  static const List<Color> _lineColors = [
    Color(0xFFC8102E),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
  ];

  _EvolutionPainter({
    required this.bulletins,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bulletins.isEmpty) return;

    final paddingLeft = 30.0;
    final paddingBottom = 30.0;
    final paddingTop = 10.0;
    final paddingRight = 10.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingBottom - paddingTop;

    _dessinerAxes(canvas, size, paddingLeft, paddingBottom, paddingTop, chartWidth, chartHeight);
    _dessinerLabelsX(canvas, size, paddingLeft, paddingBottom, chartWidth);
    _dessinerLabelsY(canvas, size, paddingLeft, paddingBottom, paddingTop, chartHeight);

    for (int domaine = 0; domaine < 5; domaine++) {
      _dessinerCourbe(
        canvas, paddingLeft, paddingTop, chartWidth, chartHeight,
        domaine, _lineColors[domaine],
      );
    }
  }

  void _dessinerAxes(
    Canvas canvas, Size size,
    double paddingLeft, double paddingBottom, double paddingTop,
    double chartWidth, double chartHeight,
  ) {
    final axisPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(paddingLeft, paddingTop),
      Offset(paddingLeft, size.height - paddingBottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(paddingLeft, size.height - paddingBottom),
      Offset(size.width - 10, size.height - paddingBottom),
      axisPaint,
    );

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 5; i++) {
      final y = paddingTop + chartHeight * (1 - i / 5);
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(paddingLeft + chartWidth, y),
        gridPaint,
      );
    }
  }

  void _dessinerLabelsX(
    Canvas canvas, Size size,
    double paddingLeft, double paddingBottom, double chartWidth,
  ) {
    for (int i = 0; i < bulletins.length; i++) {
      final x = paddingLeft + (chartWidth * i / max(1, bulletins.length - 1));
      final label = bulletins[i].periodeLabel;
      final shortLabel = label.length > 6 ? label.substring(0, 6) : label;

      final tp = TextPainter(
        text: TextSpan(
          text: shortLabel,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(x - tp.width / 2, size.height - paddingBottom + 6),
      );
    }
  }

  void _dessinerLabelsY(
    Canvas canvas, Size size,
    double paddingLeft, double paddingBottom, double paddingTop,
    double chartHeight,
  ) {
    for (int i = 0; i <= 5; i++) {
      final y = paddingTop + chartHeight * (1 - i / 5);
      final tp = TextPainter(
        text: TextSpan(
          text: '${i * 2}',
          style: TextStyle(
            fontSize: 9,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(paddingLeft - tp.width - 4, y - tp.height / 2));
    }
  }

  void _dessinerCourbe(
    Canvas canvas, double paddingLeft, double paddingTop,
    double chartWidth, double chartHeight,
    int domaineIndex, Color color,
  ) {
    if (bulletins.length < 2) {
      final value = _getValeurDomaine(bulletins[0], domaineIndex);
      final x = paddingLeft + chartWidth / 2;
      final y = paddingTop + chartHeight * (1 - value / 10);
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = color,
      );
      return;
    }

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < bulletins.length; i++) {
      final value = _getValeurDomaine(bulletins[i], domaineIndex);
      final x = paddingLeft + (chartWidth * i / (bulletins.length - 1));
      final y = paddingTop + chartHeight * (1 - value / 10);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final point in points) {
      canvas.drawCircle(
        point,
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point,
        3,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  double _getValeurDomaine(Bulletin bulletin, int index) {
    final values = bulletin.competences.toList();
    return values[index].clamp(0, 10);
  }

  @override
  bool shouldRepaint(covariant _EvolutionPainter oldDelegate) {
    return oldDelegate.bulletins != bulletins;
  }
}
