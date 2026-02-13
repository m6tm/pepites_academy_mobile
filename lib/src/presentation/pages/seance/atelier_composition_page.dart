import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/atelier.dart';
import '../../../domain/entities/seance.dart';
import '../../../injection_container.dart';
import '../../state/annotation_state.dart';
import '../../state/atelier_state.dart';
import '../../theme/app_colors.dart';
import '../annotation/annotation_page.dart';

/// Ecran de composition des ateliers rattache a une seance.
/// Permet d'ajouter, modifier, supprimer et reorganiser les ateliers
/// par glisser-deposer.
class AtelierCompositionPage extends StatefulWidget {
  final Seance seance;
  final AtelierState atelierState;

  const AtelierCompositionPage({
    super.key,
    required this.seance,
    required this.atelierState,
  });

  @override
  State<AtelierCompositionPage> createState() => _AtelierCompositionPageState();
}

class _AtelierCompositionPageState extends State<AtelierCompositionPage> {
  @override
  void initState() {
    super.initState();
    widget.atelierState.addListener(_onStateChanged);
    widget.atelierState.chargerAteliers(widget.seance.id);
  }

  @override
  void dispose() {
    widget.atelierState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});

    final state = widget.atelierState;
    if (state.successMessage != null) {
      _showSnackBar(state.successMessage!, isError: false);
      state.clearMessages();
    } else if (state.errorMessage != null) {
      _showSnackBar(state.errorMessage!, isError: true);
      state.clearMessages();
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = widget.atelierState;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildRecapHeader(colorScheme, isDark)),
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.ateliers.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(colorScheme))
          else
            _buildAtelierList(colorScheme, isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: widget.seance.estOuverte
          ? FloatingActionButton.extended(
              onPressed: () => _showAjouterAtelierDialog(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Ajouter',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.primary.withValues(alpha: 0.95),
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Ateliers',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecapHeader(ColorScheme colorScheme, bool isDark) {
    final state = widget.atelierState;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.seance.titre,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.ateliers.length} atelier${state.ateliers.length > 1 ? 's' : ''} programme${state.ateliers.length > 1 ? 's' : ''}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.seance.estOuverte
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.seance.estOuverte ? 'En cours' : 'Fermee',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.seance.estOuverte
                    ? const Color(0xFF10B981)
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun atelier programme',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Composez votre seance en ajoutant des ateliers.\n'
              'Chaque atelier represente un bloc d\'activite.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            if (widget.seance.estOuverte) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => _showAjouterAtelierDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  'Ajouter un atelier',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAtelierList(ColorScheme colorScheme, bool isDark) {
    final state = widget.atelierState;

    if (!widget.seance.estOuverte) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final atelier = state.ateliers[index];
            return _AtelierCard(
              atelier: atelier,
              isDark: isDark,
              colorScheme: colorScheme,
              isEditable: false,
              onEdit: null,
              onDelete: null,
              onAnnotate: () => _naviguerVersAnnotations(atelier),
            );
          }, childCount: state.ateliers.length),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverReorderableList(
        itemBuilder: (context, index) {
          final atelier = state.ateliers[index];
          return ReorderableDragStartListener(
            key: ValueKey(atelier.id),
            index: index,
            child: _AtelierCard(
              atelier: atelier,
              isDark: isDark,
              colorScheme: colorScheme,
              isEditable: true,
              onEdit: () => _showModifierAtelierDialog(context, atelier),
              onDelete: () => _confirmerSuppression(context, atelier),
              onAnnotate: () => _naviguerVersAnnotations(atelier),
            ),
          );
        },
        itemCount: state.ateliers.length,
        onReorder: (oldIndex, newIndex) {
          state.reordonnerAteliers(oldIndex, newIndex);
        },
      ),
    );
  }

  void _showAjouterAtelierDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AtelierFormSheet(
        onSubmit: (nom, type, description) {
          widget.atelierState.ajouterAtelier(
            nom: nom,
            type: type,
            description: description,
          );
        },
      ),
    );
  }

  void _showModifierAtelierDialog(BuildContext context, Atelier atelier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AtelierFormSheet(
        atelier: atelier,
        onSubmit: (nom, type, description) {
          widget.atelierState.modifierAtelier(
            atelier.copyWith(nom: nom, type: type, description: description),
          );
        },
      ),
    );
  }

  void _naviguerVersAnnotations(Atelier atelier) {
    final annotationState = AnnotationState(
      DependencyInjection.annotationService,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnnotationPage(
          atelier: atelier,
          seance: widget.seance,
          annotationState: annotationState,
        ),
      ),
    );
  }

  void _confirmerSuppression(BuildContext context, Atelier atelier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Supprimer l\'atelier ?',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'L\'atelier "${atelier.nom}" sera definitivement supprime.',
          style: GoogleFonts.montserrat(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: AppColors.textMutedLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.atelierState.supprimerAtelier(atelier.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Supprimer',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte representant un atelier dans la liste.
class _AtelierCard extends StatelessWidget {
  final Atelier atelier;
  final bool isDark;
  final ColorScheme colorScheme;
  final bool isEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAnnotate;

  const _AtelierCard({
    required this.atelier,
    required this.isDark,
    required this.colorScheme,
    required this.isEditable,
    this.onEdit,
    this.onDelete,
    this.onAnnotate,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(atelier.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEditable ? onEdit : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getTypeIcon(atelier.type),
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atelier.nom,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              atelier.typeLabel,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: typeColor,
                              ),
                            ),
                          ),
                          if (atelier.description.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                atelier.description,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (onAnnotate != null)
                  IconButton(
                    onPressed: onAnnotate,
                    icon: Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      size: 22,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Annoter',
                  ),
                if (isEditable) ...[
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  Icon(
                    Icons.drag_handle_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    size: 22,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _getTypeColor(AtelierType type) {
    switch (type) {
      case AtelierType.dribble:
        return const Color(0xFF3B82F6);
      case AtelierType.passes:
        return const Color(0xFF10B981);
      case AtelierType.finition:
        return const Color(0xFFEF4444);
      case AtelierType.physique:
        return const Color(0xFFF59E0B);
      case AtelierType.jeuEnSituation:
        return const Color(0xFF8B5CF6);
      case AtelierType.tactique:
        return const Color(0xFF6366F1);
      case AtelierType.gardien:
        return const Color(0xFF14B8A6);
      case AtelierType.echauffement:
        return const Color(0xFFF97316);
      case AtelierType.personnalise:
        return const Color(0xFF64748B);
    }
  }

  static IconData _getTypeIcon(AtelierType type) {
    switch (type) {
      case AtelierType.dribble:
        return Icons.sports_soccer_rounded;
      case AtelierType.passes:
        return Icons.swap_horiz_rounded;
      case AtelierType.finition:
        return Icons.sports_rounded;
      case AtelierType.physique:
        return Icons.timer_rounded;
      case AtelierType.jeuEnSituation:
        return Icons.groups_rounded;
      case AtelierType.tactique:
        return Icons.map_rounded;
      case AtelierType.gardien:
        return Icons.sports_handball_rounded;
      case AtelierType.echauffement:
        return Icons.directions_run_rounded;
      case AtelierType.personnalise:
        return Icons.tune_rounded;
    }
  }
}

/// Bottom sheet pour ajouter ou modifier un atelier.
class _AtelierFormSheet extends StatefulWidget {
  final Atelier? atelier;
  final void Function(String nom, AtelierType type, String description)
  onSubmit;

  const _AtelierFormSheet({this.atelier, required this.onSubmit});

  @override
  State<_AtelierFormSheet> createState() => _AtelierFormSheetState();
}

class _AtelierFormSheetState extends State<_AtelierFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  late AtelierType _selectedType;
  bool _isCustomName = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.atelier?.nom ?? '');
    _descriptionController = TextEditingController(
      text: widget.atelier?.description ?? '',
    );
    _selectedType = widget.atelier?.type ?? AtelierType.dribble;
    _isCustomName =
        widget.atelier?.type == AtelierType.personnalise ||
        (widget.atelier != null &&
            widget.atelier!.nom != _getDefaultName(widget.atelier!.type));
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getDefaultName(AtelierType type) {
    switch (type) {
      case AtelierType.dribble:
        return 'Dribble';
      case AtelierType.passes:
        return 'Passes';
      case AtelierType.finition:
        return 'Finition';
      case AtelierType.physique:
        return 'Condition physique';
      case AtelierType.jeuEnSituation:
        return 'Jeu en situation';
      case AtelierType.tactique:
        return 'Tactique';
      case AtelierType.gardien:
        return 'Gardien';
      case AtelierType.echauffement:
        return 'Echauffement';
      case AtelierType.personnalise:
        return '';
    }
  }

  void _onTypeSelected(AtelierType type) {
    setState(() {
      _selectedType = type;
      if (type == AtelierType.personnalise) {
        _isCustomName = true;
        _nomController.text = '';
      } else if (!_isCustomName) {
        _nomController.text = _getDefaultName(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.atelier != null;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? 'Modifier l\'atelier' : 'Ajouter un atelier',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Selectionnez un type d\'exercice',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),
              _buildTypeGrid(colorScheme, isDark),
              const SizedBox(height: 20),
              Text(
                'Nom de l\'atelier',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomController,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Ex: Dribble en slalom',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  filled: true,
                  fillColor: colorScheme.onSurface.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
                onChanged: (_) {
                  _isCustomName = true;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Description (optionnelle)',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Decrivez l\'exercice...',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  filled: true,
                  fillColor: colorScheme.onSurface.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Modifier' : 'Ajouter l\'atelier',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeGrid(ColorScheme colorScheme, bool isDark) {
    final types = AtelierType.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = type == _selectedType;
        final color = _AtelierCard._getTypeColor(type);
        final icon = _AtelierCard._getTypeIcon(type);

        return GestureDetector(
          onTap: () => _onTypeSelected(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.5)
                    : colorScheme.onSurface.withValues(alpha: 0.06),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? color
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  _getDefaultName(type).isEmpty
                      ? 'Libre'
                      : _getDefaultName(type),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? color
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _nomController.text.trim(),
        _selectedType,
        _descriptionController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }
}
