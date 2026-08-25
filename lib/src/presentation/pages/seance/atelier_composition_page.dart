import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/atelier.dart';
import '../../../domain/entities/seance.dart';
import '../../../domain/entities/permission.dart';
import '../../../infrastructure/network/api_endpoints.dart';
import '../../../injection_container.dart';
import '../../state/atelier_state.dart';
import '../../state/exercice_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';
import '../../widgets/atelier_card.dart';
import '../../widgets/icon_selector.dart';
import '../ateliers/atelier_form_page.dart';
import '../../../../l10n/app_localizations.dart';

/// Ecran de composition des ateliers rattache a une seance.
/// Permet d'ajouter, modifier, supprimer et reorganiser les ateliers
/// par glisser-deposer.
class AtelierCompositionPage extends StatefulWidget {
  final Seance seance;
  final AtelierState atelierState;
  final ExerciceState exerciceState;

  const AtelierCompositionPage({
    super.key,
    required this.seance,
    required this.atelierState,
    required this.exerciceState,
  });

  @override
  State<AtelierCompositionPage> createState() => _AtelierCompositionPageState();
}

class _AtelierCompositionPageState extends State<AtelierCompositionPage> {
  bool _hasCreateAtelierPermission = false;
  bool _hasUpdateAtelierPermission = false;
  bool _hasDeleteAtelierPermission = false;
  bool _hasApplyAtelierPermission = false;

  bool get _isSeanceFermee => widget.seance.estFermee;

  @override
  void initState() {
    super.initState();
    widget.atelierState.addListener(_onStateChanged);
    _loadAteliers();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final roleService = DependencyInjection.roleService;
    if (mounted) {
      setState(() {
        _hasCreateAtelierPermission = roleService.hasPermission(Permission.atelierCreate);
        _hasUpdateAtelierPermission = roleService.hasPermission(Permission.atelierUpdate);
        _hasDeleteAtelierPermission = roleService.hasPermission(Permission.atelierDelete);
        _hasApplyAtelierPermission = roleService.hasPermission(Permission.atelierApply);
      });
    }
  }

  /// Charge les ateliers depuis le cache local d'abord, puis rafraichit depuis l'API en arriere-plan.
  Future<void> _loadAteliers() async {
    // Afficher immediatement les donnees du cache local
    await widget.atelierState.chargerAteliers(widget.seance.id);

    // Rafraichir depuis l'API en arriere-plan
    _refreshFromApiIfOnline().then((_) {
      // Recharger depuis le cache mis a jour
      if (mounted) {
        widget.atelierState.chargerAteliers(widget.seance.id);
      }
    });
  }

  /// Si connecte, recupere les ateliers de la seance depuis l'API
  /// et met a jour le cache local.
  Future<void> _refreshFromApiIfOnline() async {
    if (!DependencyInjection.connectivityState.isConnected) return;
    try {
      final data = await DependencyInjection.apiSyncDatasource.fetchAll(
        '${ApiEndpoints.ateliers}?seance_id=${widget.seance.id}',
      );
      if (data == null || data.isEmpty) return;

      final remoteList = data
          .map(_atelierFromApiJson)
          .whereType<Atelier>()
          .toList();

      if (remoteList.isNotEmpty) {
        await DependencyInjection.atelierRepository.upsertAllFromRemote(
          remoteList,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AtelierCompositionPage] Erreur refresh API: $e');
    }
  }

  /// Convertit un JSON API en entite Atelier.
  Atelier? _atelierFromApiJson(Map<String, dynamic> json) {
    try {
      return Atelier(
        id: json['id'] as String,
        nom: json['nom'] as String? ?? '',
        icone: json['icone'] as String? ?? json['icon'] as String?,
        ordre: json['ordre'] as int? ?? 0,
        statut: AtelierStatut.cree,
        seanceId: (json['seance_id'] ?? json['seanceId']) as String,
      );
    } catch (_) {
      return null;
    }
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
      AcademyToast.show(context, title: state.successMessage!, isSuccess: true);
      state.clearMessages();
    } else if (state.errorMessage != null) {
      AcademyToast.show(context, title: state.errorMessage!, isError: true);
      state.clearMessages();
    }
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
            _buildAtelierList(colorScheme, isDark, widget.exerciceState),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: (!_isSeanceFermee && _hasCreateAtelierPermission)
          ? FloatingActionButton.extended(
              onPressed: () => _showAjouterAtelierDialog(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                AppLocalizations.of(context)!.addAction,
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
          AppLocalizations.of(context)!.workshopCompositionTitle,
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
                  AppLocalizations.of(
                    context,
                  )!.workshopProgrammed(state.ateliers.length),
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
              widget.seance.estOuverte
                  ? AppLocalizations.of(context)!.sessionStatusOpen
                  : AppLocalizations.of(context)!.sessionStatusClosed,
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
              AppLocalizations.of(context)!.noWorkshopProgrammed,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.workshopCompositionSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            if (!_isSeanceFermee) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => _showAjouterAtelierDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  AppLocalizations.of(context)!.addWorkshop,
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

  Widget _buildAtelierList(ColorScheme colorScheme, bool isDark, ExerciceState exerciceState) {
    final state = widget.atelierState;
    final isEditable = !_isSeanceFermee && _hasUpdateAtelierPermission;
    final isOpen = widget.seance.estOuverte;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverReorderableList(
        itemBuilder: (context, index) {
          final atelier = state.ateliers[index];
          final exercices = exerciceState.exercicesParAtelier[atelier.id] ?? [];
          return ReorderableDragStartListener(
            key: ValueKey(atelier.id),
            index: index,
            child: AtelierCard(
              index: index,
              atelier: atelier,
              exercices: exercices,
              isEditable: isEditable,
              onEdit: isEditable ? () => _showModifierAtelierDialog(context, atelier) : null,
              onDelete: (!_isSeanceFermee && _hasDeleteAtelierPermission)
                  ? () => _confirmerSuppression(context, atelier)
                  : null,
              isApplying: state.isProcessingAtelier(atelier.id),
              onApply: (isOpen && _hasApplyAtelierPermission)
                  ? () => _confirmApplyAtelier(context, atelier)
                  : null,
            ),
          );
        },
        itemCount: state.ateliers.length,
        onReorderItem: isEditable
            ? (oldIndex, newIndex) {
                state.reordonnerAteliers(oldIndex, newIndex);
              }
            : (oldIndex, newIndex) {},

      ),
    );
  }

  void _showAjouterAtelierDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AtelierFormSheet(
        atelier: null,
        onSubmit: (nom, icone) {
          widget.atelierState.ajouterAtelier(
            seanceId: widget.seance.id,
            nom: nom,
            icone: icone,
          );
        },
      ),
    );
  }

