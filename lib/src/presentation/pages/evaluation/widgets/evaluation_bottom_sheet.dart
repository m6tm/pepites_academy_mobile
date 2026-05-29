import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/atelier.dart';
import '../../../../domain/entities/evaluation.dart';
import '../../../../domain/entities/referentiel_evaluation_data.dart';
import '../../../../domain/entities/seance.dart';
import '../../../state/evaluation_state.dart';
import '../../../theme/app_colors.dart';
import '../../annotation/widgets/annotation_rating_colors.dart';

/// Bottom sheet d'evaluation multicritere pour un academicien.
/// Presente les 5 criteres avec les 2 elements selectionnes dans la configuration
/// de l'atelier, et permet de noter chaque element sur 5.
class EvaluationBottomSheet extends StatefulWidget {
  final Academicien academicien;
  final Atelier atelier;
  final Seance seance;
  final EvaluationState evaluationState;
  final String encadreurId;

  const EvaluationBottomSheet({
    super.key,
    required this.academicien,
    required this.atelier,
    required this.seance,
    required this.evaluationState,
    required this.encadreurId,
  });

  @override
  State<EvaluationBottomSheet> createState() => _EvaluationBottomSheetState();
}

class _EvaluationBottomSheetState extends State<EvaluationBottomSheet> {
  final TextEditingController _commentaireController = TextEditingController();
  bool _isSaving = false;
  bool _showRecapitulatif = false;

  List<ConfigurationElementEvaluation> get _configuration =>
      widget.atelier.configurationEvaluation ?? [];

