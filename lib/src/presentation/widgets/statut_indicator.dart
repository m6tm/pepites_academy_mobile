import 'package:flutter/material.dart';

/// Un indicateur visuel (icône colorée) basé sur le statut.
class StatutIndicator extends StatelessWidget {
  final Enum statut; // Soit AtelierStatut, soit ExerciceStatut
  final double size;

  const StatutIndicator({
    super.key,
    required this.statut,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIcon(),
        color: _getColor(),
        size: size,
      ),
    );
  }

  IconData _getIcon() {
    final sStr = statut.toString().split('.').last;
    switch (sStr) {
      case 'cree':
        return Icons.add_circle_outline_rounded;
      case 'modifie':
        return Icons.edit_note_rounded;
      case 'valide':
        return Icons.check_circle_outline_rounded;
      case 'applique':
        return Icons.play_circle_outline_rounded;
      case 'ferme':
        return Icons.lock_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getColor() {
    final sStr = statut.toString().split('.').last;
    switch (sStr) {
      case 'cree':
        return Colors.blue;
      case 'modifie':
        return Colors.orange;
      case 'valide':
        return Colors.green;
      case 'applique':
        return Colors.purple;
      case 'ferme':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
