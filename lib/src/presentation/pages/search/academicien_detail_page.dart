import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/annotation.dart';
import '../../../domain/entities/bulletin.dart';
import '../../../domain/entities/presence.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glassmorphism_card.dart';

/// Fiche de consultation detaillee d'un academicien.
/// Onglets : Infos, Presences, Annotations, Bulletins.
class AcademicienDetailPage extends StatefulWidget {
  final Academicien academicien;

  const AcademicienDetailPage({super.key, required this.academicien});

  @override
  State<AcademicienDetailPage> createState() => _AcademicienDetailPageState();
}

class _AcademicienDetailPageState extends State<AcademicienDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Presence> _presences = [];
  List<Annotation> _annotations = [];
  List<Bulletin> _bulletins = [];
  bool _isLoading = true;
  String _posteNom = '';
  String _niveauNom = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      final presences = await DependencyInjection.presenceRepository
          .getByProfil(widget.academicien.id);
      final annotations = await DependencyInjection.annotationRepository
          .getByAcademicien(widget.academicien.id);
      final bulletins = await DependencyInjection.bulletinRepository
          .getByAcademicien(widget.academicien.id);

      // Resolution des noms depuis les referentiels
      final postes = await DependencyInjection.referentielService
          .getAllPostes();
      final niveaux = await DependencyInjection.referentielService
          .getAllNiveaux();
      final posteMatch = postes.where(
        (p) => p.id == widget.academicien.posteFootballId,
      );
      final niveauMatch = niveaux.where(
        (n) => n.id == widget.academicien.niveauScolaireId,
      );

      if (mounted) {
        setState(() {
          _presences = presences;
          _annotations = annotations;
          _bulletins = bulletins;
          _posteNom = posteMatch.isNotEmpty
              ? posteMatch.first.nom
              : 'Non specifie';
          _niveauNom = niveauMatch.isNotEmpty
              ? niveauMatch.first.nom
              : 'Non specifie';
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
            _buildProfileHeader(colorScheme, isDark),
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
                        _buildPresencesTab(colorScheme, isDark),
                        _buildAnnotationsTab(colorScheme, isDark),
                        _buildBulletinsTab(colorScheme, isDark),
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
              'Fiche Academicien',
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

  /// En-tete avec photo et infos principales.
  Widget _buildProfileHeader(ColorScheme colorScheme, bool isDark) {
    final acad = widget.academicien;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF2D1215)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
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
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${acad.prenom.isNotEmpty ? acad.prenom[0] : ''}${acad.nom.isNotEmpty ? acad.nom[0] : ''}',
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
                  '${acad.prenom} ${acad.nom}',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ACADEMICIEN',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B82F6),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniStat(
                      Icons.check_circle_rounded,
                      '${_presences.length}',
                      'Presences',
                    ),
                    const SizedBox(width: 16),
                    _buildMiniStat(
                      Icons.edit_note_rounded,
                      '${_annotations.length}',
                      'Annotations',
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
        tabs: const [
          Tab(text: 'Infos'),
          Tab(text: 'Presences'),
          Tab(text: 'Notes'),
          Tab(text: 'Bulletins'),
        ],
      ),
    );
  }

  /// Onglet Informations generales.
  Widget _buildInfosTab(ColorScheme colorScheme, bool isDark) {
    final acad = widget.academicien;
    final age = DateTime.now().difference(acad.dateNaissance).inDays ~/ 365;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(
            colorScheme,
            isDark,
            'Informations personnelles',
            Icons.person_rounded,
            [
              _InfoRow('Nom complet', '${acad.prenom} ${acad.nom}'),
              _InfoRow('Age', '$age ans'),
              _InfoRow(
                'Date de naissance',
                '${acad.dateNaissance.day}/${acad.dateNaissance.month}/${acad.dateNaissance.year}',
              ),
              _InfoRow('Telephone parent', acad.telephoneParent),
              if (acad.piedFort != null) _InfoRow('Pied fort', acad.piedFort!),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            colorScheme,
            isDark,
            'Informations sportives',
            Icons.sports_soccer_rounded,
            [
              _InfoRow(
                'Poste',
                _posteNom.isNotEmpty ? _posteNom : acad.posteFootballId,
              ),
              _InfoRow(
                'Niveau scolaire',
                _niveauNom.isNotEmpty ? _niveauNom : acad.niveauScolaireId,
              ),
              _InfoRow('Code QR', acad.codeQrUnique),
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

  /// Onglet Presences.
  Widget _buildPresencesTab(ColorScheme colorScheme, bool isDark) {
    if (_presences.isEmpty) {
      return _buildEmptyTab(
        colorScheme,
        Icons.check_circle_outline_rounded,
        'Aucune presence enregistree',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _presences.length,
      itemBuilder: (context, index) {
        final presence = _presences[index];
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
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seance ${presence.seanceId.substring(0, 8)}...',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDateTime(presence.horodateArrivee),
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Present',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Onglet Annotations.
  Widget _buildAnnotationsTab(ColorScheme colorScheme, bool isDark) {
    if (_annotations.isEmpty) {
      return _buildEmptyTab(
        colorScheme,
        Icons.edit_note_rounded,
        'Aucune annotation enregistree',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _annotations.length,
      itemBuilder: (context, index) {
        final annotation = _annotations[index];
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateTime(annotation.horodate),
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        if (annotation.note != null)
                          Text(
                            'Note : ${annotation.note!.toStringAsFixed(1)}/10',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                annotation.contenu,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              if (annotation.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: annotation.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Onglet Bulletins.
  Widget _buildBulletinsTab(ColorScheme colorScheme, bool isDark) {
    if (_bulletins.isEmpty) {
      return _buildEmptyTab(
        colorScheme,
        Icons.description_outlined,
        'Aucun bulletin genere',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _bulletins.length,
      itemBuilder: (context, index) {
        final bulletin = _bulletins[index];
        return GlassmorphismCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bulletin.periodeLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${bulletin.competences.moyenne.toStringAsFixed(1)}/10',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildBulletinStat(
                    'Presence',
                    '${bulletin.tauxPresence.toStringAsFixed(0)}%',
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 16),
                  _buildBulletinStat(
                    'Seances',
                    '${bulletin.nbSeancesPresent}/${bulletin.nbSeancesTotal}',
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 16),
                  _buildBulletinStat(
                    'Annotations',
                    '${bulletin.nbAnnotationsTotal}',
                    const Color(0xFF8B5CF6),
                  ),
                ],
              ),
              if (bulletin.observationsGenerales.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  bulletin.observationsGenerales,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBulletinStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
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

  /// Formate une date en chaine lisible.
  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} a '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Ligne d'information label/valeur.
class _InfoRow {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);
}
