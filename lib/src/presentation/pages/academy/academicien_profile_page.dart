import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/poste_football.dart';
import '../../../domain/entities/niveau_scolaire.dart';
import '../../../infrastructure/repositories/academicien_repository_impl.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../bulletin/bulletin_page.dart';
import 'academicien_edit_page.dart';

/// Page de consultation du profil d'un academicien (joueur).
/// Affiche les informations completes, le badge QR et les statistiques.
class AcademicienProfilePage extends StatefulWidget {
  final Academicien academicien;
  final AcademicienRepositoryImpl repository;
  final Map<String, PosteFootball> postesMap;
  final Map<String, NiveauScolaire> niveauxMap;

  const AcademicienProfilePage({
    super.key,
    required this.academicien,
    required this.repository,
    required this.postesMap,
    required this.niveauxMap,
  });

  @override
  State<AcademicienProfilePage> createState() => _AcademicienProfilePageState();
}

class _AcademicienProfilePageState extends State<AcademicienProfilePage>
    with SingleTickerProviderStateMixin {
  late Academicien _academicien;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _academicien = widget.academicien;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getPosteName() {
    return widget.postesMap[_academicien.posteFootballId]?.nom ??
        'Non specifie';
  }

  String _getNiveauName() {
    return widget.niveauxMap[_academicien.niveauScolaireId]?.nom ??
        'Non specifie';
  }

  int _calculateAge() {
    final now = DateTime.now();
    int age = now.year - _academicien.dateNaissance.year;
    if (now.month < _academicien.dateNaissance.month ||
        (now.month == _academicien.dateNaissance.month &&
            now.day < _academicien.dateNaissance.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Supprimer le joueur',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Etes-vous sur de vouloir supprimer ${_academicien.prenom} ${_academicien.nom} ? '
          'Cette action est irreversible.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final nomComplet = '${_academicien.prenom} ${_academicien.nom}';
              final academicienId = _academicien.id;
              navigator.pop();
              await DependencyInjection.activityService
                  .enregistrerAcademicienSupprime(nomComplet, academicienId);
              await widget.repository.delete(academicienId);
              if (mounted) navigator.pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Supprimer',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _ouvrirBulletin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BulletinPage(academicien: _academicien),
      ),
    );
  }

  void _ouvrirEdition() {
    Navigator.push<Academicien>(
      context,
      MaterialPageRoute(
        builder: (_) => AcademicienEditPage(
          academicien: _academicien,
          repository: widget.repository,
          postesMap: widget.postesMap,
          niveauxMap: widget.niveauxMap,
        ),
      ),
    ).then((updated) {
      if (updated != null && mounted) {
        setState(() => _academicien = updated);
      }
    });
  }

  void _showQrFullScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QrFullScreenSheet(
        academicien: _academicien,
        posteName: _getPosteName(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(colorScheme, isDark),
          SliverToBoxAdapter(child: _buildIdentityCard(colorScheme, isDark)),
          SliverToBoxAdapter(child: _buildStatsRow(colorScheme, isDark)),
          SliverToBoxAdapter(child: _buildTabBar(colorScheme)),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(colorScheme, isDark),
                _buildSportTab(colorScheme, isDark),
                _buildQrTab(colorScheme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ColorScheme colorScheme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => _buildOptionsSheet(colorScheme),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child:
                          _academicien.photoUrl.isNotEmpty &&
                              File(_academicien.photoUrl).existsSync()
                          ? Image.file(
                              File(_academicien.photoUrl),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.white.withValues(alpha: 0.2),
                              child: Center(
                                child: Text(
                                  '${_academicien.prenom.isNotEmpty ? _academicien.prenom[0] : ''}${_academicien.nom.isNotEmpty ? _academicien.nom[0] : ''}',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_academicien.prenom} ${_academicien.nom}',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_getPosteName()} - ${_calculateAge()} ans',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard(ColorScheme colorScheme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Expanded(
            child: _InfoChip(
              icon: Icons.school_outlined,
              label: 'Niveau',
              value: _getNiveauName(),
              colorScheme: colorScheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          Expanded(
            child: _InfoChip(
              icon: Icons.directions_run_rounded,
              label: 'Pied fort',
              value: _academicien.piedFort ?? 'N/A',
              colorScheme: colorScheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          Expanded(
            child: _InfoChip(
              icon: Icons.cake_outlined,
              label: 'Age',
              value: '${_calculateAge()} ans',
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              value: '0',
              label: 'Seances',
              icon: Icons.event_rounded,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatTile(
              value: '0',
              label: 'Evaluations',
              icon: Icons.star_rounded,
              color: const Color(0xFFF59E0B),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatTile(
              value: '0',
              label: 'Presences',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
        labelStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Infos'),
          Tab(text: 'Sport'),
          Tab(text: 'Badge QR'),
        ],
      ),
    );
  }

  Widget _buildInfoTab(ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Informations personnelles',
            Icons.person_rounded,
            [
              _InfoRowData(label: 'Nom', value: _academicien.nom),
              _InfoRowData(label: 'Prenom', value: _academicien.prenom),
              _InfoRowData(
                label: 'Date de naissance',
                value: _formatDate(_academicien.dateNaissance),
              ),
              _InfoRowData(label: 'Age', value: '${_calculateAge()} ans'),
              _InfoRowData(
                label: 'Telephone parent',
                value: _academicien.telephoneParent,
              ),
            ],
            colorScheme,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            'Identifiants',
            Icons.qr_code_rounded,
            [
              _InfoRowData(label: 'ID', value: _academicien.id),
              _InfoRowData(label: 'Code QR', value: _academicien.codeQrUnique),
            ],
            colorScheme,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSportTab(ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Profil sportif',
            Icons.sports_soccer_rounded,
            [
              _InfoRowData(label: 'Poste', value: _getPosteName()),
              _InfoRowData(
                label: 'Pied fort',
                value: _academicien.piedFort ?? 'Non specifie',
              ),
            ],
            colorScheme,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            'Scolarite',
            Icons.school_rounded,
            [_InfoRowData(label: 'Niveau', value: _getNiveauName())],
            colorScheme,
            isDark,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _ouvrirBulletin,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assessment_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bulletin de formation',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Consulter et generer le bulletin\nde formation periodique.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Acceder au bulletin',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.white,
                      ),
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

  Widget _buildQrTab(ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showQrFullScreen,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PEPITES ACADEMY',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 3,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ACADEMICIEN',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 2,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  QrImageView(
                    data: _academicien.codeQrUnique,
                    version: QrVersions.auto,
                    size: 200,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF1C1C1C),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${_academicien.prenom} ${_academicien.nom}',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: const Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPosteName(),
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _academicien.codeQrUnique,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Appuyez sur le badge pour l\'agrandir',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    'Partager',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    'Telecharger',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    IconData icon,
    List<_InfoRowData> rows,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildOptionsSheet(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _OptionItem(
            icon: Icons.qr_code_rounded,
            label: 'Voir le badge QR',
            color: const Color(0xFF3B82F6),
            onTap: () {
              Navigator.pop(context);
              _showQrFullScreen();
            },
          ),
          _OptionItem(
            icon: Icons.assessment_rounded,
            label: 'Bulletin de formation',
            color: AppColors.primary,
            onTap: () {
              Navigator.pop(context);
              _ouvrirBulletin();
            },
          ),
          _OptionItem(
            icon: Icons.edit_rounded,
            label: 'Modifier le profil',
            color: const Color(0xFFF59E0B),
            onTap: () {
              Navigator.pop(context);
              _ouvrirEdition();
            },
          ),
          _OptionItem(
            icon: Icons.share_rounded,
            label: 'Partager le profil',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
          _OptionItem(
            icon: Icons.delete_outline_rounded,
            label: 'Supprimer le joueur',
            color: AppColors.error,
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Feuille modale plein ecran pour le QR code.
class _QrFullScreenSheet extends StatelessWidget {
  final Academicien academicien;
  final String posteName;

  const _QrFullScreenSheet({
    required this.academicien,
    required this.posteName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'PEPITES ACADEMY',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'BADGE ACADEMICIEN',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 2,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ),
          const Spacer(),
          QrImageView(
            data: academicien.codeQrUnique,
            version: QrVersions.auto,
            size: 280,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFF1C1C1C),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const Spacer(),
          Text(
            '${academicien.prenom} ${academicien.nom}',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            posteName,
            style: GoogleFonts.montserrat(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              academicien.codeQrUnique,
              style: GoogleFonts.sourceCodePro(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoRowData {
  final String label;
  final String value;
  const _InfoRowData({required this.label, required this.value});
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final ColorScheme colorScheme;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: color == AppColors.error ? AppColors.error : null,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
