import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/encadreur.dart';
import '../../../domain/entities/presence.dart';
import '../../../domain/entities/seance.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';

/// Fiche de consultation detaillee d'un encadreur.
/// Onglets : Infos, Seances dirigees, Statistiques.
class EncadreurDetailPage extends StatefulWidget {
  final Encadreur encadreur;

  const EncadreurDetailPage({super.key, required this.encadreur});

  @override
  State<EncadreurDetailPage> createState() => _EncadreurDetailPageState();
}

class _EncadreurDetailPageState extends State<EncadreurDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Seance> _seancesDirigees = [];
  List<Presence> _presences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      final toutesSeances = await DependencyInjection.seanceRepository.getAll();
      final presences = await DependencyInjection.presenceRepository
          .getByProfil(widget.encadreur.id);

      final seancesDirigees = toutesSeances
          .where(
            (s) =>
                s.encadreurResponsableId == widget.encadreur.id ||
                s.encadreurIds.contains(widget.encadreur.id),
          )
          .toList();

      seancesDirigees.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _seancesDirigees = seancesDirigees;
          _presences = presences;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(colorScheme),
            _buildProfileHeader(colorScheme),
            _buildTabBar(colorScheme),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInfosTab(colorScheme, isDark),
                        _buildSeancesTab(colorScheme, isDark),
                        _buildStatistiquesTab(colorScheme, isDark),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barre d'application.
  Widget _buildAppBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.coachProfileTitle,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// En-tete avec infos principales de l'encadreur.
  Widget _buildProfileHeader(ColorScheme colorScheme) {
    final enc = widget.encadreur;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${enc.prenom.isNotEmpty ? enc.prenom[0] : ''}${enc.nom.isNotEmpty ? enc.nom[0] : ''}',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enc.nomComplet,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.coachBadgeTypeMention,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B5CF6),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        enc.specialite,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniStat(
                      Icons.sports_soccer_rounded,
                      '${_seancesDirigees.length}',
                      AppLocalizations.of(context)!.sessionsLabel,
                    ),
                    const SizedBox(width: 16),
                    _buildMiniStat(
                      Icons.check_circle_rounded,
                      '${_presences.length}',
                      AppLocalizations.of(context)!.presenceLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Barre d'onglets.
  Widget _buildTabBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.45),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: AppLocalizations.of(context)!.infosTab),
          Tab(text: AppLocalizations.of(context)!.sessionsTab),
          Tab(text: AppLocalizations.of(context)!.statsTab),
        ],
      ),
    );
  }

  /// Onglet Informations generales.
  Widget _buildInfosTab(ColorScheme colorScheme, bool isDark) {
    final enc = widget.encadreur;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(
            colorScheme,
            isDark,
            AppLocalizations.of(context)!.personalInformation,
            Icons.person_rounded,
            [
              _InfoRow(
                AppLocalizations.of(context)!.fullNameLabel,
                enc.nomComplet,
              ),
              _InfoRow(AppLocalizations.of(context)!.phoneLabel, enc.telephone),
              _InfoRow(
                AppLocalizations.of(context)!.specialtyLabel,
                enc.specialite,
              ),
              _InfoRow(AppLocalizations.of(context)!.roleLabel, enc.role.id),
              _InfoRow(
                AppLocalizations.of(context)!.qrCodeLabel,
                enc.codeQrUnique,
              ),
              _InfoRow(
                AppLocalizations.of(context)!.registeredOnLabel,
                '${enc.createdAt.day}/${enc.createdAt.month}/${enc.createdAt.year}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            colorScheme,
            isDark,
            AppLocalizations.of(context)!.activityLabel,
            Icons.bar_chart_rounded,
            [
              _InfoRow(
                AppLocalizations.of(context)!.conductedSessions,
                '${enc.nbSeancesDirigees}',
              ),
              _InfoRow(
                AppLocalizations.of(context)!.conductedAnnotations,
                '${enc.nbAnnotations}',
              ),
              _InfoRow(
                AppLocalizations.of(context)!.recordedPresences,
                '${_presences.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Carte d'informations generique.
  Widget _buildInfoCard(
    ColorScheme colorScheme,
    bool isDark,
    String titre,
    IconData icon,
    List<_InfoRow> rows,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                titre,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      row.value,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Onglet Seances dirigees.
  Widget _buildSeancesTab(ColorScheme colorScheme, bool isDark) {
    if (_seancesDirigees.isEmpty) {
      return _buildEmptyTab(
        colorScheme,
        Icons.sports_soccer_rounded,
        'Aucune seance dirigee',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _seancesDirigees.length,
      itemBuilder: (context, index) {
        final seance = _seancesDirigees[index];
        final statusColor = _getStatusColor(seance.statut);
        final statusLabel = _getStatusLabel(seance.statut);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sports_soccer_rounded,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seance.titre,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${seance.dateFormatee} - ${seance.dureeFormatee}',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildSeanceChip(
                    Icons.people_rounded,
                    AppLocalizations.of(
                      context,
                    )!.presentsInfoLabel(seance.nbPresents),
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 10),
                  _buildSeanceChip(
                    Icons.fitness_center_rounded,
                    AppLocalizations.of(
                      context,
                    )!.workshopsInfoLabel(seance.atelierIds.length),
                    const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeanceChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Onglet Statistiques.
  Widget _buildStatistiquesTab(ColorScheme colorScheme, bool isDark) {
    final nbSeances = _seancesDirigees.length;
    final nbSeancesFermees = _seancesDirigees.where((s) => s.estFermee).length;
    final totalPresents = _seancesDirigees.fold<int>(
      0,
      (sum, s) => sum + s.nbPresents,
    );
    final moyennePresents = nbSeances > 0
        ? (totalPresents / nbSeances).toStringAsFixed(1)
        : '0';
    final totalAteliers = _seancesDirigees.fold<int>(
      0,
      (sum, s) => sum + s.atelierIds.length,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.conductedSessions,
                  '$nbSeances',
                  Icons.sports_soccer_rounded,
                  const Color(0xFF3B82F6),
                  colorScheme,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.closedSessionsStat,
                  '$nbSeancesFermees',
                  Icons.check_circle_rounded,
                  const Color(0xFF10B981),
                  colorScheme,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.avgPresents,
                  moyennePresents,
                  Icons.people_rounded,
                  const Color(0xFF8B5CF6),
                  colorScheme,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.totalWorkshops,
                  '$totalAteliers',
                  Icons.fitness_center_rounded,
                  const Color(0xFFF59E0B),
                  colorScheme,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            colorScheme,
            isDark,
            AppLocalizations.of(context)!.recapLabel,
            Icons.insights_rounded,
            [
              _InfoRow(
                AppLocalizations.of(context)!.recordedPresences,
                '${_presences.length}',
              ),
              _InfoRow(
                AppLocalizations.of(context)!.conductedAnnotations,
                '${widget.encadreur.nbAnnotations}',
              ),
              _InfoRow(
                AppLocalizations.of(context)!.closureRate,
                nbSeances > 0
                    ? '${((nbSeancesFermees / nbSeances) * 100).toStringAsFixed(0)}%'
                    : '0%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Carte de statistique individuelle.
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  /// Etat vide pour un onglet.
  Widget _buildEmptyTab(
    ColorScheme colorScheme,
    IconData icon,
    String message,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SeanceStatus statut) {
    switch (statut) {
      case SeanceStatus.ouverte:
        return const Color(0xFF10B981);
      case SeanceStatus.fermee:
        return const Color(0xFF6B7280);
      case SeanceStatus.aVenir:
        return const Color(0xFF3B82F6);
    }
  }

  String _getStatusLabel(SeanceStatus statut) {
    switch (statut) {
      case SeanceStatus.ouverte:
        return AppLocalizations.of(context)!.sessionStatusOpen;
      case SeanceStatus.fermee:
        return AppLocalizations.of(context)!.sessionStatusClosed;
      case SeanceStatus.aVenir:
        return AppLocalizations.of(context)!.sessionStatusUpcoming;
    }
  }
}

/// Ligne d'information label/valeur.
class _InfoRow {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);
}
