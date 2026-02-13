import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/bulletin.dart';
import '../../../domain/entities/encadreur.dart';
import '../../../injection_container.dart';
import '../../state/bulletin_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';
import 'bulletin_preview_page.dart';
import 'widgets/evolution_chart_widget.dart';
import 'widgets/periode_selector_widget.dart';

/// Page principale du module Bulletin de Formation.
/// Permet de selectionner un academicien, choisir une periode,
/// generer un bulletin et consulter l'historique des bulletins.
class BulletinPage extends StatefulWidget {
  final Academicien academicien;
  final Encadreur? encadreur;

  const BulletinPage({
    super.key,
    required this.academicien,
    this.encadreur,
  });

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  late final BulletinState _bulletinState;
  final TextEditingController _observationsController = TextEditingController();

  Academicien get academicien => widget.academicien;

  @override
  void initState() {
    super.initState();
    _bulletinState = BulletinState(DependencyInjection.bulletinService);
    _bulletinState.addListener(_onStateChanged);
    _bulletinState.chargerBulletins(academicien.id);
  }

  @override
  void dispose() {
    _bulletinState.removeListener(_onStateChanged);
    _bulletinState.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});

    if (_bulletinState.successMessage != null) {
      AcademyToast.show(
        context,
        title: _bulletinState.successMessage!,
        isSuccess: true,
      );
      _bulletinState.clearMessages();
    } else if (_bulletinState.errorMessage != null) {
      AcademyToast.show(
        context,
        title: _bulletinState.errorMessage!,
        isError: true,
      );
      _bulletinState.clearMessages();
    }
  }

  Future<void> _genererBulletin() async {
    final encadreurId = widget.encadreur?.id ?? '';
    final success = await _bulletinState.genererBulletin(
      academicienId: academicien.id,
      encadreurId: encadreurId,
      observationsGenerales: _observationsController.text,
    );

    if (success && _bulletinState.bulletinCourant != null && mounted) {
      _observationsController.clear();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BulletinPreviewPage(
            bulletin: _bulletinState.bulletinCourant!,
            academicien: academicien,
            encadreur: widget.encadreur,
            bulletinState: _bulletinState,
          ),
        ),
      );
    }
  }

  void _ouvrirBulletin(Bulletin bulletin) {
    _bulletinState.selectionnerBulletin(bulletin);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BulletinPreviewPage(
          bulletin: bulletin,
          academicien: academicien,
          encadreur: widget.encadreur,
          bulletinState: _bulletinState,
        ),
      ),
    );
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
          SliverToBoxAdapter(child: _buildAcademicienHeader(isDark)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PeriodeSelectorWidget(
                typePeriode: _bulletinState.typePeriode,
                dateReference: _bulletinState.dateReference,
                onTypePeriodeChanged: _bulletinState.changerTypePeriode,
                onDateReferenceChanged: _bulletinState.changerDateReference,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildObservationsInput(isDark)),
          SliverToBoxAdapter(child: _buildGenererButton(isDark)),
          if (_bulletinState.bulletins.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: EvolutionChartWidget(
                  bulletins: _bulletinState.bulletins,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildHistoriqueHeader(isDark)),
            _buildHistoriqueListe(isDark),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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

  Widget _buildAcademicienHeader(bool isDark) {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              '${academicien.prenom[0]}${academicien.nom[0]}',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${academicien.prenom} ${academicien.nom}',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_bulletinState.bulletins.length} bulletin(s) genere(s)',
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.assessment_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsInput(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Observations generales',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textMainDark
                  : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observationsController,
            maxLines: 4,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: isDark
                  ? AppColors.textMainDark
                  : AppColors.textMainLight,
            ),
            decoration: InputDecoration(
              hintText: 'Redigez vos observations pour cette periode...',
              hintStyle: GoogleFonts.montserrat(
                fontSize: 13,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenererButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _bulletinState.isGenerating ? null : _genererBulletin,
          icon: _bulletinState.isGenerating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.auto_awesome_rounded, size: 20),
          label: Text(
            _bulletinState.isGenerating
                ? 'Generation en cours...'
                : 'Generer le bulletin',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoriqueHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Historique des bulletins',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textMainDark
                  : AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueListe(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final bulletin = _bulletinState.bulletins[index];
            return _buildBulletinCard(bulletin, isDark);
          },
          childCount: _bulletinState.bulletins.length,
        ),
      ),
    );
  }

  Widget _buildBulletinCard(Bulletin bulletin, bool isDark) {
    return GestureDetector(
      onTap: () => _ouvrirBulletin(bulletin),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bulletin.periodeLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniStat(
                        Icons.star_rounded,
                        bulletin.competences.moyenne.toStringAsFixed(1),
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildMiniStat(
                        Icons.check_circle_rounded,
                        '${bulletin.tauxPresence.toStringAsFixed(0)}%',
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildMiniStat(
                        Icons.edit_note_rounded,
                        '${bulletin.nbAnnotationsTotal}',
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.primary),
        const SizedBox(width: 3),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textMutedDark
                : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }
}
