import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../../../application/services/seance_service.dart';
import '../../../../domain/entities/encadreur.dart';
import '../../../../domain/entities/seance.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../../infrastructure/network/api_endpoints.dart';
import '../../../../injection_container.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../state/seance_state.dart';
import '../../seance/seance_detail_page.dart';
import '../../../widgets/academy_toast.dart';
import '../widgets/seance_card.dart';

/// Ecran Tableau de bord des seances du dashboard encadreur.
/// Affiche la liste chronologique des seances avec filtres par statut,
/// boutons d'ouverture/fermeture et navigation vers le detail.
class EncadreurSeancesScreen extends StatefulWidget {
  final SeanceState seanceState;

  const EncadreurSeancesScreen({super.key, required this.seanceState});

  @override
  State<EncadreurSeancesScreen> createState() => _EncadreurSeancesScreenState();
}

class _EncadreurSeancesScreenState extends State<EncadreurSeancesScreen>
    with RouteAware {
  late final SeanceState _seanceState;
  SeanceFilter _selectedFilter = SeanceFilter.toutes;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _seanceState = widget.seanceState;
    _seanceState.addListener(_onStateChanged);
    // Retarde l'appel apres la phase de build pour eviter setState() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFromApiIfOnlineThenLoad();
    });
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
    if (_seanceState.errorMessage != null) {
      AcademyToast.show(
        context,
        title: _seanceState.errorMessage!,
        isError: true,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      DependencyInjection.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    _refreshFromApiIfOnlineThenLoad();
  }

  /// Si connecté, récupère la liste depuis l'API et met à jour le cache local
  /// via upsert direct (sans sync), puis charge l'affichage.
  Future<void> _refreshFromApiIfOnlineThenLoad() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      if (DependencyInjection.connectivityState.isConnected) {
        try {
          final data = await DependencyInjection.apiSyncDatasource.fetchAll(
            ApiEndpoints.seances,
          );
          if (data != null && data.isNotEmpty) {
            final remoteList = data
                .map(_seanceFromApiJson)
                .whereType<Seance>()
                .toList();
            if (remoteList.isNotEmpty) {
              await DependencyInjection.seanceRepository.upsertAllFromRemote(
                remoteList,
              );
            }
          }
        } catch (_) {
          // Ignorer les erreurs réseau
        }
      }
      await _seanceState.chargerSeances();
    } finally {
      _isRefreshing = false;
    }
  }

  /// Convertit un JSON API en entité Seance.
  Seance? _seanceFromApiJson(Map<String, dynamic> json) {
    try {
      return Seance.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    DependencyInjection.routeObserver.unsubscribe(this);
    _seanceState.removeListener(_onStateChanged);
    super.dispose();
  }

  /// Rafraîchit la liste des séances depuis l'API.
  Future<void> _onRefresh() async {
    await _refreshFromApiIfOnlineThenLoad();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(colorScheme)),
          SliverToBoxAdapter(child: _buildFilterChips(colorScheme)),
          if (_seanceState.seanceOuverte != null)
            SliverToBoxAdapter(child: _buildSeanceOuverteBanner(colorScheme)),
          if (_seanceState.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_seanceState.seances.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState(colorScheme))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final seance = _seanceState.seances[index];
                return SeanceCard(
                  title: seance.titre,
                  date: seance.dateFormatee,
                  heureDebut: _formatHeure(seance.heureDebut),
                  heureFin: _formatHeure(seance.heureFin),
                  encadreur: AppLocalizations.of(context)!.meLabel,
                  nbPresents: seance.nbPresents,
                  nbAteliers: seance.nbAteliers,
                  status: _mapStatus(seance.statut),
                  onTap: () => _navigateToDetail(seance),
                  actions: _buildSeanceActions(seance),
                );
              }, childCount: _seanceState.seances.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.mySessionsTitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.sessionsCountSubtitle(_seanceState.seances.length),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _seanceState.isLoading ? null : _showCreateSeanceSheet,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              tooltip: AppLocalizations.of(context)!.openSessionTooltip,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final filters = [
      (SeanceFilter.toutes, l10n.filterAll, Icons.list_rounded),
      (SeanceFilter.enCours, l10n.filterInProgress, Icons.play_circle_rounded),
      (
        SeanceFilter.terminees,
        l10n.filterCompleted,
        Icons.check_circle_rounded,
      ),
      (SeanceFilter.aVenir, l10n.filterUpcoming, Icons.schedule_rounded),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final (filter, label, icon) = filters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = filter);
              _seanceState.setFiltre(filter);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : colorScheme.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeanceOuverteBanner(ColorScheme colorScheme) {
    final seance = _seanceState.seanceOuverte!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.sessionInProgressBanner,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                seance.dureeFormatee,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            seance.titre,
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showFermerSeanceDialog(seance),
              icon: const Icon(Icons.stop_rounded, size: 18),
              label: Text(
                AppLocalizations.of(context)!.closeThisSession,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.sports_soccer_rounded,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noSession,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.openFirstSession,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _seanceState.isLoading ? null : _showCreateSeanceSheet,
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              AppLocalizations.of(context)!.openSession,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateSeanceSheet() async {
    final currentEncadreurId =
        await DependencyInjection.preferences.getUserId();
    if (!mounted) return;

    await showModalBottomSheet<_SeanceFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SeanceFormSheet(
        encadreurResponsableId: currentEncadreurId,
        canStartNow: _seanceState.seanceOuverte == null,
        onSubmit: (result) => _submitSeanceForm(
          result: result,
          encadreurResponsableId: currentEncadreurId ?? '',
        ),
      ),
    );
  }

  Future<void> _showEditSeanceSheet(Seance seance) async {
    await showModalBottomSheet<_SeanceFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SeanceFormSheet(
        seance: seance,
        encadreurResponsableId: seance.encadreurResponsableId,
        onSubmit: (result) => _submitEditSeanceForm(seance, result),
      ),
    );
  }

  Future<OuvertureResult> _submitEditSeanceForm(
    Seance seance,
    _SeanceFormResult result,
  ) async {
    final date = result.date;
    final hd = DateTime(
      date.year,
      date.month,
      date.day,
      result.heureDebut.hour,
      result.heureDebut.minute,
    );
    final hf = DateTime(
      date.year,
      date.month,
      date.day,
      result.heureFin.hour,
      result.heureFin.minute,
    );

    final validationError = _validateTimeSlot(
      date: date,
      heureDebut: hd,
      heureFin: hf,
      excludeSeanceId: seance.id,
    );
    if (validationError != null) {
      return OuvertureResult(success: false, message: validationError);
    }

    final editResult = await _seanceState.modifierSeance(
      seance: seance,
      titre: result.titre.trim(),
      date: date,
      heureDebut: hd,
      heureFin: hf,
      encadreurInvitesIds: result.invitedIds.toList(),
      themeObjectif: result.themeObjectif.trim(),
    );

    if (!mounted) return editResult;
    if (editResult.success) {
      AcademyToast.show(
        context,
        title: editResult.message,
        isSuccess: true,
      );
    } else {
      _showAvertissementSeanceOuverte(
        editResult.message,
        editResult.seanceBloqueante,
      );
    }
    return editResult;
  }

  Future<void> _lancerSeanceProgrammee(Seance seance) async {
    final debut = DateTime(
      seance.date.year,
      seance.date.month,
      seance.date.day,
      seance.heureDebut.hour,
      seance.heureDebut.minute,
    );

    if (DateTime.now().isBefore(debut)) {
      AcademyToast.show(
        context,
        title: AppLocalizations.of(context)!.cannotLaunchBeforeStart,
        isError: true,
      );
      return;
    }

    final result = await _seanceState.lancerSeance(seance);

    if (!mounted) return;
    if (result.success) {
      AcademyToast.show(
        context,
        title: result.message,
        isSuccess: true,
      );
    } else {
      _showAvertissementSeanceOuverte(
        result.message,
        result.seanceBloqueante,
      );
    }
  }

  Future<OuvertureResult> _submitSeanceForm({
    required _SeanceFormResult result,
    required String encadreurResponsableId,
  }) async {
    if (encadreurResponsableId.isEmpty) {
      return const OuvertureResult(
        success: false,
        message: 'Erreur d\'authentification',
      );
    }

    final date = result.date;
    final hd = DateTime(
      date.year,
      date.month,
      date.day,
      result.heureDebut.hour,
      result.heureDebut.minute,
    );
    final hf = DateTime(
      date.year,
      date.month,
      date.day,
      result.heureFin.hour,
      result.heureFin.minute,
    );

    final validationError = _validateTimeSlot(
      date: date,
      heureDebut: hd,
      heureFin: hf,
    );
    if (validationError != null) {
      return OuvertureResult(success: false, message: validationError);
    }

    final createResult = await _seanceState.creerSeance(
      titre: result.titre.trim(),
      date: date,
      heureDebut: hd,
      heureFin: hf,
      encadreurResponsableId: encadreurResponsableId,
      encadreurInvitesIds: result.invitedIds.toList(),
      statut: result.statut!,
      themeObjectif: result.themeObjectif.trim(),
    );

    if (!mounted) return createResult;
    if (createResult.success) {
      AcademyToast.show(
        context,
        title: createResult.message,
        isSuccess: true,
      );
    } else {
      _showAvertissementSeanceOuverte(
        createResult.message,
        createResult.seanceBloqueante,
      );
    }
    return createResult;
  }

  List<Widget> _buildSeanceActions(Seance seance) {
    if (seance.estAVenir) {
      return [
        IconButton(
          onPressed: () => _showEditSeanceSheet(seance),
          icon: const Icon(Icons.edit_rounded),
          tooltip: AppLocalizations.of(context)!.editSessionButton,
          color: AppColors.primary,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
          iconSize: 20,
        ),
        IconButton(
          onPressed: () => _lancerSeanceProgrammee(seance),
          icon: const Icon(Icons.play_arrow_rounded),
          tooltip: AppLocalizations.of(context)!.launchSessionButton,
          color: const Color(0xFF10B981),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
          iconSize: 22,
        ),
      ];
    }
    return [];
  }

  /// Affiche un avertissement si une seance est restee ouverte.
  void _showAvertissementSeanceOuverte(
    String message,
    Seance? seanceBloqueante,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Seance en cours',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              if (seanceBloqueante != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seanceBloqueante.titre,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              seanceBloqueante.dateFormatee,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppLocalizations.of(context)!.understoodButton,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
            if (seanceBloqueante != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showFermerSeanceDialog(seanceBloqueante);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Fermer la seance',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Affiche le dialogue de fermeture avec recapitulatif.
  void _showFermerSeanceDialog(Seance seance) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.stop_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.closeSessionDialogTitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.closeSessionConfirmation,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seance.titre,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RecapRow(
                      icon: Icons.calendar_today_rounded,
                      label: seance.dateFormatee,
                    ),
                    const SizedBox(height: 4),
                    _RecapRow(
                      icon: Icons.access_time_rounded,
                      label: seance.dureeFormatee,
                    ),
                    const SizedBox(height: 4),
                    _RecapRow(
                      icon: Icons.people_rounded,
                      label: AppLocalizations.of(
                        context,
                      )!.presentCount(seance.nbPresents),
                    ),
                    const SizedBox(height: 4),
                    _RecapRow(
                      icon: Icons.sports_soccer_rounded,
                      label: AppLocalizations.of(
                        context,
                      )!.workshopCount(seance.atelierIds.length),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.dataFrozenNote,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancelButton,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final result = await _seanceState.fermerSeance(seance.id);

                if (!mounted) return;

                if (result.success) {
                  _showFermetureRecapitulatif(result);
                } else {
                  AcademyToast.show(
                    context,
                    title: result.message,
                    isError: true,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.confirmButton,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Affiche le recapitulatif apres fermeture reussie.
  void _showFermetureRecapitulatif(FermetureResult result) {
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.sessionClosed,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RecapStat(
                    value: '${result.nbPresents}',
                    label: AppLocalizations.of(context)!.presentsRecapLabel,
                    icon: Icons.people_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                  _RecapStat(
                    value: '${result.nbAteliers}',
                    label: AppLocalizations.of(context)!.workshopsRecapLabel,
                    icon: Icons.sports_soccer_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  AppLocalizations.of(context)!.perfectButton,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetail(Seance seance) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SeanceDetailPage(seance: seance)));
  }

  /// Valide qu'un créneau horaire est dans le futur (si aujourd'hui) et qu'il ne
  /// chevauche aucune séance existante sur la même journée.
  String? _validateTimeSlot({
    required DateTime date,
    required DateTime heureDebut,
    required DateTime heureFin,
    String? excludeSeanceId,
  }) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    if (isToday && heureDebut.isBefore(now)) {
      return AppLocalizations.of(context)!.sessionStartTimeInPast;
    }

    if (!heureDebut.isBefore(heureFin)) {
      return AppLocalizations.of(context)!.sessionEndBeforeStart;
    }

    for (final existing in _seanceState.seances) {
      if (excludeSeanceId != null && existing.id == excludeSeanceId) continue;
      if (existing.date.year != date.year ||
          existing.date.month != date.month ||
          existing.date.day != date.day) {
        continue;
      }

      final existingStart = DateTime(
        date.year,
        date.month,
        date.day,
        existing.heureDebut.hour,
        existing.heureDebut.minute,
      );
      final existingEnd = DateTime(
        date.year,
        date.month,
        date.day,
        existing.heureFin.hour,
        existing.heureFin.minute,
      );

      if (heureDebut.isBefore(existingEnd) && heureFin.isAfter(existingStart)) {
        return AppLocalizations.of(context)!.sessionTimeOverlap(existing.titre);
      }
    }

    return null;
  }

  String _formatHeure(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  SeanceCardStatus _mapStatus(SeanceStatus statut) {
    switch (statut) {
      case SeanceStatus.ouverte:
        return SeanceCardStatus.enCours;
      case SeanceStatus.fermee:
        return SeanceCardStatus.terminee;
      case SeanceStatus.aVenir:
        return SeanceCardStatus.aVenir;
    }
  }
}

/// Resultat renvoye par le bottom sheet de creation/edition de seance.
class _SeanceFormResult {
  final String titre;
  final DateTime date;
  final TimeOfDay heureDebut;
  final TimeOfDay heureFin;
  final Set<String> invitedIds;
  final String themeObjectif;
  final SeanceStatus? statut;

  _SeanceFormResult({
    required this.titre,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.invitedIds,
    required this.themeObjectif,
    this.statut,
  });
}

/// Callback de soumission du bottom sheet de seance.
typedef _SeanceSubmitCallback = Future<OuvertureResult> Function(
  _SeanceFormResult result,
);

/// Bottom sheet de creation/edition d'une seance.
class _SeanceFormSheet extends StatefulWidget {
  final Seance? seance;
  final String? encadreurResponsableId;
  final bool canStartNow;
  final _SeanceSubmitCallback? onSubmit;

  const _SeanceFormSheet({
    this.seance,
    this.encadreurResponsableId,
    this.canStartNow = true,
    this.onSubmit,
  });

  @override
  State<_SeanceFormSheet> createState() => _SeanceFormSheetState();
}

class _SeanceFormSheetState extends State<_SeanceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titreController;
  late final TextEditingController _themeController;
  late DateTime _selectedDate;
  late TimeOfDay _heureDebut;
  late TimeOfDay _heureFin;
  final _selectedEncadreurIds = <String>{};
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.seance != null;

  @override
  void initState() {
    super.initState();
    final seance = widget.seance;
    if (seance != null) {
      _titreController = TextEditingController(text: seance.titre);
      _themeController = TextEditingController(text: seance.themeObjectif);
      _selectedDate = seance.date;
      _heureDebut = TimeOfDay(
        hour: seance.heureDebut.hour,
        minute: seance.heureDebut.minute,
      );
      _heureFin = TimeOfDay(
        hour: seance.heureFin.hour,
        minute: seance.heureFin.minute,
      );
      _selectedEncadreurIds.addAll(seance.encadreurIds);
    } else {
      _titreController = TextEditingController();
      _themeController = TextEditingController();
      _selectedDate = DateTime.now();
      _heureDebut = const TimeOfDay(hour: 15, minute: 0);
      _heureFin = const TimeOfDay(hour: 17, minute: 0);
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _submit(SeanceStatus? statut) async {
    if (_isSubmitting) return;
    if (_titreController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pleaseEnterTitle;
      });
      return;
    }

    final result = _SeanceFormResult(
      titre: _titreController.text.trim(),
      date: _selectedDate,
      heureDebut: _heureDebut,
      heureFin: _heureFin,
      invitedIds: Set.from(_selectedEncadreurIds),
      themeObjectif: _themeController.text.trim(),
      statut: statut,
    );

    final onSubmit = widget.onSubmit;
    if (onSubmit == null) {
      Navigator.of(context).pop(result);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final submitResult = await onSubmit(result);
      if (!mounted) return;

      if (submitResult.success) {
        Navigator.of(context).pop(result);
      } else {
        setState(() => _errorMessage = submitResult.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year - 1, 1, 1),
      lastDate: DateTime(_selectedDate.year + 2, 12, 31),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickHeureDebut() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _heureDebut,
    );
    if (picked != null) {
      setState(() => _heureDebut = picked);
    }
  }

  Future<void> _pickHeureFin() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _heureFin,
    );
    if (picked != null) {
      setState(() => _heureFin = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isEditing
                    ? l10n.editSessionButton
                    : l10n.openSession,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.fillInfoToStart,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titreController,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: l10n.sessionTitleLabel,
                  labelStyle: GoogleFonts.montserrat(fontSize: 13),
                  hintText: l10n.sessionTitleHint,
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.onSurface.withValues(alpha: 0.03),
                ),
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                label: l10n.sessionDateLabel,
                date: _selectedDate,
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TimePickerField(
                      label: l10n.startLabel,
                      time: _heureDebut,
                      onTap: _pickHeureDebut,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePickerField(
                      label: l10n.endLabel,
                      time: _heureFin,
                      onTap: _pickHeureFin,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.sessionThemeLabel,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _themeController,
                maxLines: 3,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: l10n.sessionThemeHint,
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  filled: true,
                  fillColor: colorScheme.onSurface.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _EncadreursInvitesSelector(
                excludedId: widget.encadreurResponsableId,
                selectedIds: _selectedEncadreurIds,
                onToggle: (id) {
                  setState(() {
                    if (_selectedEncadreurIds.contains(id)) {
                      _selectedEncadreurIds.remove(id);
                    } else {
                      _selectedEncadreurIds.add(id);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.error,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _submit(null),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      l10n.saveAction,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submit(SeanceStatus.aVenir),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.schedule_rounded, size: 18),
                        label: Text(
                          l10n.scheduleSessionButton,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_isSubmitting || !widget.canStartNow)
                            ? null
                            : () => _submit(SeanceStatus.ouverte),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow_rounded, size: 18),
                        label: Text(
                          l10n.startNowButton,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFF10B981).withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour selectionner une date.
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour selectionner une heure.
class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:'
                  '${time.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sélecteur multi-choix d'encadreurs invités pour le modal de création de séance.
class _EncadreursInvitesSelector extends StatefulWidget {
  final String? excludedId;
  final Set<String> selectedIds;
  final void Function(String id) onToggle;

  const _EncadreursInvitesSelector({
    required this.excludedId,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  State<_EncadreursInvitesSelector> createState() =>
      _EncadreursInvitesSelectorState();
}

class _EncadreursInvitesSelectorState
    extends State<_EncadreursInvitesSelector> {
  List<Encadreur> _encadreurs = [];
  // Vrai uniquement lors du tout premier chargement (liste vide).
  bool _isInitialLoading = true;
  // Vrai lors d'un rafraîchissement (liste déjà visible).
  bool _isRefreshing = false;

  static final _rolesAutorises = {
    UserRole.encadreur,
    UserRole.encadreurChef,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromCache());
  }

  /// Lecture du cache local — chargement initial uniquement.
  Future<void> _loadFromCache() async {
    if (!mounted) return;
    setState(() => _isInitialLoading = true);
    try {
      final all = await DependencyInjection.encadreurRepository.getAll();
      if (mounted) setState(() => _encadreurs = _filter(all));
    } catch (_) {
      if (mounted) setState(() => _encadreurs = []);
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  /// Appel réseau réel — liste courante conservée jusqu'à la réponse complète.
  Future<void> _refresh() async {
    if (!mounted || _isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await DependencyInjection.encadreurRepository.syncFromApi();
      final all = await DependencyInjection.encadreurRepository.getAll();
      // Remplacement atomique : la liste ne disparaît jamais pendant l'attente.
      if (mounted) setState(() => _encadreurs = _filter(all));
    } catch (_) {
      // En cas d'erreur on conserve la liste existante.
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  List<Encadreur> _filter(List<Encadreur> all) => all
      .where(
        (e) =>
            e.id != widget.excludedId && _rolesAutorises.contains(e.role),
      )
      .toList()
    ..sort((a, b) => a.nomComplet.compareTo(b.nomComplet));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.group_add_rounded,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.invitedCoachesLabel,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (widget.selectedIds.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.selectedIds.length}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            IconButton(
              onPressed: (_isInitialLoading || _isRefreshing) ? null : _refresh,
              icon: _isRefreshing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
              tooltip: 'Rafraichir',
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isInitialLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          )
        else if (_encadreurs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.invitedCoachesNone,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _encadreurs.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                ),
                itemBuilder: (context, index) {
                  final enc = _encadreurs[index];
                  final isSelected = widget.selectedIds.contains(enc.id);
                  return InkWell(
                    onTap: () => widget.onToggle(enc.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            backgroundImage: enc.photoUrl.isNotEmpty
                                ? NetworkImage(enc.photoUrl)
                                : null,
                            child: enc.photoUrl.isEmpty
                                ? Text(
                                    enc.prenom.isNotEmpty
                                        ? enc.prenom[0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enc.nomComplet,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                if (enc.specialite.isNotEmpty)
                                  Text(
                                    enc.specialite,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => widget.onToggle(enc.id),
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Ligne de recapitulatif avec icone et texte.
class _RecapRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RecapRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Statistique du recapitulatif de fermeture.
class _RecapStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _RecapStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
