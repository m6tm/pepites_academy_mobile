import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/annotation.dart';
import '../../../../domain/entities/atelier.dart';
import '../../../../domain/entities/seance.dart';
import '../../../state/annotation_state.dart';
import '../../../theme/app_colors.dart';

/// Tags d'observations rapides categorises.
class _TagCategory {
  final String label;
  final List<String> tags;
  final Color color;

  const _TagCategory({
    required this.label,
    required this.tags,
    required this.color,
  });
}

/// Volet lateral (bottom sheet) pour annoter un academicien.
/// Affiche les tags rapides, un champ de texte libre,
/// une note optionnelle et l'historique des annotations precedentes.
class AnnotationSidePanel extends StatefulWidget {
  final Academicien academicien;
  final Atelier atelier;
  final Seance seance;
  final AnnotationState annotationState;
  final String encadreurId;

  const AnnotationSidePanel({
    super.key,
    required this.academicien,
    required this.atelier,
    required this.seance,
    required this.annotationState,
    required this.encadreurId,
  });

  @override
  State<AnnotationSidePanel> createState() => _AnnotationSidePanelState();
}

class _AnnotationSidePanelState extends State<AnnotationSidePanel> {
  final TextEditingController _contenuController = TextEditingController();
  final List<String> _tagsSelectionnes = [];
  double? _note;
  bool _isSaving = false;

  static const List<_TagCategory> _categories = [
    _TagCategory(
      label: 'Positif',
      tags: ['Excellent', 'En progres', 'Bonne attitude', 'Creatif'],
      color: AppColors.success,
    ),
    _TagCategory(
      label: 'A travailler',
      tags: ['A travailler', 'Insuffisant', 'Manque d\'effort', 'Distrait'],
      color: AppColors.error,
    ),
    _TagCategory(
      label: 'Technique',
      tags: ['Dribble', 'Passe', 'Tir', 'Placement', 'Endurance'],
      color: Color(0xFF3498DB),
    ),
  ];

  @override
  void initState() {
    super.initState();
    widget.annotationState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.annotationState.removeListener(_onStateChanged);
    _contenuController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tagsSelectionnes.contains(tag)) {
        _tagsSelectionnes.remove(tag);
      } else {
        _tagsSelectionnes.add(tag);
      }
    });
  }

  Future<void> _enregistrerAutomatiquement() async {
    final contenu = _contenuController.text.trim();
    if (_tagsSelectionnes.isEmpty && contenu.isEmpty) return;

    setState(() => _isSaving = true);

    await widget.annotationState.creerAnnotation(
      contenu: contenu,
      tags: List<String>.from(_tagsSelectionnes),
      note: _note,
      encadreurId: widget.encadreurId,
    );

    if (mounted) {
      setState(() {
        _contenuController.clear();
        _tagsSelectionnes.clear();
        _note = null;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(isDark),
          _buildHeader(isDark),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTagsSection(isDark),
                const SizedBox(height: 16),
                _buildObservationField(isDark),
                const SizedBox(height: 16),
                _buildNoteSection(isDark),
                const SizedBox(height: 8),
                _buildEnregistrerButton(isDark),
                const SizedBox(height: 24),
                _buildHistoriqueSection(isDark),
                const SizedBox(height: 24),
              ],
            ),
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
          _buildAvatarSmall(),
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

  Widget _buildAvatarSmall() {
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

  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags rapides',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 12),
        ..._categories.map((cat) => _buildTagCategoryRow(cat, isDark)),
      ],
    );
  }

  Widget _buildTagCategoryRow(_TagCategory category, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: category.color,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: category.tags.map((tag) {
              final isSelected = _tagsSelectionnes.contains(tag);
              return GestureDetector(
                onTap: () => _toggleTag(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withValues(alpha: 0.2)
                        : isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? category.color
                          : isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? category.color
                          : isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observation detaillee',
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
            controller: _contenuController,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Bonne lecture du jeu, manque d\'appui...',
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

  Widget _buildNoteSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Note (optionnel)',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
            const Spacer(),
            if (_note != null)
              Text(
                '${_note!.toStringAsFixed(0)}/10',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.15),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: _note ?? 5,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) {
              setState(() => _note = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnregistrerButton(bool isDark) {
    final hasContent =
        _tagsSelectionnes.isNotEmpty ||
        _contenuController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: hasContent && !_isSaving
            ? _enregistrerAutomatiquement
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
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
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(
          _isSaving ? 'Enregistrement...' : 'Enregistrer l\'annotation',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoriqueSection(bool isDark) {
    final historique = widget.annotationState.historiqueAcademicien;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 18,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
            const SizedBox(width: 8),
            Text(
              'Historique (${historique.length})',
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
          ...historique.map((a) => _buildHistoriqueItem(a, isDark)),
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
          'Aucune annotation precedente',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoriqueItem(Annotation annotation, bool isDark) {
    final date = _formatDate(annotation.horodate);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              const Spacer(),
              if (annotation.note != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${annotation.note!.toStringAsFixed(0)}/10',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (annotation.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: annotation.tags.map((tag) {
                final color = _getTagColor(tag);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (annotation.contenu.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              annotation.contenu,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTagColor(String tag) {
    for (final category in _categories) {
      if (category.tags.contains(tag)) {
        return category.color;
      }
    }
    return AppColors.primary;
  }

  String _formatDate(DateTime date) {
    const mois = [
      'Jan',
      'Fev',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aout',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final heure =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
    return '${date.day} ${mois[date.month - 1]} ${date.year} a $heure';
  }
}
