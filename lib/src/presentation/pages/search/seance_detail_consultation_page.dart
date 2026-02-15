import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/annotation.dart';
import '../../../domain/entities/atelier.dart';
import '../../../domain/entities/encadreur.dart';
import '../../../domain/entities/presence.dart';
import '../../../domain/entities/seance.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';

/// Fiche de consultation detaillee d'une seance d'entrainement.
/// Recapitulatif complet en lecture seule : infos, participants, ateliers, annotations.
class SeanceDetailConsultationPage extends StatefulWidget {
  final Seance seance;

  const SeanceDetailConsultationPage({super.key, required this.seance});

  @override
  State<SeanceDetailConsultationPage> createState() =>
      _SeanceDetailConsultationPageState();
}

class _SeanceDetailConsultationPageState
    extends State<SeanceDetailConsultationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Encadreur? _responsable;
  List<Encadreur> _encadreurs = [];
  List<Academicien> _academiciens = [];
  List<Atelier> _ateliers = [];
  List<Presence> _presences = [];
  List<Annotation> _annotations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    try {
      final responsable = await DependencyInjection.encadreurRepository
          .getById(widget.seance.encadreurResponsableId);

      final encadreurs = <Encadreur>[];
      for (final id in widget.seance.encadreurIds) {
        final enc =
            await DependencyInjection.encadreurRepository.getById(id);
        if (enc != null) encadreurs.add(enc);
      }

      final academiciens = <Academicien>[];
      for (final id in widget.seance.academicienIds) {
        final acad =
            await DependencyInjection.academicienRepository.getById(id);
        if (acad != null) academiciens.add(acad);
      }

      final ateliers = await DependencyInjection.atelierRepository
          .getBySeance(widget.seance.id);
      final presences = await DependencyInjection.presenceRepository
          .getBySeance(widget.seance.id);
      final annotations = await DependencyInjection.annotationRepository
          .getBySeance(widget.seance.id);

      if (mounted) {
        setState(() {
          _responsable = responsable;
          _encadreurs = encadreurs;
          _academiciens = academiciens;
          _ateliers = ateliers;
          _presences = presences;
          _annotations = annotations;
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
            _buildSeanceHeader(colorScheme),
            _buildTabBar(colorScheme),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRecapTab(colorScheme, isDark),
                        _buildParticipantsTab(colorScheme, isDark),
                        _buildAteliersTab(colorScheme, isDark),
                        _buildAnnotationsTab(colorScheme, isDark),
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
              'Detail Seance',
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

  /// En-tete avec infos principales de la seance.
  Widget _buildSeanceHeader(ColorScheme colorScheme) {
    final seance = widget.seance;
    final statusColor = _getStatusColor(seance.statut);
    final statusLabel = _getStatusLabel(seance.statut);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1C1C1C),
            statusColor.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                seance.dateFormatee,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            seance.titre,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            seance.dureeFormatee,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildHeaderChip(
                Icons.people_rounded,
                '${seance.nbPresents} presents',
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 12),
              _buildHeaderChip(
                Icons.fitness_center_rounded,
                '${_ateliers.length} ateliers',
                const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 12),
              _buildHeaderChip(
                Icons.edit_note_rounded,
                '${_annotations.length} notes',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
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
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 11,
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
          Tab(text: 'Recap'),
          Tab(text: 'Equipe'),
          Tab(text: 'Ateliers'),
          Tab(text: 'Notes'),
        ],
      ),
    );
  }

  /// Onglet Recapitulatif.
  Widget _buildRecapTab(ColorScheme colorScheme, bool isDark) {
    final seance = widget.seance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoCard(
            colorScheme,
            isDark,
            'Informations generales',
            Icons.info_outline_rounded,
            [
              _InfoRow('Titre', seance.titre),
              _InfoRow('Date', seance.dateFormatee),
              _InfoRow('Horaires', seance.dureeFormatee),
              _InfoRow(
                'Responsable',
                _responsable != null
                    ? _responsable!.nomComplet
                    : seance.encadreurResponsableId,
              ),
              _InfoRow('Statut', _getStatusLabel(seance.statut)),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            colorScheme,
            isDark,
            'Chiffres cles',
            Icons.bar_chart_rounded,
            [
              _InfoRow('Academiciens presents', '${seance.nbPresents}'),
              _InfoRow('Encadreurs', '${_encadreurs.length + 1}'),
              _InfoRow('Ateliers realises', '${_ateliers.length}'),
              _InfoRow('Annotations', '${_annotations.length}'),
              _InfoRow('Presences scannees', '${_presences.length}'),
            ],
          ),
        ],
      ),
    );
  }

  /// Onglet Participants (encadreurs + academiciens).
  Widget _buildParticipantsTab(ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encadreurs',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          if (_responsable != null)
            _buildParticipantTile(
              _responsable!.nomComplet,
              'Responsable - ${_responsable!.specialite}',
              const Color(0xFF8B5CF6),
              Icons.star_rounded,
              colorScheme,
              isDark,
            ),
          ..._encadreurs.map(
            (enc) => _buildParticipantTile(
              enc.nomComplet,
              enc.specialite,
              const Color(0xFF6366F1),
              Icons.sports_rounded,
              colorScheme,
              isDark,
            ),
          ),
          if (_responsable == null && _encadreurs.isEmpty)
            _buildEmptyInline(colorScheme, 'Aucun encadreur enregistre'),
          const SizedBox(height: 20),
          Text(
            'Academiciens (${_academiciens.length})',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          if (_academiciens.isEmpty)
            _buildEmptyInline(colorScheme, 'Aucun academicien enregistre')
          else
            ..._academiciens.map(
              (acad) => _buildParticipantTile(
                '${acad.prenom} ${acad.nom}',
                'Academicien',
                const Color(0xFF3B82F6),
                Icons.school_rounded,
                colorScheme,
                isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(
    String nom,
    String sousTitre,
    Color color,
    IconData icon,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  sousTitre,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInline(ColorScheme colorScheme, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          color: colorScheme.onSurface.withValues(alpha: 0.35),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  /// Onglet Ateliers.
  Widget _buildAteliersTab(ColorScheme colorScheme, bool isDark) {
    if (_ateliers.isEmpty) {
      return _buildEmptyTab(
        colorScheme,
        Icons.fitness_center_rounded,
        'Aucun atelier enregistre',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _ateliers.length,
      itemBuilder: (context, index) {
        final atelier = _ateliers[index];
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${atelier.ordre}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                    ),
                    const SizedBox(height: 3),
                    Text(
                      atelier.typeLabel,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                    if (atelier.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        atelier.description,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.55),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
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
                          'Acad. ${annotation.academicienId.substring(0, 8)}...',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _formatDateTime(annotation.horodate),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (annotation.note != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${annotation.note!.toStringAsFixed(1)}/10',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                        ),
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: annotation.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.08),
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
                      color:
                          colorScheme.onSurface.withValues(alpha: 0.5),
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} a '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
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
        return 'En cours';
      case SeanceStatus.fermee:
        return 'Terminee';
      case SeanceStatus.aVenir:
        return 'A venir';
    }
  }
}

/// Ligne d'information label/valeur.
class _InfoRow {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);
}
