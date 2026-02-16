import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/poste_football.dart';
import '../../../domain/entities/niveau_scolaire.dart';
import '../../../infrastructure/repositories/academicien_repository_impl.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import 'academicien_registration_page.dart';
import 'academicien_profile_page.dart';

/// Page affichant la liste de tous les academiciens (joueurs) enregistres.
/// Permet la recherche, le filtrage par poste et la consultation des profils.
class AcademicienListPage extends StatefulWidget {
  final AcademicienRepositoryImpl repository;

  const AcademicienListPage({super.key, required this.repository});

  @override
  State<AcademicienListPage> createState() => _AcademicienListPageState();
}

class _AcademicienListPageState extends State<AcademicienListPage> {
  List<Academicien> _academiciens = [];
  List<Academicien> _filteredAcademiciens = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _selectedFilter = 'Tous';

  // Filtres dynamiques construits a partir des postes du referentiel
  List<String> _filters = ['Tous'];

  // Correspondance posteId -> PosteFootball chargee depuis le referentiel
  Map<String, PosteFootball> _postesMap = {};

  // Correspondance niveauId -> NiveauScolaire chargee depuis le referentiel
  Map<String, NiveauScolaire> _niveauxMap = {};

  @override
  void initState() {
    super.initState();
    _loadReferentielsAndAcademiciens();
  }

  Future<void> _loadReferentielsAndAcademiciens() async {
    final postes = await DependencyInjection.referentielService.getAllPostes();
    final niveaux = await DependencyInjection.referentielService
        .getAllNiveaux();
    _postesMap = {for (final p in postes) p.id: p};
    _niveauxMap = {for (final n in niveaux) n.id: n};
    _filters = ['Tous', ...postes.map((p) => p.nom)];
    await _loadAcademiciens();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAcademiciens() async {
    setState(() => _isLoading = true);
    try {
      final list = await widget.repository.getAll();
      setState(() {
        _academiciens = list;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getPosteName(String posteId) {
    return _postesMap[posteId]?.nom ?? 'Non specifie';
  }

  String _getNiveauName(String niveauId) {
    return _niveauxMap[niveauId]?.nom ?? 'Non specifie';
  }

  void _applyFilters() {
    List<Academicien> result = List.from(_academiciens);

    // Filtre par nom de poste
    if (_selectedFilter != 'Tous') {
      result = result.where((a) {
        return _getPosteName(a.posteFootballId) == _selectedFilter;
      }).toList();
    }

    // Filtre par recherche
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((a) {
        return a.nom.toLowerCase().contains(query) ||
            a.prenom.toLowerCase().contains(query) ||
            a.telephoneParent.contains(query) ||
            _getPosteName(a.posteFootballId).toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredAcademiciens = result);
  }

  Future<void> _navigateToRegistration() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AcademicienRegistrationPage(),
      ),
    );
    if (result == true) {
      _loadAcademiciens();
    }
  }

  void _navigateToProfile(Academicien academicien) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AcademicienProfilePage(
          academicien: academicien,
          repository: widget.repository,
          postesMap: _postesMap,
          niveauxMap: _niveauxMap,
        ),
      ),
    ).then((_) => _loadAcademiciens());
  }

  int _calculateAge(DateTime dateNaissance) {
    final now = DateTime.now();
    int age = now.year - dateNaissance.year;
    if (now.month < dateNaissance.month ||
        (now.month == dateNaissance.month && now.day < dateNaissance.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(colorScheme)),
            SliverToBoxAdapter(child: _buildSearchBar(colorScheme, isDark)),
            SliverToBoxAdapter(child: _buildFilterChips(colorScheme)),
            SliverToBoxAdapter(child: _buildQuickStats(colorScheme, isDark)),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredAcademiciens.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(colorScheme))
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildAcademicienCard(
                          _filteredAcademiciens[index],
                          colorScheme,
                          isDark,
                          index,
                        );
                      }, childCount: _filteredAcademiciens.length),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Joueurs',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  'Academiciens inscrits a l\'academie',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sports_soccer_rounded,
                  color: Color(0xFF3B82F6),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_academiciens.length}',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B82F6),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
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
            Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: 'Rechercher un joueur...',
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _applyFilters();
                },
                child: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
                _applyFilters();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                child: Center(
                  child: Text(
                    filter,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStats(ColorScheme colorScheme, bool isDark) {
    final gardiens = _academiciens
        .where((a) => a.posteFootballId == '1')
        .length;
    final defenseurs = _academiciens
        .where((a) => ['2', '3', '4'].contains(a.posteFootballId))
        .length;
    final milieux = _academiciens
        .where((a) => ['5', '6', '7'].contains(a.posteFootballId))
        .length;
    final attaquants = _academiciens
        .where((a) => ['8', '9', '10'].contains(a.posteFootballId))
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Total',
              value: '${_academiciens.length}',
              icon: Icons.people_rounded,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Gardiens',
              value: '$gardiens',
              icon: Icons.pan_tool_rounded,
              color: const Color(0xFFF59E0B),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Def.',
              value: '$defenseurs',
              icon: Icons.security_rounded,
              color: const Color(0xFF10B981),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Mil.',
              value: '$milieux',
              icon: Icons.repeat_rounded,
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Att.',
              value: '$attaquants',
              icon: Icons.sports_soccer_rounded,
              color: AppColors.primary,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicienCard(
    Academicien acad,
    ColorScheme colorScheme,
    bool isDark,
    int index,
  ) {
    final age = _calculateAge(acad.dateNaissance);
    final posteName = _getPosteName(acad.posteFootballId);
    final niveauName = _getNiveauName(acad.niveauScolaireId);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _navigateToProfile(acad),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child:
                      acad.photoUrl.isNotEmpty &&
                          File(acad.photoUrl).existsSync()
                      ? Image.file(File(acad.photoUrl), fit: BoxFit.cover)
                      : Container(
                          color: const Color(
                            0xFF3B82F6,
                          ).withValues(alpha: 0.08),
                          child: Center(
                            child: Text(
                              '${acad.prenom.isNotEmpty ? acad.prenom[0] : ''}${acad.nom.isNotEmpty ? acad.nom[0] : ''}',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3B82F6),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${acad.prenom} ${acad.nom}',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            posteName,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            niveauName,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$age ans',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                size: 48,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun joueur',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedFilter != 'Tous'
                  ? 'Aucun resultat pour cette recherche.\nEssayez avec d\'autres criteres.'
                  : 'Commencez par inscrire votre\npremier academicien pour demarrer.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (_searchController.text.isEmpty && _selectedFilter == 'Tous')
              ElevatedButton.icon(
                onPressed: _navigateToRegistration,
                icon: const Icon(Icons.person_add_rounded, size: 20),
                label: Text(
                  'Inscrire un joueur',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _navigateToRegistration,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.person_add_rounded, size: 20),
      label: Text(
        'Inscrire',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

/// Widget de statistique compacte.
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final ColorScheme colorScheme;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 9,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