  @override
  void initState() {
    super.initState();
    widget.evaluationState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.evaluationState.removeListener(_onStateChanged);
    _commentaireController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _enregistrer() async {
    setState(() => _isSaving = true);

    final succes = await widget.evaluationState.creerEvaluation(
      encadreurId: widget.encadreurId,
      configuration: _configuration,
      commentaire: _commentaireController.text.trim().isEmpty
          ? null
          : _commentaireController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (succes && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

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
                  widget.atelier.nom,
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
    final scoreTotal = widget.evaluationState.getScoreTotalEnCours(_configuration);
    final tousNotes = widget.evaluationState.tousLesElementsNotes(_configuration);

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildScoreTotalEnTete(scoreTotal, isDark),
              const SizedBox(height: 16),
              ..._configuration.map((config) =>
                  _buildCritereSection(config, isDark)),
              const SizedBox(height: 16),
              _buildCommentaireSection(isDark),
              const SizedBox(height: 16),
              _buildHistoriqueSection(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
        _buildBarreActions(tousNotes, isDark),
      ],
    );
  }

  Widget _buildScoreTotalEnTete(double scoreTotal, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Score total',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          RatingBar(
            note: scoreTotal,
            maxNote: 50,
            width: 100,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCritereSection(
    ConfigurationElementEvaluation config,
    bool isDark,
  ) {
    final critere = ReferentielEvaluationData.criteres
        .where((c) => c.id == config.critereId)
        .firstOrNull;
    if (critere == null) return const SizedBox.shrink();

    final element1 = critere.elements
        .where((e) => e.id == config.element1Id)
        .firstOrNull;
    final element2 = critere.elements
        .where((e) => e.id == config.element2Id)
        .firstOrNull;

    if (element1 == null || element2 == null) return const SizedBox.shrink();

    final sousTotal = widget.evaluationState.getSousTotalCritere(
      config.critereId,
      config.element1Id,
      config.element2Id,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  critere.nom,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
              ),
              RatingBar(
                note: sousTotal,
                maxNote: 10,
                width: 60,
                height: 6,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildElementSlider(
            config.critereId,
            element1.id,
            element1.libelle,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildElementSlider(
            config.critereId,
            element2.id,
            element2.libelle,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildElementSlider(
    String critereId,
    String elementId,
    String libelle,
    bool isDark,
  ) {
    final note = widget.evaluationState.getNoteEnCours(critereId, elementId);
    final sliderColor = getRatingColor(note);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                libelle,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
            RatingIndicator(note: note, size: 22),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: sliderColor,
            inactiveTrackColor: sliderColor.withValues(alpha: 0.15),
            thumbColor: sliderColor,
            overlayColor: sliderColor.withValues(alpha: 0.1),
            trackHeight: 3,
          ),
          child: Slider(
            value: note,
            min: 0,
            max: 5,
            divisions: 10,
            onChanged: (value) {
              widget.evaluationState.mettreAJourNote(
                critereId,
                elementId,
                value,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentaireSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commentaire (optionnel)',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: TextField(
            controller: _commentaireController,
            maxLines: 3,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
            decoration: InputDecoration(
              hintText:
                  'Observations qualitatives sur la seance...',
              hintStyle: GoogleFonts.montserrat(
                fontSize: 13,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoriqueSection(bool isDark) {
    final historique = widget.evaluationState.historiqueAcademicien;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 18,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
            const SizedBox(width: 8),
            Text(
              historique.isEmpty
                  ? 'Aucune evaluation precedente'
                  : '${historique.length} evaluation(s) precedente(s)',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (historique.isEmpty)
          _buildEmptyHistorique(isDark)
        else
          ...historique.take(3).map((e) => _buildHistoriqueItem(e, isDark)),
      ],
    );
  }

  Widget _buildEmptyHistorique(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Premiere evaluation pour cet academicien',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoriqueItem(Evaluation evaluation, bool isDark) {
    final date = _formatDate(evaluation.horodate);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 14,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              date,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ),
          RatingBar(
            note: evaluation.scoreTotal.toDouble(),
            maxNote: 50,
            width: 60,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildBarreActions(bool tousNotes, bool isDark) {
    final errorMessage = widget.evaluationState.errorMessage;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                errorMessage,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
          if (!tousNotes && !_showRecapitulatif) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Veuillez noter tous les elements avant de continuer.',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
          Row(
            children: [
              if (_showRecapitulatif)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _showRecapitulatif = false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Modifier',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              if (_showRecapitulatif) const SizedBox(width: 12),
              Expanded(
                flex: _showRecapitulatif ? 2 : 1,
                child: ElevatedButton.icon(
                  onPressed: tousNotes && !_isSaving
                      ? (_showRecapitulatif
                          ? _enregistrer
                          : () => setState(() => _showRecapitulatif = true))
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.3),
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _showRecapitulatif
                              ? Icons.save_rounded
                              : Icons.preview_rounded,
                          size: 20,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Enregistrement...'
                        : _showRecapitulatif
                            ? 'Confirmer'
                            : 'Recapitulatif',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecapitulatif(bool isDark) {
    final scoreTotal =
        widget.evaluationState.getScoreTotalEnCours(_configuration);

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
                'Recapitulatif de l\'evaluation',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
              const SizedBox(height: 8),
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
        ..._configuration.map((config) =>
            _buildRecapCritere(config, isDark)),
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

  Widget _buildRecapCritere(
    ConfigurationElementEvaluation config,
    bool isDark,
  ) {
    final critere = ReferentielEvaluationData.criteres
        .where((c) => c.id == config.critereId)
        .firstOrNull;
    if (critere == null) return const SizedBox.shrink();

    final element1 = critere.elements
        .where((e) => e.id == config.element1Id)
        .firstOrNull;
    final element2 = critere.elements
        .where((e) => e.id == config.element2Id)
        .firstOrNull;

    if (element1 == null || element2 == null) return const SizedBox.shrink();

    final note1 = widget.evaluationState
        .getNoteEnCours(config.critereId, config.element1Id);
    final note2 = widget.evaluationState
        .getNoteEnCours(config.critereId, config.element2Id);
    final sousTotal = note1 + note2;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  critere.nom,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildNoteLine(element1.libelle, note1),
                    const SizedBox(width: 12),
                    _buildNoteLine(element2.libelle, note2),
                  ],
                ),
              ],
            ),
          ),
          RatingBar(
            note: sousTotal,
            maxNote: 10,
            width: 50,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteLine(String libelle, double note) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          libelle,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        RatingIndicator(note: note, size: 16),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = intl.DateFormat('d MMM yyyy', locale).format(date);
    final heure = intl.DateFormat('HH:mm', locale).format(date);
    return '$dateStr - $heure';
  }
}
