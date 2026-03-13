import 'package:flutter/material.dart';
import '../../domain/entities/exercice.dart';
import 'statut_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

/// Composant de liste pour chaque exercice associé à un atelier.
class ExerciceListTile extends StatelessWidget {
  final Exercice exercice;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApply;
  final VoidCallback? onClose;
  final bool isEditable;
  final int? index;

  const ExerciceListTile({
    super.key,
    required this.exercice,
    this.onEdit,
    this.onDelete,
    this.onApply,
    this.onClose,
    this.isEditable = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: StatutIndicator(statut: exercice.statut),
      title: Text(
        exercice.nom,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: exercice.description.isNotEmpty
          ? Text(
              exercice.description,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isEditable
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onApply != null && exercice.statut == ExerciceStatut.valide)
                  IconButton(
                    icon: Icon(Icons.play_circle_outline_rounded, size: 18, color: colorScheme.primary),
                    onPressed: onApply,
                    tooltip: 'Appliquer en séance',
                  ),
                if (onClose != null && exercice.statut == ExerciceStatut.applique)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.green),
                    onPressed: onClose,
                    tooltip: 'Fermer l\'exercice',
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 18, color: colorScheme.primary),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    onPressed: onDelete,
                  ),
                if (index != null)
                  ReorderableDragStartListener(
                    index: index!,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                      child: Icon(Icons.drag_handle_rounded, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                    ),
                  ),
              ],
            )
          : null,
    );
  }
}
