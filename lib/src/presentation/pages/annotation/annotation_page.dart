import 'package:flutter/material.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/atelier.dart';
import '../../../domain/entities/seance.dart';
import '../../../injection_container.dart';
import '../../state/annotation_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';
import 'widgets/academicien_annotation_tile.dart';
import 'widgets/annotation_side_panel.dart';

/// Page d'annotations et observations pour un atelier.
/// Affiche la liste des academiciens presents et permet
/// d'ouvrir un volet lateral pour annoter chaque academicien.
class AnnotationPage extends StatefulWidget {
  final Atelier atelier;
  final Seance seance;
  final AnnotationState annotationState;

  const AnnotationPage({
    super.key,
    required this.atelier,
    required this.seance,
    required this.annotationState,
  });

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  List<Academicien> _academiciens = [];
  bool _isLoadingAcademiciens = false;

  Atelier get atelier => widget.atelier;
  Seance get seance => widget.seance;
  AnnotationState get annotationState => widget.annotationState;

  @override
  void initState() {
    super.initState();
    annotationState.addListener(_onStateChanged);
    _initialiser();
  }

  @override
  void dispose() {
    annotationState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});

    if (annotationState.successMessage != null) {
      AcademyToast.show(
        context,
        title: annotationState.successMessage!,
        isSuccess: true,
      );
      annotationState.clearMessages();
    } else if (annotationState.errorMessage != null) {
      AcademyToast.show(
        context,
        title: annotationState.errorMessage!,
        isError: true,
      );
      annotationState.clearMessages();
    }
  }

  Future<void> _initialiser() async {
    await annotationState.initialiserContexte(
      atelierId: atelier.id,
      seanceId: seance.id,
    );
    await _chargerAcademiciens();
  }

  Future<void> _chargerAcademiciens() async {
    setState(() => _isLoadingAcademiciens = true);
    try {
      final tous = await DependencyInjection.academicienRepository.getAll();
      final presents = tous
          .where((a) => seance.academicienIds.contains(a.id))
          .toList();
      if (mounted) {
        setState(() {
          _academiciens = presents;
          _isLoadingAcademiciens = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAcademiciens = false);
    }
  }

  void _ouvrirVoletAnnotation(Academicien academicien) {
    annotationState.selectionnerAcademicien(academicien.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AnnotationSidePanel(
        academicien: academicien,
        atelier: atelier,
        seance: seance,
        annotationState: annotationState,
        encadreurId: seance.encadreurResponsableId,
      ),
    ).whenComplete(() {
      annotationState.deselectionnerAcademicien();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildAtelierHeader(isDark)),
          if (_isLoadingAcademiciens || annotationState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_academiciens.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(isDark))
          else
            _buildAcademiciensList(isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
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
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppLocalizations.of(context)!.annotationPageTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 18,
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

  Widget _buildAtelierHeader(bool isDark) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atelier.nom,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      atelier.typeLabel,
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
            ],
          ),
          if (atelier.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              atelier.description,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                Icons.people_rounded,
                AppLocalizations.of(
                  context,
                )!.academiciansCount(_academiciens.length),
                isDark,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.note_alt_rounded,
                AppLocalizations.of(
                  context,
                )!.annotationsCount(annotationState.annotationsAtelier.length),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noAcademicianPresent,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noAcademicianPresentDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademiciensList(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final academicien = _academiciens[index];
          final nbAnnotations = annotationState.nbAnnotationsPourAcademicien(
            academicien.id,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AcademicienAnnotationTile(
              academicien: academicien,
              nbAnnotations: nbAnnotations,
              isDark: isDark,
              onTap: () => _ouvrirVoletAnnotation(academicien),
            ),
          );
        }, childCount: _academiciens.length),
      ),
    );
  }
}
