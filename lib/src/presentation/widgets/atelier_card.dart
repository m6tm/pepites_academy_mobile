import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/atelier.dart';
import '../../domain/entities/exercice.dart';
import 'exercice_list_tile.dart';
import 'statut_indicator.dart';

/// Une carte expandable pour afficher les détails d'un atelier et ses exercices.
class AtelierCard extends StatefulWidget {
  final Atelier atelier;
  final List<Exercice> exercices;
  final bool isEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddExercice;
  final VoidCallback? onAnnotate;
  final Function(Exercice)? onEditExercice;
  final Function(Exercice)? onDeleteExercice;
  final VoidCallback? onApply;
  final Function(Exercice)? onApplyExercice;
  final Function(Exercice)? onCloseExercice;
  final bool isLoadingExercices;

  const AtelierCard({
    super.key,
    required this.atelier,
    required this.exercices,
    this.isEditable = false,
    this.onEdit,
    this.onDelete,
    this.onAddExercice,
    this.onAnnotate,
    this.onEditExercice,
    this.onDeleteExercice,
    this.onApply,
    this.onApplyExercice,
    this.onCloseExercice,
    this.isLoadingExercices = false,
  });

  @override
  State<AtelierCard> createState() => _AtelierCardState();
}

class _AtelierCardState extends State<AtelierCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _getAtelierTypeColor(widget.atelier.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded 
              ? typeColor.withValues(alpha: 0.3) 
              : colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (Clickable to expand)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getTypeIcon(widget.atelier.type),
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.atelier.nom,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StatutIndicator(statut: widget.atelier.statut, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.exercices.length} exercices',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions or Expand Icon
                  if (widget.isEditable)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onApply != null && widget.atelier.statut == AtelierStatut.valide)
                          IconButton(
                            icon: Icon(Icons.play_circle_outline_rounded, size: 20, color: typeColor),
                            onPressed: widget.onApply,
                            tooltip: 'Appliquer en séance',
                          ),
                        if (widget.onAnnotate != null)
                          IconButton(
                            icon: Icon(Icons.note_alt_outlined, size: 20, color: typeColor),
                            onPressed: widget.onAnnotate,
                          ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 20, color: typeColor),
                          onPressed: widget.onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                          onPressed: widget.onDelete,
                        ),
                      ],
                    ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                const Divider(height: 1),
                if (widget.atelier.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.atelier.description,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ),
                
                // Exercices List
                if (widget.isLoadingExercices)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else if (widget.exercices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Aucun exercice pour cet atelier',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                else
                  ...widget.exercices.map((ex) => ExerciceListTile(
                        exercice: ex,
                        isEditable: widget.isEditable,
                        onEdit: widget.onEditExercice != null ? () => widget.onEditExercice!(ex) : null,
                        onDelete: widget.onDeleteExercice != null ? () => widget.onDeleteExercice!(ex) : null,
                        onApply: widget.onApplyExercice != null ? () => widget.onApplyExercice!(ex) : null,
                        onClose: widget.onCloseExercice != null ? () => widget.onCloseExercice!(ex) : null,
                      )),
                
                // Add Exercice Button
                if (widget.isEditable && widget.onAddExercice != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextButton.icon(
                      onPressed: widget.onAddExercice,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        'Ajouter un exercice',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: typeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Color _getAtelierTypeColor(AtelierType type) {
    switch (type) {
      case AtelierType.dribble: return const Color(0xFF3B82F6);
      case AtelierType.passes: return const Color(0xFF10B981);
      case AtelierType.finition: return const Color(0xFFEF4444);
      case AtelierType.physique: return const Color(0xFFF59E0B);
      case AtelierType.jeuEnSituation: return const Color(0xFF8B5CF6);
      case AtelierType.tactique: return const Color(0xFF6366F1);
      case AtelierType.gardien: return const Color(0xFF14B8A6);
      case AtelierType.echauffement: return const Color(0xFFF97316);
      case AtelierType.personnalise: return const Color(0xFF64748B);
    }
  }

  IconData _getTypeIcon(AtelierType type) {
    switch (type) {
      case AtelierType.dribble: return Icons.sports_soccer_rounded;
      case AtelierType.passes: return Icons.swap_horiz_rounded;
      case AtelierType.finition: return Icons.sports_rounded;
      case AtelierType.physique: return Icons.timer_rounded;
      case AtelierType.jeuEnSituation: return Icons.groups_rounded;
      case AtelierType.tactique: return Icons.map_rounded;
      case AtelierType.gardien: return Icons.sports_handball_rounded;
      case AtelierType.echauffement: return Icons.directions_run_rounded;
      case AtelierType.personnalise: return Icons.tune_rounded;
    }
  }
}
