import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../domain/entities/atelier.dart';
import '../../../domain/entities/exercice.dart';
import '../../../domain/entities/permission.dart';
import '../../../domain/entities/seance.dart';
import '../../../injection_container.dart';
import '../../state/atelier_state.dart';
import '../../state/exercice_state.dart';
import '../../state/annotation_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';
import '../annotation/annotation_page.dart';
import '../../state/message_state_mixin.dart';
import '../../widgets/atelier_card.dart';
import 'atelier_form_page.dart';
import '../exercices/exercice_form_page.dart';

/// Page affichant la liste des ateliers d'une séance avec leurs exercices associés.
class AteliersPage extends StatefulWidget {
  final Seance seance;

  const AteliersPage({super.key, required this.seance});

  static String getTypeLabel(BuildContext context, AtelierType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case AtelierType.dribble:
        return l10n.workshopTypeDribble;
      case AtelierType.passes:
        return l10n.workshopTypePasses;
      case AtelierType.finition:
        return l10n.workshopTypeFinition;
      case AtelierType.physique:
        return l10n.workshopTypePhysique;
      case AtelierType.jeuEnSituation:
        return l10n.workshopTypeJeuEnSituation;
      case AtelierType.tactique:
        return l10n.workshopTypeTactique;
      case AtelierType.gardien:
        return l10n.workshopTypeGardien;
      case AtelierType.echauffement:
        return l10n.workshopTypeEchauffement;
      case AtelierType.personnalise:
        return l10n.workshopTypePersonnalise;
    }
  }

  @override
  State<AteliersPage> createState() => _AteliersPageState();
}

class _AteliersPageState extends State<AteliersPage> {
  late final AtelierState _atelierState;
  late final ExerciceState _exerciceState;
  late final AnnotationState _annotationState;

  bool _hasCreatePermission = false;
  bool _hasUpdatePermission = false;
  bool _hasApplyAtelierPermission = false;
  bool _hasApplyExercicePermission = false;
  bool _hasCloseExercicePermission = false;

