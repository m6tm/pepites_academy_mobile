import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/seance.dart';
import '../../../../injection_container.dart';
import '../../../../presentation/theme/app_colors.dart';
import '../../../state/seance_state.dart';
import '../../seance/seance_detail_page.dart';
import '../widgets/seance_card.dart';

/// Ecran Seances du dashboard administrateur.
/// Consultation en lecture seule : historique, suivi et filtres.
/// L'administrateur ne peut pas creer, ouvrir ou fermer de seance.
class AdminSeancesScreen extends StatefulWidget {
  const AdminSeancesScreen({super.key});

  @override
  State<AdminSeancesScreen> createState() => _AdminSeancesScreenState();
}

class _AdminSeancesScreenState extends State<AdminSeancesScreen> {
  late final SeanceState _seanceState;
  SeanceFilter _selectedFilter = SeanceFilter.toutes;

  @override
  void initState() {
    super.initState();
    _seanceState = SeanceState(DependencyInjection.seanceService);
    _seanceState.addListener(_onStateChanged);
    _seanceState.chargerSeances();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _seanceState.removeListener(_onStateChanged);
    _seanceState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
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
                encadreur: seance.encadreurResponsableId,
                nbPresents: seance.nbPresents,
                nbAteliers: seance.nbAteliers,
                status: _mapStatus(seance.statut),
                onTap: () => _navigateToDetail(seance),
              );
            }, childCount: _seanceState.seances.length),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  /// En-tete sans bouton de creation
  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seances',
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_seanceState.seances.length} seance(s) - Historique et suivi',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Filtres par statut
  Widget _buildFilterChips(ColorScheme colorScheme) {
    final filters = [
      (SeanceFilter.toutes, 'Toutes', Icons.list_rounded),
      (SeanceFilter.enCours, 'En cours', Icons.play_circle_rounded),
      (SeanceFilter.terminees, 'Terminees', Icons.check_circle_rounded),
      (SeanceFilter.aVenir, 'A venir', Icons.schedule_rounded),
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

  /// Banniere informative si une seance est en cours (lecture seule)
  Widget _buildSeanceOuverteBanner(ColorScheme colorScheme) {
    final seance = _seanceState.seanceOuverte!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _navigateToDetail(seance),
      child: Container(
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
                        'SEANCE EN COURS',
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
            const SizedBox(height: 6),
            Text(
              seance.encadreurResponsableId,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  size: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 6),
                Text(
                  'Appuyez pour consulter le detail',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Etat vide
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
            'Aucune seance',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les seances creees par les encadreurs\napparaitront ici.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Seance seance) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => SeanceDetailPage(seance: seance)));
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
