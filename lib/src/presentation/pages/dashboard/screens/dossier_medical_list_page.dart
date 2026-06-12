import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/academicien.dart';
import '../../../../domain/entities/dossier_medical.dart';
import '../../../../injection_container.dart';
import '../../../state/dossier_medical_state.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/sync_notification_banner.dart';
import 'dossier_medical_detail_page.dart';
import 'dossier_medical_form_page.dart';

/// Page affichant la liste des dossiers medicaux d'un academicien.
///
/// Cette page permet au medecin de consulter l'historique des blessures
/// d'un academicien et d'acceder a la creation d'un nouveau dossier.
class DossierMedicalListPage extends StatefulWidget {
  final Academicien academicien;

  const DossierMedicalListPage({
    super.key,
    required this.academicien,
  });

  @override
  State<DossierMedicalListPage> createState() => _DossierMedicalListPageState();
}

class _DossierMedicalListPageState extends State<DossierMedicalListPage> {
  late final DossierMedicalState _state;

  @override
  void initState() {
    super.initState();
    _state = DependencyInjection.dossierMedicalState;
    _loadDossiers();
  }

  Future<void> _loadDossiers() async {
    await _state.loadDossiers(widget.academicien.id);
  }

  Future<void> _onRefresh() async {
    final success = await _state.syncFromApi(widget.academicien.id);
    if (!success && mounted) {
      _state.loadDossiers(widget.academicien.id);
    }
  }

  @override
  void dispose() {
    // Ne pas disposer le state car il est gere par DependencyInjection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            SyncNotificationBanner(
              connectivityState: DependencyInjection.connectivityState,
              syncState: DependencyInjection.syncState,
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _state,
                builder: (context, _) {
                  return RefreshIndicator(
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
                          child: _buildAcademicienCard(colorScheme, isDark),
                        ),
                        if (_state.isLoading && _state.dossiers.isEmpty)
                          const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_state.isEmpty)
                          SliverFillRemaining(
                            child: _buildEmptyState(colorScheme, l10n),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _buildDossierCard(
                                    _state.dossiers[index],
                                    colorScheme,
                                    isDark,
                                    index,
                                  );
                                },
                                childCount: _state.dossiers.length,
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(colorScheme),
    );
  }

  Widget _buildHeader(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surface
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dossiers medicaux',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Historique des blessures',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicienCard(ColorScheme colorScheme, bool isDark) {
    final acad = widget.academicien;
    final age = _calculateAge(acad.dateNaissance);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B0A1E), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B0A1E).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
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
                const SizedBox(height: 6),
                Text(
                  '$age ans',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.folder_shared_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDossierCard(
    DossierMedical dossier,
    ColorScheme colorScheme,
    bool isDark,
    int index,
  ) {
    final Color statutColor = _statutColor(dossier.statutReprise);

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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DossierMedicalDetailPage(
                academicien: widget.academicien,
                dossier: dossier,
              ),
            ),
          );
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
                      color: statutColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dossier.statutRepriseLabel.toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statutColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(dossier.dateBlessure),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dossier.natureBlessure,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (dossier.description != null &&
                  dossier.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  dossier.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
              ],
              if (dossier.gravite != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: _graviteColor(dossier.gravite!),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Gravite: ${dossier.gravite!}',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _graviteColor(dossier.gravite!),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun dossier medical',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cet academicien ne possede encore aucun dossier medical.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onCreateDossier,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Creer un dossier',
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

  Widget? _buildFab(ColorScheme colorScheme) {
    if (_state.isEmpty) return null;

    return FloatingActionButton.extended(
      onPressed: _onCreateDossier,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Nouveau dossier',
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _onCreateDossier() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DossierMedicalFormPage(
          academicien: widget.academicien,
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_cours':
        return AppColors.warning;
      case 'apte_entrainement':
        return AppColors.primary;
      case 'apte_competition':
        return AppColors.success;
      case 'fini':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _graviteColor(String gravite) {
    switch (gravite.toLowerCase()) {
      case 'legere':
        return AppColors.success;
      case 'moyenne':
        return AppColors.warning;
      case 'grave':
        return AppColors.error;
      default:
        return const Color(0xFF6B7280);
    }
  }
}
