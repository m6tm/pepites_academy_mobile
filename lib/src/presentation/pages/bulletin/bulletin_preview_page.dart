import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/bulletin.dart';
import '../../../domain/entities/encadreur.dart';
import '../../state/bulletin_state.dart';
import '../../theme/app_colors.dart';
import 'widgets/competences_radar_widget.dart';

/// Ecran de previsualisation du bulletin de formation.
/// Mise en page type scolaire avec en-tete academie,
/// identite de l'eleve, tableau des appreciations,
/// radar des competences et observations generales.
class BulletinPreviewPage extends StatefulWidget {
  final Bulletin bulletin;
  final Academicien academicien;
  final Encadreur? encadreur;
  final BulletinState bulletinState;

  const BulletinPreviewPage({
    super.key,
    required this.bulletin,
    required this.academicien,
    this.encadreur,
    required this.bulletinState,
  });

  @override
  State<BulletinPreviewPage> createState() => _BulletinPreviewPageState();
}

class _BulletinPreviewPageState extends State<BulletinPreviewPage> {
  final GlobalKey _bulletinKey = GlobalKey();
  final TextEditingController _observationsController = TextEditingController();
  bool _isEditing = false;

  Bulletin get bulletin => widget.bulletinState.bulletinCourant ?? widget.bulletin;
  Academicien get academicien => widget.academicien;

  @override
  void initState() {
    super.initState();
    _observationsController.text = bulletin.observationsGenerales;
    widget.bulletinState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.bulletinState.removeListener(_onStateChanged);
    _observationsController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _exporterImage() async {
    try {
      final boundary = _bulletinKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bulletin capture. Fonctionnalite de partage disponible prochainement.',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'export : $e',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final precedent = widget.bulletinState.getBulletinPrecedent(bulletin);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              key: _bulletinKey,
              child: Container(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                child: Column(
                  children: [
                    _buildEnTete(isDark),
                    _buildIdentiteEleve(isDark),
                    _buildStatistiques(isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CompetencesRadarWidget(
                        competences: bulletin.competences,
                        competencesPrecedentes: precedent?.competences,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTableauAppreciations(isDark),
                    _buildObservationsGenerales(isDark),
                    _buildPiedDePage(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: _exporterImage,
          tooltip: 'Partager',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Bulletin de formation',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnTete(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'PEPITES ACADEMY',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bulletin de Formation Periodique',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              bulletin.periodeLabel,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentiteEleve(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              '${academicien.prenom[0]}${academicien.nom[0]}',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${academicien.prenom} ${academicien.nom}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ne(e) le ${_formatDate(academicien.dateNaissance)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistiques(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            'Presence',
            '${bulletin.tauxPresence.toStringAsFixed(0)}%',
            Icons.check_circle_rounded,
            AppColors.success,
            isDark,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Seances',
            '${bulletin.nbSeancesPresent}/${bulletin.nbSeancesTotal}',
            Icons.calendar_today_rounded,
            AppColors.primary,
            isDark,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Annotations',
            '${bulletin.nbAnnotationsTotal}',
            Icons.edit_note_rounded,
            const Color(0xFF2196F3),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label, String value, IconData icon, Color color, bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableauAppreciations(bool isDark) {
    if (bulletin.appreciations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Aucune appreciation disponible',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Les appreciations seront generees a partir des annotations.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appreciations par domaine',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textMainDark
                  : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 12),
          ...bulletin.appreciations.map(
            (appreciation) => _buildAppreciationRow(appreciation, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildAppreciationRow(AppreciationDomaine appreciation, bool isDark) {
    final noteColor = _noteColor(appreciation.note);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: noteColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                appreciation.note.toStringAsFixed(1),
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: noteColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appreciation.domaine,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                if (appreciation.commentaire.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    appreciation.commentaire,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildNoteBar(appreciation.note, isDark),
        ],
      ),
    );
  }

  Widget _buildNoteBar(double note, bool isDark) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (note / 10).clamp(0, 1),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(_noteColor(note)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '/10',
            style: GoogleFonts.montserrat(
              fontSize: 9,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsGenerales(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Observations generales',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  size: 20,
                ),
                color: AppColors.primary,
                onPressed: _toggleEditing,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            TextField(
              controller: _observationsController,
              maxLines: 5,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
              decoration: InputDecoration(
                hintText: 'Redigez vos observations...',
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
            Text(
              bulletin.observationsGenerales.isNotEmpty
                  ? bulletin.observationsGenerales
                  : 'Aucune observation redigee.',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontStyle: bulletin.observationsGenerales.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
                color: bulletin.observationsGenerales.isEmpty
                    ? (isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight)
                    : (isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight),
              ),
            ),
          if (widget.encadreur != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                const SizedBox(width: 6),
                Text(
                  'Encadreur : ${widget.encadreur!.nomComplet}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPiedDePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 8),
          Text(
            'Genere le ${_formatDate(bulletin.dateGeneration)}',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pepites Academy - Formation Football',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exporterImage,
                icon: const Icon(Icons.image_rounded, size: 18),
                label: Text(
                  'Exporter image',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exporterImage,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(
                  'Partager',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEditing() async {
    if (_isEditing) {
      await widget.bulletinState.mettreAJourObservations(
        _observationsController.text,
      );
    }
    setState(() => _isEditing = !_isEditing);
  }

  Color _noteColor(double note) {
    if (note >= 7) return AppColors.success;
    if (note >= 5) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
