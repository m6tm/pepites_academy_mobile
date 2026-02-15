import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../application/services/search_service.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/encadreur.dart';
import '../../../domain/entities/seance.dart';
import '../../../injection_container.dart';
import '../../state/search_state.dart';
import '../../theme/app_colors.dart';
import 'academicien_detail_page.dart';
import 'encadreur_detail_page.dart';
import 'seance_detail_consultation_page.dart';

/// Page de recherche universelle.
/// Permet de rechercher des academiciens, encadreurs et seances
/// avec filtres par categorie et historique des recherches recentes.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late final SearchState _searchState;
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchState = DependencyInjection.searchState;
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _searchState.addListener(_onStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchState.removeListener(_onStateChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(colorScheme, isDark),
              _buildCategoryFilters(colorScheme, isDark),
              Expanded(
                child: _searchState.query.isEmpty
                    ? _buildHistoriqueSection(colorScheme, isDark)
                    : _buildResultatsSection(colorScheme, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// En-tete avec barre de recherche.
  Widget _buildHeader(ColorScheme colorScheme, bool isDark) {
    final baseColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: baseColor.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      _searchState.rechercher(value);
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _searchState.ajouterAHistorique(value.trim());
                      }
                    },
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Rechercher un academicien, encadreur, seance...',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _searchState.reinitialiser();
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                                size: 20,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Filtres par categorie (chips horizontaux).
  Widget _buildCategoryFilters(ColorScheme colorScheme, bool isDark) {
    final categories = [
      _CategoryChipData('Tous', SearchCategory.tous, Icons.apps_rounded),
      _CategoryChipData(
        'Academiciens',
        SearchCategory.academiciens,
        Icons.school_rounded,
      ),
      _CategoryChipData(
        'Encadreurs',
        SearchCategory.encadreurs,
        Icons.sports_rounded,
      ),
      _CategoryChipData(
        'Seances',
        SearchCategory.seances,
        Icons.calendar_today_rounded,
      ),
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = _searchState.categorieActive == cat.categorie;

          return GestureDetector(
            onTap: () => _searchState.setCategorie(cat.categorie),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : colorScheme.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 16,
                    color: isActive
                        ? Colors.white
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
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

  /// Section affichant l'historique des recherches recentes.
  Widget _buildHistoriqueSection(ColorScheme colorScheme, bool isDark) {
    if (_searchState.historique.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recherches recentes',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => _searchState.viderHistorique(),
                child: Text(
                  'Tout effacer',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _searchState.historique.length,
            itemBuilder: (context, index) {
              final item = _searchState.historique[index];
              return _buildHistoriqueItem(item, colorScheme);
            },
          ),
        ),
      ],
    );
  }

  /// Element de l'historique de recherche.
  Widget _buildHistoriqueItem(String query, ColorScheme colorScheme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.history_rounded,
          size: 18,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
      title: Text(
        query,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: GestureDetector(
        onTap: () => _searchState.supprimerDeHistorique(query),
        child: Icon(
          Icons.close_rounded,
          size: 18,
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
      onTap: () {
        _searchController.text = query;
        _searchState.rechercher(query);
      },
    );
  }

  /// Etat vide quand aucun historique.
  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.search_rounded,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recherche universelle',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Trouvez rapidement un academicien, un encadreur ou une seance.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.45),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section affichant les resultats de recherche.
  Widget _buildResultatsSection(ColorScheme colorScheme, bool isDark) {
    if (_searchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_searchState.resultats.isEmpty) {
      return _buildNoResultsState(colorScheme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _searchState.resultats.length,
      itemBuilder: (context, index) {
        final result = _searchState.resultats[index];
        return _buildResultItem(result, colorScheme, isDark);
      },
    );
  }

  /// Etat "aucun resultat".
  Widget _buildNoResultsState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun resultat',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Essayez avec d\'autres termes de recherche.',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  /// Element de resultat de recherche.
  Widget _buildResultItem(
    SearchResult result,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final categoryData = _getCategoryVisual(result.categorie);

    return GestureDetector(
      onTap: () => _naviguerVersDetail(result),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: categoryData.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                categoryData.icon,
                color: categoryData.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.titre,
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
                    result.sousTitre,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: categoryData.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                categoryData.label,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: categoryData.color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation vers la fiche de consultation detaillee.
  void _naviguerVersDetail(SearchResult result) {
    _searchState.ajouterAHistorique(_searchState.query);

    switch (result.categorie) {
      case SearchCategory.academiciens:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AcademicienDetailPage(
              academicien: result.entite as Academicien,
            ),
          ),
        );
        break;
      case SearchCategory.encadreurs:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                EncadreurDetailPage(encadreur: result.entite as Encadreur),
          ),
        );
        break;
      case SearchCategory.seances:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                SeanceDetailConsultationPage(seance: result.entite as Seance),
          ),
        );
        break;
      case SearchCategory.tous:
        break;
    }
  }

  /// Retourne les informations visuelles pour une categorie.
  _CategoryVisual _getCategoryVisual(SearchCategory categorie) {
    switch (categorie) {
      case SearchCategory.academiciens:
        return _CategoryVisual(
          icon: Icons.school_rounded,
          color: const Color(0xFF3B82F6),
          label: 'Joueur',
        );
      case SearchCategory.encadreurs:
        return _CategoryVisual(
          icon: Icons.sports_rounded,
          color: const Color(0xFF8B5CF6),
          label: 'Coach',
        );
      case SearchCategory.seances:
        return _CategoryVisual(
          icon: Icons.calendar_today_rounded,
          color: const Color(0xFF10B981),
          label: 'Seance',
        );
      case SearchCategory.tous:
        return _CategoryVisual(
          icon: Icons.apps_rounded,
          color: AppColors.primary,
          label: 'Tous',
        );
    }
  }
}

/// Donnees pour un chip de categorie.
class _CategoryChipData {
  final String label;
  final SearchCategory categorie;
  final IconData icon;

  const _CategoryChipData(this.label, this.categorie, this.icon);
}

/// Informations visuelles d'une categorie.
class _CategoryVisual {
  final IconData icon;
  final Color color;
  final String label;

  const _CategoryVisual({
    required this.icon,
    required this.color,
    required this.label,
  });
}
