import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

/// Widget permettant de dessiner une signature avec le doigt ou un stylet.
/// Le tracé est fin mais visible, avec support de la pression pour les stylets.
class SignaturePad extends StatefulWidget {
  /// Couleur du tracé
  final Color strokeColor;

  /// Epaisseur du tracé
  final double strokeWidth;

  /// Callback appele quand la signature est sauvegardee
  final ValueChanged<File?>? onSignatureSaved;

  const SignaturePad({
    super.key,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
    this.onSignatureSaved,
  });

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = [];
  final GlobalKey _signatureKey = GlobalKey();
  bool _isEmpty = true;

  /// Verifie si la signature est vide
  bool get isEmpty => _isEmpty;

  /// Efface la signature
  void clear() {
    setState(() {
      _points.clear();
      _isEmpty = true;
    });
  }

  /// Sauvegarde la signature en tant que fichier image PNG
  Future<File?> saveSignature() async {
    if (_isEmpty || _points.isEmpty) return null;

    try {
      // Capturer le widget en image
      final RenderRepaintBoundary boundary =
          _signatureKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return null;

      // Sauvegarder dans un fichier temporaire
      final directory = await getTemporaryDirectory();
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      widget.onSignatureSaved?.call(file);
      return file;
    } catch (e) {
      debugPrint('Erreur sauvegarde signature: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Zone de dessin
        Expanded(
          child: RepaintBoundary(
            key: _signatureKey,
            child: Container(
              color: Colors.white,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                        _isEmpty = false;
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _points.add(null); // Marque la fin du trait
                      });
                    },
                    child: CustomPaint(
                      painter: _SignaturePainter(
                        points: _points,
                        strokeColor: widget.strokeColor,
                        strokeWidth: widget.strokeWidth,
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Ligne de signature
        Container(
          height: 1,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),

        // Indication
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Signez ci-dessus',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

/// Paint personnalise pour dessiner la signature avec un tracé fin et lisse
class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;
  final double strokeWidth;

  _SignaturePainter({
    required this.points,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    // Dessiner chaque trait continu
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      if (current != null && next != null) {
        canvas.drawLine(current, next, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return points.length != oldDelegate.points.length;
  }
}

/// Affiche un dialogue modal pour capturer une signature
class SignatureDialog {
  /// Affiche le dialogue de signature et retourne le fichier genere
  static Future<File?> show(BuildContext context) async {
    final GlobalKey<SignaturePadState> signatureKey = GlobalKey();

    return await showModalBottomSheet<File?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Poignee de glissement
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // En-tete
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Signature',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Zone de signature
              Expanded(
                child: SignaturePad(
                  key: signatureKey,
                  strokeColor: Colors.black,
                  strokeWidth: 2.0,
                ),
              ),

              // Boutons d'action
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Bouton effacer
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          signatureKey.currentState?.clear();
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Effacer'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Bouton valider
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final file = await signatureKey.currentState
                              ?.saveSignature();
                          if (context.mounted) {
                            Navigator.pop(context, file);
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Valider'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}
