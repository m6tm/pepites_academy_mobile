import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Overlay du scanner QR avec viseur en verre depoli et bordures lumineuses animees.
/// Cree un effet Glassmorphism autour de la zone de scan.
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({super.key});

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _borderController;
  late final Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;

    return Stack(
      children: [
        // Zone sombre autour du viseur
        CustomPaint(
          size: size,
          painter: _OverlayPainter(scanAreaSize: scanAreaSize),
        ),
        // Viseur avec bordures lumineuses animees
        Center(
          child: SizedBox(
            width: scanAreaSize,
            height: scanAreaSize,
            child: AnimatedBuilder(
              animation: _borderAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ViewfinderPainter(
                    progress: _borderAnimation.value,
                  ),
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Peint la zone sombre autour du viseur de scan.
class _OverlayPainter extends CustomPainter {
  final double scanAreaSize;

  _OverlayPainter({required this.scanAreaSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Dessine le fond sombre avec un trou pour le viseur
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
          ),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) =>
      oldDelegate.scanAreaSize != scanAreaSize;
}

/// Peint les coins lumineux animes du viseur.
class _ViewfinderPainter extends CustomPainter {
  final double progress;

  _ViewfinderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cornerLength = size.width * 0.15;
    const strokeWidth = 3.0;
    const radius = 20.0;

    // Couleur animee qui pulse entre rouge et blanc
    final color = Color.lerp(
      AppColors.primary,
      Colors.white,
      (sin(progress * 2 * pi) + 1) / 4,
    )!;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Coin superieur gauche
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..arcToPoint(
          const Offset(radius, 0),
          radius: const Radius.circular(radius),
        )
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Coin superieur droit
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..arcToPoint(
          Offset(size.width, radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Coin inferieur droit
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLength)
        ..lineTo(size.width, size.height - radius)
        ..arcToPoint(
          Offset(size.width - radius, size.height),
          radius: const Radius.circular(radius),
        )
        ..lineTo(size.width - cornerLength, size.height),
      paint,
    );

    // Coin inferieur gauche
    canvas.drawPath(
      Path()
        ..moveTo(cornerLength, size.height)
        ..lineTo(radius, size.height)
        ..arcToPoint(
          Offset(0, size.height - radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(0, size.height - cornerLength),
      paint,
    );

    // Ligne de scan animee horizontale
    final scanLineY = size.height * progress;
    final scanLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary.withValues(alpha: 0.6),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(0, scanLineY - 1, size.width, 2),
      )
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(radius, scanLineY),
      Offset(size.width - radius, scanLineY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) => true;
}