  void _showModifierAtelierDialog(BuildContext context, Atelier atelier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AtelierFormPage(
          seanceId: widget.seance.id,
          atelier: atelier,
          atelierState: widget.atelierState,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _confirmerSuppression(BuildContext context, Atelier atelier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.deleteWorkshopTitle,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteWorkshopConfirmation(atelier.nom),
          style: GoogleFonts.montserrat(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancelAction,
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
              AppLocalizations.of(context)!.deleteAction,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmApplyAtelier(BuildContext context, Atelier atelier) {
    if (!_hasApplyAtelierPermission || !widget.seance.estOuverte) return;

    final l10n = AppLocalizations.of(context)!;
    bool isApplying = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
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
              onPressed: isApplying ? null : () => Navigator.pop(ctx),
              child: Text(
                l10n.cancelAction,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: isApplying
                  ? null
                  : () async {
                      setState(() => isApplying = true);
                      final success = await widget.atelierState.appliquerAtelier(atelier.id);
                      if (success) {
                        await widget.exerciceState.chargerExercices(atelier.id);
                      }
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(widget.atelierState.errorMessage ?? 'Erreur lors de l\'application'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isApplying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.confirmButton,
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

}


/// Bottom sheet pour ajouter un atelier.
class _AtelierFormSheet extends StatefulWidget {
  final Atelier? atelier;
  final void Function(String nom, String? icone) onSubmit;

  const _AtelierFormSheet({this.atelier, required this.onSubmit});

  @override
  State<_AtelierFormSheet> createState() => _AtelierFormSheetState();
}

class _AtelierFormSheetState extends State<_AtelierFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late String _selectedIcon;
  bool _isCustomName = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: '');
    _selectedIcon = AtelierIconeMapper.icons.first['value'] as String;
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  void _onIconSelected(String? icon) {
    if (icon == null) return;
    setState(() {
      _selectedIcon = icon;
      if (!_isCustomName) {
        _nomController.text = AtelierIconeMapper.getLabel(icon);
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
                isEditing
                    ? AppLocalizations.of(context)!.editWorkshopTitle
                    : AppLocalizations.of(context)!.addWorkshopTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.selectExerciseType,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 20),
              IconSelector(
                selectedIcon: _selectedIcon,
                onIconSelected: _onIconSelected,
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.workshopNameLabel,
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
                  hintText: AppLocalizations.of(context)!.workshopNameHint,
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
                    return AppLocalizations.of(context)!.workshopNameRequired;
                  }
                  return null;
                },
                onChanged: (_) {
                  _isCustomName = true;
                },
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
                    isEditing
                        ? AppLocalizations.of(context)!.editAction
                        : AppLocalizations.of(context)!.saveWorkshop,
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _nomController.text.trim(),
        _selectedIcon,
      );
      Navigator.of(context).pop();
    }
  }
}
