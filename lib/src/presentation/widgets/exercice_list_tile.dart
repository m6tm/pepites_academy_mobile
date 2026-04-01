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
  final VoidCallback? onAnnotate;
  final bool isEditable;
  final int? index;

  const ExerciceListTile({
    super.key,
    required this.exercice,
    this.onEdit,
    this.onDelete,
    this.onApply,
    this.onClose,
    this.onAnnotate,
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
          ? Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: -4, // Resserre les icônes
              children: [
                if (onApply != null && exercice.statut == ExerciceStatut.valide)
                  IconButton(
                    icon: Icon(Icons.play_circle_outline_rounded, size: 18, color: colorScheme.primary),
                    onPressed: onApply,
                    tooltip: 'Appliquer en séance',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (onClose != null && exercice.statut == ExerciceStatut.applique)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.green),
                    onPressed: onClose,
                    tooltip: 'Fermer l\'exercice',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (onAnnotate != null)
                  IconButton(
                    icon: Icon(
                      Icons.note_alt_outlined,
                      size: 18,
                      color: exercice.statut == ExerciceStatut.applique
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    onPressed: exercice.statut == ExerciceStatut.applique ? onAnnotate : null,
                    tooltip: exercice.statut == ExerciceStatut.applique
                        ? 'Annoter l\'exercice'
                        : 'Veuillez appliquer l\'exercice pour commencer les annotations',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 18, color: colorScheme.primary),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (index != null)
                  ReorderableDragStartListener(
                    index: index!,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                      child: Icon(Icons.drag_handle_rounded, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                    ),
                  ),
              ],
            )
          : null,
    );
  }
}
