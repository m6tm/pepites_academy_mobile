import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/atelier.dart';
import '../../../domain/entities/seance.dart';
import '../../../injection_container.dart';
import '../../state/evaluation_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';
import 'widgets/academicien_evaluation_tile.dart';
import 'widgets/evaluation_bottom_sheet.dart';

/// Page d'evaluation multicritere pour un atelier.
/// Affiche la liste des academiciens presents et permet
/// d'ouvrir un bottom sheet d'evaluation pour chaque academicien.
class EvaluationPage extends StatefulWidget {
  final Atelier atelier;
  final Seance seance;
  final EvaluationState evaluationState;

  const EvaluationPage({
    super.key,
    required this.atelier,
    required this.seance,
    required this.evaluationState,
  });

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  List<Academicien> _academiciens = [];
  bool _isLoadingAcademiciens = false;

  Atelier get atelier => widget.atelier;
  Seance get seance => widget.seance;
  EvaluationState get evaluationState => widget.evaluationState;

  @override
  void initState() {
    super.initState();
    evaluationState.addListener(_onStateChanged);
    _initialiser();
  }

  @override
  void dispose() {
    evaluationState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});

    if (evaluationState.successMessage != null) {
      AcademyToast.show(
        context,
        title: evaluationState.successMessage!,
        isSuccess: true,
      );
      evaluationState.clearMessages();
    } else if (evaluationState.errorMessage != null) {
      AcademyToast.show(
        context,
        title: evaluationState.errorMessage!,
        isError: true,
      );
      evaluationState.clearMessages();
    }
  }

  Future<void> _initialiser() async {
    await evaluationState.initialiserContexte(
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

  void _ouvrirBottomSheetEvaluation(Academicien academicien) {
    evaluationState.selectionnerAcademicien(academicien.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EvaluationBottomSheet(
        academicien: academicien,
        atelier: atelier,
        seance: seance,
        evaluationState: evaluationState,
        encadreurId: seance.encadreurResponsableId,
      ),
    ).whenComplete(() {
      evaluationState.deselectionnerAcademicien();
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
          if (_isLoadingAcademiciens || evaluationState.isLoading)
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
          'Evaluations',
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
    final nbEvaluations = evaluationState.evaluationsAtelier.length;

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
                  Icons.assessment_rounded,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                Icons.people_rounded,
                '${_academiciens.length} academicien(s)',
                isDark,
              ),
              _buildInfoChip(
                Icons.star_rounded,
                '$nbEvaluations evaluation(s)',
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
            'Aucun academicien present',
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
            'Les academiciens doivent etre inscrits a cette seance.',
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
          final evaluations =
              evaluationState.evaluationsPourAcademicien(academicien.id);
          final dernierScore = evaluations.isEmpty
              ? null
              : evaluations.first.scoreTotal;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AcademicienEvaluationTile(
              academicien: academicien,
              nbEvaluations: evaluations.length,
              dernierScore: dernierScore,
              isDark: isDark,
              onTap: () => _ouvrirBottomSheetEvaluation(academicien),
            ),
          );
        }, childCount: _academiciens.length),
      ),
    );
  }
}
