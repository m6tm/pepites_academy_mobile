import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/niveau_scolaire.dart';
import '../../../../domain/entities/poste_football.dart';
import '../../../../injection_container.dart';
import '../../../theme/app_colors.dart';

/// Ecran presentant la liste des academiciens pour le suivi medical.
/// Design aligne sur le design system de l'application (cartes, ombres, animations,
/// typographies et hierarchie visuelle).
class MedecinAcademyScreen extends StatefulWidget {
  const MedecinAcademyScreen({super.key});

  @override
  State<MedecinAcademyScreen> createState() => _MedecinAcademyScreenState();
}

class _MedecinAcademyScreenState extends State<MedecinAcademyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Academicien> _academicians = [];
  List<Academicien> _filteredAcademicians = [];
  bool _isLoading = true;

  Map<String, PosteFootball> _postesMap = {};
  Map<String, NiveauScolaire> _niveauxMap = {};

  @override
  void initState() {
    super.initState();
    _loadReferentielsAndAcademicians();
  }

  Future<void> _loadReferentielsAndAcademicians() async {
    final postes = await DependencyInjection.referentielService.getAllPostes();
    final niveaux = await DependencyInjection.referentielService.getAllNiveaux();
    _postesMap = {for (final p in postes) p.id: p};
    _niveauxMap = {for (final n in niveaux) n.id: n};
    if (mounted) {
      await _loadAcademicians();
    }
  }

  /// Rafraichit les donnees depuis le backend, vide le cache memoire
  /// puis recharge la liste locale.
  Future<void> _onRefresh() async {
    await DependencyInjection.academicienRepository.syncFromApi();
    DependencyInjection.academicienRepository.clearCache();
    await _loadAcademicians();
  }

  Future<void> _loadAcademicians() async {
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

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = query.isNotEmpty;
    });

    if (query.isEmpty) {
      _loadAcademicians();
      return;
    }

    try {
      final results = await DependencyInjection.academicienRepository.search(
        query,
      );
      if (mounted) {
        setState(() {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getPosteName(String posteId) {
    return _postesMap[posteId]?.nom ??
        AppLocalizations.of(context)!.notSpecified;
  }

  String _getNiveauName(String niveauId) {
    return _niveauxMap[niveauId]?.nom ??
        AppLocalizations.of(context)!.notSpecified;
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(colorScheme, l10n)),
            SliverToBoxAdapter(
              child: _buildSearchBar(colorScheme, isDark, l10n),
            ),
            SliverToBoxAdapter(
              child: _buildQuickStats(colorScheme, isDark),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredAcademicians.isEmpty
                ? SliverFillRemaining(
                    child: _buildEmptyState(colorScheme, l10n),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildAcademicienCard(
                          _filteredAcademicians[index],
                          colorScheme,
                          isDark,
                          index,
                        );
                      }, childCount: _filteredAcademicians.length),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicalFiles,
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Consultez et gerez les dossiers medicaux',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
                  Icons.folder_shared_rounded,
                  color: Color(0xFF3B82F6),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_academicians.length}',
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

  Widget _buildSearchBar(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
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
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: l10n.searchMedicalFile,
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
                  _search('');
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

  Widget _buildQuickStats(ColorScheme colorScheme, bool isDark) {
    final allergies = _academicians.where((a) => a.aAllergie == true).length;
    final peau = _academicians.where((a) => a.aProblemesPeau == true).length;
    final contacts = _academicians
        .where((a) => a.telephoneParent.isNotEmpty)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Total',
              value: '${_academicians.length}',
              icon: Icons.people_rounded,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Allergies',
              value: '$allergies',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFF59E0B),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Peau',
              value: '$peau',
              icon: Icons.healing_rounded,
              color: const Color(0xFFDC2626),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Contacts',
              value: '$contacts',
              icon: Icons.contact_phone_rounded,
              color: const Color(0xFF10B981),
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
        onTap: () {
          // TODO: Naviguer vers le detail medical de l'academicien (ST-03)
        },
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
                  child: _buildAvatarImage(acad),
                ),
              ),
              const SizedBox(width: 14),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                        Text(
                          '$age ans',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        if (acad.aAllergie == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFDC2626,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 10,
                                  color: Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Allergie',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
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

  Widget _buildAvatarImage(Academicien acad) {
    final initials =
        '${acad.prenom.isNotEmpty ? acad.prenom[0] : ''}${acad.nom.isNotEmpty ? acad.nom[0] : ''}';
    final fallback = Container(
      color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3B82F6),
            fontSize: 18,
          ),
        ),
      ),
    );

    if (acad.photoUrl.isEmpty) return fallback;

    final isRemote = acad.photoUrl.startsWith('http');
    if (isRemote) {
      return Image.network(
        acad.photoUrl,
        fit: BoxFit.cover,
        width: 56,
        height: 56,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    final file = File(acad.photoUrl);
    if (!file.existsSync()) return fallback;
    return Image.file(file, fit: BoxFit.cover);
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
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
                Icons.folder_open_rounded,
                size: 48,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noPlayerFound,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? l10n.noSearchResult
                  : 'Aucun dossier medical disponible',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de statistique compacte pour la ligne de stats medicale.
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
