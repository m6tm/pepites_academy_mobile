import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/events/academicien_events.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/poste_football.dart';
import '../../../../injection_container.dart';
import '../../../theme/app_colors.dart';
import 'bilan_medical_list_page.dart';

/// Ecran des bilans medicaux mensuels accessible depuis la navigation medecin.
///
/// Affiche la liste des academiciens et permet d'acceder aux bilans de chacun.
class MedecinBilansScreen extends StatefulWidget {
  const MedecinBilansScreen({super.key});

  @override
  State<MedecinBilansScreen> createState() => MedecinBilansScreenState();
}

class MedecinBilansScreenState extends State<MedecinBilansScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Academicien> _academicians = [];
  List<Academicien> _filteredAcademicians = [];
  Map<String, PosteFootball> _postesMap = {};
  bool _isLoading = true;

  final List<StreamSubscription<dynamic>> _academicienEventsSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _listenToAcademicienEvents();
    _loadReferentielsAndAcademicians();
  }

  void _listenToAcademicienEvents() {
    _academicienEventsSubscriptions.add(
      DependencyInjection.domainEventBus
          .on<AcademicienCreatedEvent>()
          .listen((_) => _loadAcademicians()),
    );
    _academicienEventsSubscriptions.add(
      DependencyInjection.domainEventBus
          .on<AcademicienUpdatedEvent>()
          .listen((_) => _loadAcademicians()),
    );
  }

  Future<void> _loadReferentielsAndAcademicians() async {
    if (!mounted || _isLoading) return;
    final postes = await DependencyInjection.referentielService.getAllPostes();
    _postesMap = {for (final p in postes) p.id: p};
    if (mounted) {
      await _loadAcademicians();
    }
  }

  Future<void> _loadAcademicians() async {
    if (!mounted || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final results = await DependencyInjection.academicienRepository.getAll();
      if (mounted) {
        setState(() {
          _academicians = results;
          _filteredAcademicians = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    if (_isLoading) return;
    await DependencyInjection.academicienRepository.syncFromApi();
    DependencyInjection.academicienRepository.clearCache();
    await _loadAcademicians();
  }

  /// Recharge les academiciens depuis le cache local lorsque l'onglet redevient visible.
  Future<void> reload() async {
    await _loadReferentielsAndAcademicians();
  }

  String _getPosteName(String posteId) {
    return _postesMap[posteId]?.nom ??
        AppLocalizations.of(context)!.notSpecified;
  }

  void _onSearch(String query) {
    setState(() {
      _filteredAcademicians = _academicians.where((a) {
        final fullName = '${a.prenom} ${a.nom}'.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _openBilans(Academicien academicien) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BilanMedicalListPage(academicien: academicien),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
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
                child: _buildSearchBar(colorScheme, isDark, l10n),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_filteredAcademicians.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(colorScheme, l10n),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildAcademicienCard(
                          _filteredAcademicians[index],
                          colorScheme,
                          isDark,
                          l10n,
                        );
                      },
                      childCount: _filteredAcademicians.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bilansTitle,
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.bilansSubtitle,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: l10n.searchAcademicianHint,
            hintStyle: GoogleFonts.montserrat(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          style: GoogleFonts.montserrat(),
        ),
      ),
    );
  }

  Widget _buildAcademicienCard(
    Academicien academicien,
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openBilans(academicien),
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: academicien.photoUrl.isNotEmpty
                    ? NetworkImage(academicien.photoUrl)
                    : null,
                child: academicien.photoUrl.isEmpty
                    ? Icon(Icons.person_rounded, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${academicien.prenom} ${academicien.nom}',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPosteName(academicien.posteFootballId),
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
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
              Icons.people_outline_rounded,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noAcademicianFound,
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

  @override
  void dispose() {
    for (final sub in _academicienEventsSubscriptions) {
      sub.cancel();
    }
    _academicienEventsSubscriptions.clear();
    _searchController.dispose();
    super.dispose();
  }
}