  @override
  void initState() {
    super.initState();
    _atelierState = DependencyInjection.atelierState;
    _exerciceState = DependencyInjection.exerciceState;
    _annotationState = DependencyInjection.annotationState;

    _atelierState.addListener(_onAtelierStateChanged);
    _exerciceState.addListener(_onExerciceStateChanged);

    _checkPermissions();
    
    // Initialiser les l10n pour les states
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _atelierState.setLocalizations(l10n);
        _exerciceState.setLocalizations(l10n);
      }
    });

    _loadData();
  }

  Future<void> _checkPermissions() async {
    final role = await DependencyInjection.roleService.getCurrentUserRole();
    if (mounted) {
      if (!role.hasPermission(Permission.atelierView)) {
        AcademyToast.show(
          context,
          title: 'Accès refusé. Permission manquante.',
          isError: true,
        );
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _hasCreatePermission = role.hasPermission(Permission.atelierCreate);
        _hasUpdatePermission = role.hasPermission(Permission.atelierUpdate);
        _hasApplyAtelierPermission = role.hasPermission(Permission.atelierApply);
        _hasApplyExercicePermission = role.hasPermission(Permission.exerciceApply);
        _hasCloseExercicePermission = role.hasPermission(Permission.exerciceClose);
      });
    }
  }

  Future<void> _loadData() async {
    await _atelierState.chargerAteliers(widget.seance.id);
    for (final atelier in _atelierState.ateliers) {
      _exerciceState.chargerExercices(atelier.id);
    }
  }

  void _onAtelierStateChanged() {
    if (mounted) setState(() {});
    _handleMessages(_atelierState);
  }

  void _onExerciceStateChanged() {
    if (mounted) setState(() {});
    _handleMessages(_exerciceState);
  }

  void _handleMessages(MessageStateMixin state) {
    if (state.successMessage != null) {
      AcademyToast.show(context, title: state.successMessage!, isSuccess: true);
      state.clearMessages();
    } else if (state.errorMessage != null) {
      AcademyToast.show(context, title: state.errorMessage!, isError: true);
      state.clearMessages();
    }
  }

  @override
  void dispose() {
    _atelierState.removeListener(_onAtelierStateChanged);
    _exerciceState.removeListener(_onExerciceStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, l10n),
          _buildHeader(context, l10n, colorScheme, isDark),
          if (_atelierState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_atelierState.ateliers.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(context, l10n, colorScheme),
            )
          else
            _buildAteliersList(l10n, colorScheme, isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: (_hasCreatePermission && widget.seance.estOuverte)
          ? FloatingActionButton.extended(
              onPressed: () => _showAddAtelier(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                l10n.addWorkshop,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
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
          l10n.workshops,
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

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primary,
                size: 22,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    widget.seance.dateFormatee,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(l10n, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(AppLocalizations l10n, ColorScheme colorScheme) {
    final isOpen = widget.seance.estOuverte;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? l10n.inProgress : l10n.completed,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isOpen ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer_rounded,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noWorkshopProgrammed,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAteliersList(
    AppLocalizations l10n,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final ateliers = _atelierState.ateliers;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverReorderableList(
        itemCount: ateliers.length,
        onReorder: _atelierState.reordonnerAteliers,
        itemBuilder: (context, index) {
          final atelier = ateliers[index];
          final exercices =
              _exerciceState.exercicesParAtelier[atelier.id] ?? [];

          return ReorderableDragStartListener(
            key: ValueKey(atelier.id),
            index: index,
            child: AtelierCard(
              atelier: atelier,
              exercices: exercices,
              isLoadingExercices: _exerciceState.isLoading(atelier.id),
              isEditable: _hasUpdatePermission && widget.seance.estOuverte,
              onAnnotate: () => _naviguerVersAnnotation(atelier),
              onEdit: () => _showEditAtelier(context, atelier),
              onDelete: () => _showDeleteConfirmation(context, atelier),
              onAddExercice: () => _showAddExercice(context, atelier),
              onEditExercice: (ex) => _showEditExercice(context, ex),
              onDeleteExercice: (ex) =>
                  _exerciceState.supprimerExercice(ex.id, atelier.id),
              onApply: (_hasApplyAtelierPermission && widget.seance.estOuverte) ? () => _confirmApplyAtelier(context, atelier) : null,
              onApplyExercice: (_hasApplyExercicePermission && widget.seance.estOuverte) ? (ex) => _confirmApplyExercice(context, ex) : null,
              onCloseExercice: (_hasCloseExercicePermission && widget.seance.estOuverte) ? (ex) => _confirmCloseExercice(context, ex) : null,
            ),
          );
        },
      ),
    );
  }

  // --- Modal Logic ---

  void _showAddAtelier(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AtelierFormPage(
          seanceId: widget.seance.id,
          atelierState: _atelierState,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showEditAtelier(BuildContext context, Atelier atelier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AtelierFormPage(
          seanceId: widget.seance.id,
          atelier: atelier,
          atelierState: _atelierState,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Atelier atelier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'atelier'),
        content: Text('Voulez-vous vraiment supprimer "${atelier.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _atelierState.supprimerAtelier(atelier.id);
              Navigator.pop(ctx);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddExercice(BuildContext context, Atelier atelier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciceFormPage(
          atelierId: atelier.id,
          exerciceState: _exerciceState,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showEditExercice(BuildContext context, Exercice exercice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciceFormPage(
          atelierId: exercice.atelierId,
          exercice: exercice,
          exerciceState: _exerciceState,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _naviguerVersAnnotation(Atelier atelier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnnotationPage(
          atelier: atelier,
          seance: widget.seance,
          annotationState: _annotationState,
        ),
      ),
    );
  }

  void _confirmApplyAtelier(BuildContext context, Atelier atelier) {
    if (!_hasApplyAtelierPermission || !widget.seance.estOuverte) return;

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.applyWorkshopTitle,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.applyWorkshopConfirmation(atelier.nom),
          style: GoogleFonts.montserrat(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancelAction,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _atelierState.appliquerAtelier(atelier.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              l10n.confirmButton,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmApplyExercice(BuildContext context, Exercice exercice) {
    if (!_hasApplyExercicePermission || !widget.seance.estOuverte) return;

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.applyExerciseTitle,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.applyExerciseConfirmation(exercice.nom),
          style: GoogleFonts.montserrat(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancelAction,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _exerciceState.appliquerExercice(exercice.id, exercice.atelierId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              l10n.confirmButton,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCloseExercice(BuildContext context, Exercice exercice) {
    if (!_hasCloseExercicePermission || !widget.seance.estOuverte) return;

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.closeExerciseTitle,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.closeExerciseConfirmation(exercice.nom),
          style: GoogleFonts.montserrat(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancelAction,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final isAtelierClosed = await _exerciceState.fermerExercice(
                exercice.id,
                exercice.atelierId,
                exercice.nom,
              );
              if (isAtelierClosed) {
                // Si l'atelier a été fermé, on rafraîchit l'état des ateliers
                await _atelierState.chargerAteliers(widget.seance.id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              l10n.confirmButton,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
