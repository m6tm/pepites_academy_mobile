import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/atelier.dart';
import '../../../domain/entities/seance.dart';
import '../../../injection_container.dart';
import '../../state/annotation_state.dart';
import '../../state/seance_detail_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';
import '../annotation/widgets/annotation_side_panel.dart';
import '../ateliers/ateliers_page.dart';
import '../../widgets/ateliers_progress_card.dart';
import '../../widgets/permission_guard.dart';
import '../../../domain/entities/permission.dart';
import '../../../../l10n/app_localizations.dart';

/// Vue detaillee d'une seance affichant les encadreurs presents,
/// les academiciens et les ateliers programmes.
class SeanceDetailPage extends StatefulWidget {
  final Seance seance;

  const SeanceDetailPage({super.key, required this.seance});

  @override
  State<SeanceDetailPage> createState() => _SeanceDetailPageState();
}

class _SeanceDetailPageState extends State<SeanceDetailPage> with RouteAware {
  late final SeanceDetailState _state;

  @override
  void initState() {
    super.initState();
    _state = SeanceDetailState(widget.seance);
    _state.loadInitial();
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
  void dispose() {
    _state.dispose();
    DependencyInjection.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    _state.refreshFromBackend();
  }

  Future<void> _onRefresh() async {
    await _state.refreshFromBackend(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final seance = _state.seance;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(context, colorScheme, seance),
                SliverToBoxAdapter(child: _buildStatusBanner(colorScheme, seance)),
                SliverToBoxAdapter(
                  child: _buildInfoSection(colorScheme, isDark, seance),
                ),
                SliverToBoxAdapter(
                  child: _buildStatsRow(colorScheme, isDark, seance),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    AppLocalizations.of(context)!.invitedCoachesLabel,
                    Icons.mail_outline_rounded,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildInvitedCoachesList(colorScheme, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    AppLocalizations.of(context)!.presentCoaches,
                    Icons.person_rounded,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildEncadreursList(colorScheme, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    AppLocalizations.of(context)!.academicians,
                    Icons.groups_rounded,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildAcademiciensList(colorScheme, isDark),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionTitleWithAction(
                    context,
                    AppLocalizations.of(context)!.workshopsRecapLabel,
                    Icons.fitness_center_rounded,
                    seance,
                  ),
                ),
                SliverToBoxAdapter(
                  child: PermissionGuard(
                    permission: Permission.atelierView,
                    child: AteliersProgressCard(ateliers: _state.ateliers),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildAteliersList(colorScheme, isDark, seance),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme, Seance seance) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: _statusColor(seance).withValues(alpha: 0.95),
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          seance.titre,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_statusColor(seance), _statusColor(seance).withValues(alpha: 0.8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(ColorScheme colorScheme, Seance seance) {
    final color = _statusColor(seance);
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(seance), color: color, size: 22),
          const SizedBox(width: 10),
          Text(
            _getStatusLabel(context, seance),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            seance.dateFormatee,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme, bool isDark, Seance seance) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: AppLocalizations.of(context)!.dateLabel,
            value: seance.dateFormatee,
          ),
          const Divider(height: 20, color: Colors.grey),
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: AppLocalizations.of(context)!.horaireLabel,
            value: seance.dureeFormatee,
          ),
          const Divider(height: 20, color: Colors.grey),
          _DetailRow(
            icon: Icons.person_rounded,
            label: AppLocalizations.of(context)!.responsibleLabel,
            value: seance.encadreurResponsableId == 'current_user'
                ? (_state.responsableNom ?? AppLocalizations.of(context)!.meLabel)
                : (_state.responsableNom ??
                      _state.responsable?.nomComplet ??
                      seance.encadreurResponsableId),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme, bool isDark, Seance seance) {
    final nbPresents = _state.nbPresents ?? seance.nbPresents;
    final nbAteliers = _state.ateliers.isNotEmpty
        ? _state.ateliers.length
        : seance.atelierIds.length;
    final nbEncadreurs = (_state.encadreursPresents.isNotEmpty ||
            _state.encadreursInvites.isNotEmpty)
        ? _state.encadreursPresents.length + _state.encadreursInvites.length
        : seance.encadreurIds
                .where((id) => id != seance.encadreurResponsableId)
                .length +
            (seance.encadreurResponsableId.isNotEmpty &&
                    seance.encadreurResponsableId != 'current_user'
                ? 1
                : 0);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _StatBox(
            icon: Icons.people_rounded,
            value: '$nbPresents',
            label: AppLocalizations.of(context)!.presentsRecapLabel,
            color: const Color(0xFF3B82F6),
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _StatBox(
            icon: Icons.sports_soccer_rounded,
            value: '$nbAteliers',
            label: AppLocalizations.of(context)!.workshops,
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _StatBox(
            icon: Icons.group_rounded,
            value: '$nbEncadreurs',
            label: AppLocalizations.of(context)!.coaches,
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitleWithAction(
    BuildContext context,
    String title,
    IconData icon,
    Seance seance,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _naviguerVersComposition(seance),
            icon: Icon(
              seance.estFermee ? Icons.visibility_rounded : Icons.edit_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            label: Text(
              seance.estFermee
                  ? AppLocalizations.of(context)!.viewAll
                  : AppLocalizations.of(context)!.manageAction,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncadreursList(ColorScheme colorScheme, bool isDark) {
    if (_state.isLoadingPersonnes) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_state.encadreursPresents.isEmpty) {
      return _buildEmptyListMessage(
        AppLocalizations.of(context)!.noCoachRegistered,
        colorScheme,
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: _state.encadreursPresents.length,
        itemBuilder: (context, index) {
          final enc = _state.encadreursPresents[index];
          return _PersonChip(
            label: enc.nomComplet,
            initials:
                '${enc.prenom.isNotEmpty ? enc.prenom[0] : ''}${enc.nom.isNotEmpty ? enc.nom[0] : ''}',
            photoUrl: enc.photoUrl,
            color: const Color(0xFF10B981),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildInvitedCoachesList(ColorScheme colorScheme, bool isDark) {
    if (_state.isLoadingPersonnes) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_state.encadreursInvites.isEmpty) {
      return _buildEmptyListMessage(
        AppLocalizations.of(context)!.invitedCoachesNone,
        colorScheme,
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: _state.encadreursInvites.length,
        itemBuilder: (context, index) {
          final enc = _state.encadreursInvites[index];
          return _PersonChip(
            label: enc.nomComplet,
            initials:
                '${enc.prenom.isNotEmpty ? enc.prenom[0] : ''}${enc.nom.isNotEmpty ? enc.nom[0] : ''}',
            photoUrl: enc.photoUrl,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildAcademiciensList(ColorScheme colorScheme, bool isDark) {
    if (_state.isLoadingPersonnes) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_state.academiciens.isEmpty) {
      return _buildEmptyListMessage(
        AppLocalizations.of(context)!.noAcademicianRegistered,
        colorScheme,
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: _state.academiciens.length,
        itemBuilder: (context, index) {
          final aca = _state.academiciens[index];
          return GestureDetector(
            onTap: () => _ouvrirAnnotationAcademicien(aca),
            child: _PersonChip(
              label: '${aca.prenom} ${aca.nom}',
              initials:
                  '${aca.prenom.isNotEmpty ? aca.prenom[0] : ''}${aca.nom.isNotEmpty ? aca.nom[0] : ''}',
              photoUrl: aca.photoUrl,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAteliersList(ColorScheme colorScheme, bool isDark, Seance seance) {
    if (_state.isLoadingAteliers) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_state.ateliers.isEmpty) {
      return _buildEmptyListMessage(
        AppLocalizations.of(context)!.noWorkshopProgrammed,
        colorScheme,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(_state.ateliers.length, (index) {
          final atelier = _state.ateliers[index];
          final typeColor = _getAtelierTypeColor(atelier.type);
          final typeIcon = _getAtelierTypeIcon(atelier.type);

          return GestureDetector(
            onTap: () => _naviguerVersComposition(seance),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: typeColor.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atelier.nom,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                atelier.typeLabel,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: typeColor,
                                ),
                              ),
                            ),
                            if (atelier.description.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  atelier.description,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _ouvrirAnnotationAcademicien(Academicien academicien) async {
    if (_state.ateliers.isEmpty) {
      AcademyToast.show(
        context,
        title: AppLocalizations.of(context)!.sessionAddAtLeastOneWorkshop,
        isError: true,
      );
      return;
    }

    if (!mounted) return;
    showModalBottomSheet<Atelier>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AtelierPickerSheet(
        academicien: academicien,
        ateliers: _state.ateliers
            .where((a) => a.statut == AtelierStatut.applique)
            .toList(),
      ),
    ).then((atelier) {
      if (!mounted || atelier == null) return;
      _ouvrirAnnotationAcademicienPourAtelier(
        academicien: academicien,
        atelier: atelier,
      ).then((_) {
        if (!mounted) return;
        _ouvrirAnnotationAcademicien(academicien);
      });
    });
  }

  Future<void> _ouvrirAnnotationAcademicienPourAtelier({
    required Academicien academicien,
    required Atelier atelier,
  }) async {
    final annotationState = AnnotationState(
      DependencyInjection.annotationService,
      DependencyInjection.domainEventBus,
    );

    await annotationState.initialiserContexte(
      atelierId: atelier.id,
      seanceId: _state.seance.id,
    );
    await annotationState.selectionnerAcademicien(academicien.id);

    if (!mounted) {
      annotationState.dispose();
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnnotationSidePanel(
        academicien: academicien,
        atelier: atelier,
        seance: _state.seance,
        annotationState: annotationState,
        encadreurId: _state.seance.encadreurResponsableId,
      ),
    );

    annotationState.deselectionnerAcademicien();
    annotationState.dispose();
  }

  Future<void> _naviguerVersComposition(Seance seance) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AteliersPage(seance: seance),
      ),
    );
    _state.refreshFromBackend();
  }

  Widget _buildEmptyListMessage(String message, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(Seance seance) {
    switch (seance.statut) {
      case SeanceStatus.ouverte:
        return const Color(0xFF10B981);
      case SeanceStatus.fermee:
        return AppColors.textMutedLight;
      case SeanceStatus.aVenir:
        return const Color(0xFF3B82F6);
    }
  }

  String _getStatusLabel(BuildContext context, Seance seance) {
    final l10n = AppLocalizations.of(context)!;
    switch (seance.statut) {
      case SeanceStatus.ouverte:
        return l10n.sessionStatusOpen;
      case SeanceStatus.fermee:
        return l10n.sessionStatusClosed;
      case SeanceStatus.aVenir:
        return l10n.sessionStatusUpcoming;
    }
  }

  IconData _statusIcon(Seance seance) {
    switch (seance.statut) {
      case SeanceStatus.ouverte:
        return Icons.play_circle_rounded;
      case SeanceStatus.fermee:
        return Icons.check_circle_rounded;
      case SeanceStatus.aVenir:
        return Icons.schedule_rounded;
    }
  }

  static Color _getAtelierTypeColor(AtelierType type) {
    switch (type) {
      case AtelierType.dribble:
        return const Color(0xFF3B82F6);
      case AtelierType.passes:
        return const Color(0xFF10B981);
      case AtelierType.finition:
        return const Color(0xFFEF4444);
      case AtelierType.physique:
        return const Color(0xFFF59E0B);
      case AtelierType.jeuEnSituation:
        return const Color(0xFF8B5CF6);
      case AtelierType.tactique:
        return const Color(0xFF6366F1);
      case AtelierType.gardien:
        return const Color(0xFF14B8A6);
      case AtelierType.echauffement:
        return const Color(0xFFF97316);
      case AtelierType.personnalise:
        return const Color(0xFF64748B);
    }
  }

  static IconData _getAtelierTypeIcon(AtelierType type) {
    switch (type) {
      case AtelierType.dribble:
        return Icons.sports_soccer_rounded;
      case AtelierType.passes:
        return Icons.swap_horiz_rounded;
      case AtelierType.finition:
        return Icons.sports_rounded;
      case AtelierType.physique:
        return Icons.timer_rounded;
      case AtelierType.jeuEnSituation:
        return Icons.groups_rounded;
      case AtelierType.tactique:
        return Icons.map_rounded;
      case AtelierType.gardien:
        return Icons.sports_handball_rounded;
      case AtelierType.echauffement:
        return Icons.directions_run_rounded;
      case AtelierType.personnalise:
        return Icons.tune_rounded;
    }
  }
}

class _AtelierPickerSheet extends StatelessWidget {
  final Academicien academicien;
  final List<Atelier> ateliers;

  const _AtelierPickerSheet({
    required this.academicien,
    required this.ateliers,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${academicien.prenom} ${academicien.nom}',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.workshops,
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
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: ateliers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final atelier = ateliers[index];
                final typeColor = _SeanceDetailPageState._getAtelierTypeColor(
                  atelier.type,
                );
                final typeIcon = _SeanceDetailPageState._getAtelierTypeIcon(
                  atelier.type,
                );

                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(atelier),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(typeIcon, color: typeColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                atelier.nom,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                atelier.typeLabel,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonChip extends StatelessWidget {
  final String label;
  final String? initials;
  final String? photoUrl;
  final Color color;
  final bool isDark;

  const _PersonChip({
    required this.label,
    this.initials,
    this.photoUrl,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayInitials = initials ?? (label.isNotEmpty ? label[0] : '?');

    return Container(
      width: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildPhoto(displayInitials),
                  )
                : Center(
                    child: Text(
                      displayInitials,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(String displayInitials) {
    final isLocal = !photoUrl!.startsWith('http');
    final fallback = Center(
      child: Text(
        displayInitials,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );

    if (isLocal) {
      return Image.file(
        File(photoUrl!),
        fit: BoxFit.cover,
        width: 34,
        height: 34,
        errorBuilder: (_, e1, s1) => fallback,
      );
    }

    return Image.network(
      photoUrl!,
      fit: BoxFit.cover,
      width: 34,
      height: 34,
      errorBuilder: (_, e2, s2) => fallback,
    );
  }
}
