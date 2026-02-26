import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../../domain/entities/annotation.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/atelier.dart';
import '../widgets/encadreur_internal_widgets.dart';

/// Ecran Annotations du dashboard encadreur.
/// Observations et evaluations des academiciens avec filtres par tags.
class EncadreurAnnotationsScreen extends StatefulWidget {
  const EncadreurAnnotationsScreen({super.key});

  @override
  State<EncadreurAnnotationsScreen> createState() =>
      _EncadreurAnnotationsScreenState();
}

class _EncadreurAnnotationsScreenState
    extends State<EncadreurAnnotationsScreen> {
  bool _isLoading = false;
  String? _error;

  bool _isRefreshingFromRemote = false;

  String _selectedFilter = 'all';
  List<Annotation> _annotations = [];

  static const Set<String> _positifTags = {
    'positif',
    'excellent',
    'en progres',
    'bonne attitude',
    'creatif',
  };

  static const Set<String> _toWorkOnTags = {
    'a travailler',
    'insuffisant',
    'manque d\'effort',
    'distrait',
  };

  static const Set<String> _techniqueTags = {
    'technique',
    'dribble',
    'passe',
    'tir',
    'placement',
    'endurance',
  };

  final Map<String, Academicien?> _academicienCache = {};
  final Map<String, Atelier?> _atelierCache = {};

  @override
  void initState() {
    super.initState();
    _chargerLocal(showLoading: true);
  }

  Future<void> _chargerLocal({required bool showLoading}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      // En mode refresh, on conserve l'affichage actuel.
      _error = null;
    }

    try {
      final encadreurId = await DependencyInjection.preferences.getUserId();
      if (encadreurId == null || encadreurId.isEmpty) {
        setState(() {
          _annotations = [];
          _isLoading = false;
          _error = 'Utilisateur non connecté.';
        });
        return;
      }

      final list = await DependencyInjection.annotationRepository
          .getByEncadreur(encadreurId);

      for (final a in list) {
        _academicienCache[a.academicienId] ??= await DependencyInjection
            .academicienRepository
            .getById(a.academicienId);
        _atelierCache[a.atelierId] ??= await DependencyInjection
            .atelierRepository
            .getById(a.atelierId);
      }

      if (!mounted) return;
      setState(() {
        _annotations = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refreshOfflineFirst() async {
    // 1) Affiche d'abord les données locales (sans vider l'écran)
    await _chargerLocal(showLoading: false);

    // 2) Si connecté, fetch backend en arrière-plan, puis recharge local
    try {
      final isConnected = await DependencyInjection.connectivityService
          .isConnected();
      if (!isConnected) return;

      if (!mounted) return;
      setState(() => _isRefreshingFromRemote = true);

      await DependencyInjection.annotationRepository.syncFromApi();
      await _chargerLocal(showLoading: false);
    } finally {
      if (mounted) setState(() => _isRefreshingFromRemote = false);
    }
  }

  List<Annotation> get _filtered {
    if (_selectedFilter == 'all') return _annotations;
    return _annotations.where((a) {
      final tags = a.tags.map((t) => t.toLowerCase()).toSet();

      if (_selectedFilter == 'positif') {
        return tags.intersection(_positifTags).isNotEmpty;
      }
      if (_selectedFilter == 'en progres') {
        return tags.contains('en progres');
      }
      if (_selectedFilter == 'a travailler') {
        return tags.intersection(_toWorkOnTags).isNotEmpty;
      }
      if (_selectedFilter == 'technique') {
        return tags.intersection(_techniqueTags).isNotEmpty;
      }

      return tags.contains(_selectedFilter);
    }).toList();
  }

  int get _positivesCount {
    return _annotations.where((a) {
      final tags = a.tags.map((t) => t.toLowerCase()).toSet();
      return tags.intersection(_positifTags).isNotEmpty;
    }).length;
  }

  int get _toWorkOnCount {
    return _annotations.where((a) {
      final tags = a.tags.map((t) => t.toLowerCase()).toSet();
      return tags.intersection(_toWorkOnTags).isNotEmpty;
    }).length;
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    return intl.DateFormat('dd/MM/yyyy').format(date);
  }

  List<AnnotationData> _buildViewModels(List<Annotation> list) {
    return list.map((a) {
      final academicien = _academicienCache[a.academicienId];
      final atelier = _atelierCache[a.atelierId];
      final academicienNom = academicien == null
          ? a.academicienId
          : '${academicien.prenom} ${academicien.nom}'.trim();
      final atelierNom = atelier?.nom ?? a.atelierId;
      return AnnotationData(
        academicienNom,
        atelierNom,
        a.contenu,
        a.tags,
        _formatTimeAgo(a.horodate),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final filtered = _filtered;
    final viewModels = _buildViewModels(filtered);

    return RefreshIndicator(
      onRefresh: _refreshOfflineFirst,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.annotationsScreenTitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.myObservationsSubtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  if (_isRefreshingFromRemote) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 2,
                      child: LinearProgressIndicator(
                        backgroundColor: colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: MiniAnnotCard(
                      label: l10n.totalLabel,
                      value: _annotations.length.toString(),
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MiniAnnotCard(
                      label: l10n.positivesLabel,
                      value: _positivesCount.toString(),
                      icon: Icons.thumb_up_rounded,
                      color: const Color(0xFF10B981),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MiniAnnotCard(
                      label: l10n.toWorkOnLabel,
                      value: _toWorkOnCount.toString(),
                      icon: Icons.warning_rounded,
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildAnnotationTags(context, colorScheme)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (viewModels.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Text(
                  l10n.noAnnotationRecorded,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final data = viewModels[index];
                return AnnotationListItem(data: data, isDark: isDark);
              }, childCount: viewModels.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAnnotationTags(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;

    final tags = <(String label, String key)>[
      (l10n.allTagFilter, 'all'),
      (l10n.tagPositif, 'positif'),
      (l10n.inProgressTagFilter, 'en progres'),
      (l10n.toWorkOnLabel, 'a travailler'),
      (l10n.techniqueTagFilter, 'technique'),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final (label, key) = tags[index];
          final isSelected = _selectedFilter == key;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = key);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? null
                    : Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                      ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
