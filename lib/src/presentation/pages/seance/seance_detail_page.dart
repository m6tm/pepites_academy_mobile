import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/seance.dart';
import '../../theme/app_colors.dart';

/// Vue detaillee d'une seance affichant les encadreurs presents,
/// les academiciens et les ateliers programmes.
class SeanceDetailPage extends StatelessWidget {
  final Seance seance;

  const SeanceDetailPage({super.key, required this.seance});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, colorScheme),
          SliverToBoxAdapter(child: _buildStatusBanner(colorScheme)),
          SliverToBoxAdapter(child: _buildInfoSection(colorScheme, isDark)),
          SliverToBoxAdapter(child: _buildStatsRow(colorScheme, isDark)),
          SliverToBoxAdapter(
            child: _buildSectionTitle(
              'Encadreurs presents',
              Icons.person_rounded,
            ),
          ),
          SliverToBoxAdapter(child: _buildEncadreursList(colorScheme, isDark)),
          SliverToBoxAdapter(
            child: _buildSectionTitle('Academiciens', Icons.groups_rounded),
          ),
          SliverToBoxAdapter(
            child: _buildAcademiciensList(colorScheme, isDark),
          ),
          SliverToBoxAdapter(
            child: _buildSectionTitle(
              'Ateliers programmes',
              Icons.fitness_center_rounded,
            ),
          ),
          SliverToBoxAdapter(child: _buildAteliersList(colorScheme, isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: _statusColor.withValues(alpha: 0.95),
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
              colors: [_statusColor, _statusColor.withValues(alpha: 0.8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon, color: _statusColor, size: 22),
          const SizedBox(width: 10),
          Text(
            _statusLabel,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _statusColor,
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

  Widget _buildInfoSection(ColorScheme colorScheme, bool isDark) {
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
            label: 'Date',
            value: seance.dateFormatee,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: 'Horaire',
            value: seance.dureeFormatee,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.person_rounded,
            label: 'Responsable',
            value: seance.encadreurResponsableId == 'current_user'
                ? 'Moi'
                : seance.encadreurResponsableId,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _StatBox(
            icon: Icons.people_rounded,
            value: '${seance.nbPresents}',
            label: 'Presents',
            color: const Color(0xFF3B82F6),
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _StatBox(
            icon: Icons.sports_soccer_rounded,
            value: '${seance.atelierIds.length}',
            label: 'Ateliers',
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _StatBox(
            icon: Icons.group_rounded,
            value: '${seance.encadreurIds.length}',
            label: 'Encadreurs',
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

  Widget _buildEncadreursList(ColorScheme colorScheme, bool isDark) {
    if (seance.encadreurIds.isEmpty) {
      return _buildEmptyListMessage('Aucun encadreur enregistre', colorScheme);
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: seance.encadreurIds.length,
        itemBuilder: (context, index) {
          return _PersonChip(
            label: 'Encadreur ${index + 1}',
            color: const Color(0xFF10B981),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildAcademiciensList(ColorScheme colorScheme, bool isDark) {
    if (seance.academicienIds.isEmpty) {
      return _buildEmptyListMessage(
        'Aucun academicien enregistre',
        colorScheme,
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: seance.academicienIds.length,
        itemBuilder: (context, index) {
          return _PersonChip(
            label: 'Academicien ${index + 1}',
            color: const Color(0xFF3B82F6),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildAteliersList(ColorScheme colorScheme, bool isDark) {
    if (seance.atelierIds.isEmpty) {
      return _buildEmptyListMessage('Aucun atelier programme', colorScheme);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(seance.atelierIds.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Atelier ${index + 1}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ],
            ),
          );
        }),
      ),
    );
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

  Color get _statusColor {
    switch (seance.statut) {
      case SeanceStatus.ouverte:
        return const Color(0xFF10B981);
      case SeanceStatus.fermee:
        return AppColors.textMutedLight;
      case SeanceStatus.aVenir:
        return const Color(0xFF3B82F6);
    }
  }

  String get _statusLabel {
    switch (seance.statut) {
      case SeanceStatus.ouverte:
        return 'En cours';
      case SeanceStatus.fermee:
        return 'Terminee';
      case SeanceStatus.aVenir:
        return 'A venir';
    }
  }

  IconData get _statusIcon {
    switch (seance.statut) {
      case SeanceStatus.ouverte:
        return Icons.play_circle_rounded;
      case SeanceStatus.fermee:
        return Icons.check_circle_rounded;
      case SeanceStatus.aVenir:
        return Icons.schedule_rounded;
    }
  }
}

/// Ligne de detail avec icone, label et valeur.
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
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Boite de statistique compacte.
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

/// Chip representant une personne (encadreur ou academicien).
class _PersonChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _PersonChip({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            child: Center(
              child: Text(
                label[0],
                style: GoogleFonts.montserrat(
                  fontSize: 16,
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
}
