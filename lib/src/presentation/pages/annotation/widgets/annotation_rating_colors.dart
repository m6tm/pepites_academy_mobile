import 'package:flutter/material.dart';

/// Retourne la couleur associée à une note sur une échelle de 0 à 5.
/// - Rouge   : 0.0 → 1.5  (très insuffisant)
/// - Orange  : 2.0 → 2.5  (insuffisant)
/// - Jaune   : 3.0 → 3.5  (passable)
/// - Vert    : 4.0 → 5.0  (excellent)
Color getRatingColor(double value) {
  if (value <= 1.5) return const Color(0xFFE53935); // Rouge
  if (value <= 2.5) return const Color(0xFFFB8C00); // Orange
  if (value <= 3.5) return const Color(0xFFFDD835); // Jaune
  return const Color(0xFF43A047); // Vert
}

/// Icône Material adaptée au niveau de la note.
IconData getRatingIcon(double value) {
  if (value <= 1.5) return Icons.sentiment_very_dissatisfied;
  if (value <= 2.5) return Icons.sentiment_dissatisfied;
  if (value <= 3.5) return Icons.sentiment_neutral;
  return Icons.sentiment_very_satisfied;
}

/// Cercle coloré + icône représentant une note unique.
class RatingIndicator extends StatelessWidget {
  final double note;
  final double size;

  const RatingIndicator({
    super.key,
    required this.note,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final color = getRatingColor(note);
    return Icon(
      getRatingIcon(note),
      color: color,
      size: size,
    );
  }
}

/// Barre de progression horizontale colorée selon la note.
/// [note]    : valeur actuelle
/// [maxNote] : valeur maximale (ex: 5 pour un élément, 10 pour un critère, 50 pour le total)
class RatingBar extends StatelessWidget {
  final double note;
  final double maxNote;
  final double height;
  final double width;

  const RatingBar({
    super.key,
    required this.note,
    this.maxNote = 5.0,
    this.height = 6,
    this.width = 80,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (note / maxNote).clamp(0.0, 1.0);
    // Normalise sur 5 pour récupérer la bonne couleur
    final normalized = (note * (5.0 / maxNote)).clamp(0.0, 5.0);
    final color = getRatingColor(normalized);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: width * ratio,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
