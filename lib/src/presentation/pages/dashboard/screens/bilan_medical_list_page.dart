import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/navigation/route_aware_refresh_mixin.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/bilan_medical_mensuel.dart';
import '../../../../injection_container.dart';
import '../../../state/bilan_medical_mensuel_state.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/sync_notification_banner.dart';
import 'bilan_medical_detail_page.dart';
import 'bilan_medical_form_page.dart';

/// Page affichant la liste des bilans medicaux mensuels d'un academicien.
class BilanMedicalListPage extends StatefulWidget {
  final Academicien academicien;

  const BilanMedicalListPage({
    super.key,
    required this.academicien,
  });

  @override
  State<BilanMedicalListPage> createState() => _BilanMedicalListPageState();
}

class _BilanMedicalListPageState extends State<BilanMedicalListPage>
    with RouteAware, RouteAwareRefreshMixin<BilanMedicalListPage> {
  late final BilanMedicalMensuelState _state;
  String _posteName = '';

  @override
  void initState() {
    super.initState();
    _state = DependencyInjection.bilanMedicalMensuelState;
    _loadPosteName();
    _silentRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscribeRouteObserver(context, DependencyInjection.routeObserver);
  }

  @override
  void didPopNext() {
    refreshNotifier.notifyReturned();
    _state.refresh(widget.academicien.id);
  }

  @override
  void dispose() {
    unsubscribeRouteObserver(DependencyInjection.routeObserver);
    super.dispose();
  }

  Future<void> _loadPosteName() async {
    try {
      final poste = await DependencyInjection
          .referentielService.posteRepository
          .getById(widget.academicien.posteFootballId);
      if (mounted && poste != null) {
        setState(() => _posteName = poste.nom);
      }
    } catch (_) {
      // ignore
    }
  }

  /// Rafraichissement silencieux au chargement initial ou au retour de page.
  Future<void> _silentRefresh() async {
    await _state.syncFromApi(widget.academicien.id, silent: true);
  }

  Future<void> _onRefresh() async {
    await _state.syncFromApi(widget.academicien.id);
  }

  void _openDetail(BilanMedicalMensuel bilan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BilanMedicalDetailPage(
          academicien: widget.academicien,
          bilan: bilan,
        ),
      ),
    );
  }

  Future<void> _openForm({BilanMedicalMensuel? bilan}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BilanMedicalFormPage(
          academicien: widget.academicien,
          bilan: bilan,
        ),
      ),
    );
    if (result == true && mounted) {
      await _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            SyncNotificationBanner(
              connectivityState: DependencyInjection.connectivityState,
              syncState: DependencyInjection.syncState,
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _state,
                builder: (context, _) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.primary,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildHeader(colorScheme, isDark, l10n),
                        ),
                        SliverToBoxAdapter(
                          child: _buildAcademicienCard(colorScheme, isDark, l10n),
                        ),
                        if (_state.isFetching && !_state.isLoading)
                          SliverToBoxAdapter(
                            child: _buildSilentRefreshIndicator(colorScheme),
                          ),
                        if (_state.isLoading && _state.bilans.isEmpty)
                          const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_state.isEmpty)
                          SliverFillRemaining(
                            child: _buildEmptyState(colorScheme, l10n),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _buildBilanCard(
                                    _state.bilans[index],
                                    colorScheme,
                                    isDark,
                                    l10n,
                                  );
                                },
                                childCount: _state.bilans.length,
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.bilanMedicalCreateButton,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bilansTitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.bilansSubtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicienCard(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: widget.academicien.photoUrl.isNotEmpty
                  ? NetworkImage(widget.academicien.photoUrl)
                  : null,
              child: widget.academicien.photoUrl.isEmpty
                  ? Icon(Icons.person_rounded, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.academicien.prenom} ${widget.academicien.nom}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _posteName,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBilanCard(
    BilanMedicalMensuel bilan,
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openDetail(bilan),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bilan.periodeLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${bilan.totalBlessures} ${l10n.bilanMedicalTotalBlessuresLabel}',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildCounterChip(
                    l10n.bilanMedicalMusculaireShort,
                    bilan.blessuresMusculaire,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildCounterChip(
                    l10n.bilanMedicalArticulaireShort,
                    bilan.blessuresArticulaire,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildCounterChip(
                    l10n.bilanMedicalTraumatiqueShort,
                    bilan.blessuresTraumatique,
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterChip(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
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
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSilentRefreshIndicator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          minHeight: 3,
          backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_rounded,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.bilanMedicalEmpty,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
