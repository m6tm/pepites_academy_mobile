import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';
import '../../../core/events/referentiel_events.dart';
import '../../../domain/entities/atelier.dart';
import '../../../domain/entities/categorie_joueur.dart';
import '../../../domain/entities/critere_evaluation.dart';
import '../../state/atelier_state.dart';
import '../../widgets/glass_text_field.dart';
import '../../widgets/icon_selector.dart';
import '../../widgets/duration_picker_field.dart';
import '../../widgets/evaluation_configuration_selector.dart';

import '../../../injection_container.dart';
import '../../../domain/entities/permission.dart';
import '../../widgets/academy_toast.dart';

class AtelierFormPage extends StatefulWidget {
  final String seanceId;
  final Atelier? atelier;
  final AtelierState atelierState;
  final bool syncSeanceIdWithState;

  const AtelierFormPage({
    super.key,
    required this.seanceId,
    this.atelier,
    required this.atelierState,
    this.syncSeanceIdWithState = false,
  });

  @override
  State<AtelierFormPage> createState() => _AtelierFormPageState();
}

class _AtelierFormPageState extends State<AtelierFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _themeController;
  late final TextEditingController _objectifsController;
  String? _selectedIcon;
  int? _dureeMinutes;
  bool _isSubmitting = false;
  List<CritereEvaluation> _criteres = [];
  List<ConfigurationElementEvaluation> _configurationEvaluation = [];
  List<CategorieJoueur> _categories = [];
  final Set<String> _selectedCategorieIds = {};
  StreamSubscription<ReferentielUpdatedEvent>? _referentielSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _nomController = TextEditingController(text: widget.atelier?.nom ?? '');
    _themeController = TextEditingController(
      text: widget.atelier?.theme ?? '',
    );
    _objectifsController = TextEditingController(
      text: widget.atelier?.objectifs ?? '',
    );
    _selectedIcon = widget.atelier?.icone ?? AtelierIconeMapper.icons.first['value'] as String;
    _dureeMinutes = widget.atelier?.dureeMinutes;
    _selectedCategorieIds.addAll(widget.atelier?.categorieIds ?? const []);
    _configurationEvaluation =
        widget.atelier?.configurationEvaluation?.toList() ?? [];
    _chargerCriteres();
    _chargerCategories();

    // Recharge les categories si le referentiel est modifie ailleurs.
    _referentielSubscription = DependencyInjection.domainEventBus
        .on<ReferentielUpdatedEvent>()
        .listen((_) => _chargerCategories());

    if (widget.syncSeanceIdWithState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.atelierState.chargerAteliers(widget.seanceId);
      });
    }
  }

  Future<void> _chargerCriteres() async {
    final criteres = await DependencyInjection
        .evaluationReferentielRepository.getAllCriteres();
    if (mounted) {
      setState(() => _criteres = criteres);
    }
  }

  Future<void> _chargerCategories() async {
    try {
      final categories = await DependencyInjection.referentielService
          .getAllCategories();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } catch (_) {
      // Hors-ligne ou referentiel indisponible : la liste reste vide.
    }
  }

  Future<void> _checkPermissions() async {
    final role = await DependencyInjection.roleService.getCurrentUserRole();
    final requiredPermission = widget.atelier == null
        ? Permission.atelierCreate
        : Permission.atelierUpdate;

    if (!role.hasPermission(requiredPermission)) {
      if (mounted) {
        AcademyToast.show(
          context,
          title: 'Permission insuffisante',
          isError: true,
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _referentielSubscription?.cancel();
    _nomController.dispose();
    _themeController.dispose();
    _objectifsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_criteres.isNotEmpty && _configurationEvaluation.length != 5) {
      AcademyToast.show(
        context,
        title: 'Veuillez selectionner au moins 1 element par critere d\'evaluation',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    bool success;
    if (widget.atelier == null) {
      success = await widget.atelierState.ajouterAtelier(
        seanceId: widget.seanceId,
        nom: _nomController.text.trim(),
        theme: _themeController.text.trim(),
        objectifs: _objectifsController.text.trim(),
        dureeMinutes: _dureeMinutes,
        categorieIds: _selectedCategorieIds.toList(),
        icone: _selectedIcon,
        configurationEvaluation: _configurationEvaluation.isNotEmpty
            ? _configurationEvaluation
            : null,
      );
    } else {
      success = await widget.atelierState.modifierAtelier(
        widget.atelier!.copyWith(
          nom: _nomController.text.trim(),
          theme: _themeController.text.trim(),
          objectifs: _objectifsController.text.trim(),
          dureeMinutes: _dureeMinutes,
          clearDureeMinutes: _dureeMinutes == null,
          categorieIds: _selectedCategorieIds.toList(),
          icone: _selectedIcon,
          configurationEvaluation: _configurationEvaluation.isNotEmpty
              ? _configurationEvaluation
              : null,
          statut: AtelierStatut.valide,
        ),
      );
    }

    if (mounted && success) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() => _isSubmitting = false);
      AcademyToast.show(
        context,
        title: widget.atelier == null
            ? 'Erreur lors de la creation'
            : 'Erreur lors de la modification',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(textColor),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildHeader(textColor),
                          const SizedBox(height: 32),

                          GlassTextField(
                            label: 'Nom de l\'atelier *',
                            hint: 'Ex: Dribbles entre les plots',
                            controller: _nomController,
                            prefixIcon: Icons.edit_rounded,
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Le nom est obligatoire'
                                : null,
                          ),

                          const SizedBox(height: 24),

                          IconSelector(
                            selectedIcon: _selectedIcon,
                            onIconSelected: (icon) =>
                                setState(() => _selectedIcon = icon),
                          ),

                          const SizedBox(height: 24),

                          GlassTextField(
                            label: 'Thème de l\'atelier',
                            hint: 'Ex: Jeu de transition offensive...',
                            controller: _themeController,
                            prefixIcon: Icons.lightbulb_outline_rounded,
                            maxLines: 3,
                          ),

                          const SizedBox(height: 24),

                          GlassTextField(
                            label: 'Objectifs',
                            hint: 'Objectifs pédagogiques de l\'atelier...',
                            controller: _objectifsController,
                            prefixIcon: Icons.flag_outlined,
                            maxLines: 3,
                          ),

                          const SizedBox(height: 24),

                          DurationPickerField(
                            label: 'Durée',
                            dureeMinutes: _dureeMinutes,
                            onChanged: (minutes) =>
                                setState(() => _dureeMinutes = minutes),
                          ),

                          const SizedBox(height: 24),

                          _buildCategoriesSelector(textColor),

                          if (_criteres.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            EvaluationConfigurationSelector(
                              criteres: _criteres,
                              configurationInitiale:
                                  widget.atelier?.configurationEvaluation,
                              onConfigurationChanged: (config) {
                                _configurationEvaluation = config;
                              },
                            ),
                          ],

                          const SizedBox(height: 40),

                          _buildSubmitButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Selecteur multiple des categories de joueurs (chips).
  Widget _buildCategoriesSelector(Color textColor) {
    final hintColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Catégories de joueurs',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        if (_categories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Aucune catégorie disponible',
              style: TextStyle(color: hintColor, fontSize: 13),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((categorie) {
              final selected = _selectedCategorieIds.contains(categorie.id);
              return FilterChip(
                label: Text(categorie.nom),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedCategorieIds.add(categorie.id);
                    } else {
                      _selectedCategorieIds.remove(categorie.id);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
                labelStyle: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.primary : textColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected
                        ? AppColors.primary
                        : textColor.withValues(alpha: 0.15),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildAppBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: textColor),
          ),
          if (widget.atelier != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'MODIFICATION',
                style: GoogleFonts.montserrat(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.atelier == null ? 'Créer un atelier' : 'Modifier l\'atelier',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'VALIDER L\'ATELIER',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
