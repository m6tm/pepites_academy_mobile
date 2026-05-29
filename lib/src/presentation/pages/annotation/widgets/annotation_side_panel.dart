import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/annotation.dart';
import '../../../../domain/entities/atelier.dart';
import '../../../../domain/entities/exercice.dart';
import '../../../../domain/entities/seance.dart';
import '../../../state/annotation_state.dart';
import '../../../theme/app_colors.dart';
import 'annotation_action_bar.dart';
import 'annotation_comment_field.dart';
import 'annotation_element_rating.dart';
import 'annotation_rating_colors.dart';
import 'annotation_recap_item.dart';

class AnnotationSidePanel extends StatefulWidget {
  final Academicien academicien;
  final Atelier atelier;
  final Exercice? exercice;
  final Seance seance;
  final AnnotationState annotationState;
  final String encadreurId;

  const AnnotationSidePanel({
    super.key,
    required this.academicien,
    required this.atelier,
    this.exercice,
    required this.seance,
    required this.annotationState,
    required this.encadreurId,
  });

  @override
  State<AnnotationSidePanel> createState() => _AnnotationSidePanelState();
}

class _AnnotationSidePanelState extends State<AnnotationSidePanel> {
  final TextEditingController _commentaireController = TextEditingController();
  final Map<String, double> _notesEnCours = {};
  bool _isSaving = false;
  bool _showRecapitulatif = false;
  bool _modeEdition = false;
  String? _annotationExistanteId;

  List<ConfigurationElementEvaluation> get _configuration =>
      widget.atelier.configurationEvaluation ?? [];

  @override
  void initState() {
    super.initState();
    widget.annotationState.addListener(_onStateChanged);
    _initNotes();
  }

  void _initNotes() {
    for (final config in _configuration) {
      _notesEnCours['${config.critereId}_${config.element1Id}'] = 0.0;
      _notesEnCours['${config.critereId}_${config.element2Id}'] = 0.0;
    }

    final existante = widget.annotationState.annotationPourExerciceActuel;
    if (existante != null) {
      _modeEdition = true;
      _annotationExistanteId = existante.id;
      for (final score in existante.scores) {
        _notesEnCours['${score.critereId}_${score.element1Id}'] =
            score.noteElement1;
        _notesEnCours['${score.critereId}_${score.element2Id}'] =
            score.noteElement2;
      }
      if (existante.commentaire != null && existante.commentaire!.isNotEmpty) {
        _commentaireController.text = existante.commentaire!;
      }
    }
  }

  @override
  void dispose() {
    widget.annotationState.removeListener(_onStateChanged);
    _commentaireController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  double _getNote(String critereId, String elementId) {
    return _notesEnCours['${critereId}_$elementId'] ?? 0.0;
  }

  void _setNote(String critereId, String elementId, double note) {
    setState(() {
      _notesEnCours['${critereId}_$elementId'] = note;
    });
  }

  double _getScoreTotal() {
    double total = 0;
    for (final config in _configuration) {
      final note1 = _getNote(config.critereId, config.element1Id);
      final note2 = _getNote(config.critereId, config.element2Id);
      total += note1 + note2;
    }
    return total;
  }

  bool _tousLesElementsNotes() {
    for (final config in _configuration) {
      if (_getNote(config.critereId, config.element1Id) == 0) return false;
      if (_getNote(config.critereId, config.element2Id) == 0) return false;
    }
    return true;
  }

  Future<void> _enregistrer() async {
    setState(() => _isSaving = true);

    final scores = _configuration.map((config) {
      return ScoreAnnotation(
        critereId: config.critereId,
        element1Id: config.element1Id,
        noteElement1: _getNote(config.critereId, config.element1Id),
        element2Id: config.element2Id,
        noteElement2: _getNote(config.critereId, config.element2Id),
      );
    }).toList();

    final commentaire = _commentaireController.text.trim().isEmpty
        ? null
        : _commentaireController.text.trim();

    final bool succes;
    if (_modeEdition && _annotationExistanteId != null) {
      succes = await widget.annotationState.modifierAnnotation(
        annotationId: _annotationExistanteId!,
        scores: scores,
        commentaire: commentaire,
      );
    } else {
      succes = await widget.annotationState.creerAnnotation(
        scores: scores,
        commentaire: commentaire,
        encadreurId: widget.encadreurId,
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (succes && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else if (!succes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.annotationState.errorMessage ?? 'Erreur lors de l\'enregistrement'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final isApplique = widget.exercice != null
        ? widget.exercice!.statut == ExerciceStatut.applique
        : widget.atelier.statut == AtelierStatut.applique;

    return Container(
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(isDark),
          _buildHeader(isDark),
          Expanded(
            child: _showRecapitulatif
                ? _buildRecapitulatif(isDark)
                : _buildFormulaire(isDark),
          ),
          AnnotationActionBar(
            tousNotes: _tousLesElementsNotes(),
            isSaving: _isSaving,
            isApplique: isApplique,
            showRecapitulatif: _showRecapitulatif,
            errorMessage: widget.annotationState.errorMessage,
            onEnregistrer: _enregistrer,
            onAfficherRecap: () => setState(() => _showRecapitulatif = true),
            onModifier: () => setState(() => _showRecapitulatif = false),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.academicien.prenom} ${widget.academicien.nom}',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  widget.exercice != null
                      ? '${widget.atelier.nom} > ${widget.exercice!.nom}'
                      : widget.atelier.nom,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: widget.academicien.photoUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                widget.academicien.photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(),
              ),
            )
          : _buildAvatarFallback(),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        '${widget.academicien.prenom.isNotEmpty ? widget.academicien.prenom[0] : ''}'
        '${widget.academicien.nom.isNotEmpty ? widget.academicien.nom[0] : ''}',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildFormulaire(bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        AnnotationScoreHeader(
          scoreTotal: _getScoreTotal(),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        ..._configuration.map(
            (config) => AnnotationElementRating(
                  config: config,
                  getNote: _getNote,
                  setNote: _setNote,
                  isDark: isDark,
                )),
        const SizedBox(height: 16),
        AnnotationCommentField(
          controller: _commentaireController,
          isDark: isDark,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecapitulatif(bool isDark) {
    final scoreTotal = _getScoreTotal();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Recapitulatif de l\'annotation',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
              const SizedBox(height: 12),
              RatingBar(
                note: scoreTotal,
                maxNote: 50,
                width: 140,
                height: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._configuration.map(
            (config) => AnnotationRecapItem(
                  config: config,
                  getNote: _getNote,
                  isDark: isDark,
                )),
        if (_commentaireController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commentaire',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _commentaireController.text.trim(),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}