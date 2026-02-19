import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import '../../../domain/entities/academicien.dart';
import '../../../domain/entities/encadreur.dart';
import '../../../domain/entities/niveau_scolaire.dart';
import '../../../domain/entities/poste_football.dart';
import '../../../domain/entities/sms_message.dart';
import '../../../injection_container.dart';
import '../../state/sms_state.dart';
import '../../theme/app_colors.dart';
import 'sms_confirmation_page.dart';

/// Page de selection des destinataires pour un SMS.
/// Permet la recherche individuelle et la selection groupee par filtres.
class SmsRecipientSelectionPage extends StatefulWidget {
  final SmsState smsState;

  const SmsRecipientSelectionPage({super.key, required this.smsState});

  @override
  State<SmsRecipientSelectionPage> createState() =>
      _SmsRecipientSelectionPageState();
}

class _SmsRecipientSelectionPageState extends State<SmsRecipientSelectionPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, PosteFootball> _postesMap = {};
  Map<String, NiveauScolaire> _niveauxMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    widget.smsState.chargerContacts();
    _chargerReferentiels();
  }

  Future<void> _chargerReferentiels() async {
    final postes = await DependencyInjection.referentielService.getAllPostes();
    final niveaux = await DependencyInjection.referentielService
        .getAllNiveaux();
    if (mounted) {
      setState(() {
        _postesMap = {for (final p in postes) p.id: p};
        _niveauxMap = {for (final n in niveaux) n.id: n};
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n!.smsRecipientsTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          labelColor: AppColors.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.4),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: l10n.smsRecipientsTabIndividual),
            Tab(text: l10n.smsRecipientsTabFilters),
            Tab(text: l10n.smsRecipientsTabSelection),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.smsState,
        builder: (context, _) {
          if (widget.smsState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIndividualTab(l10n, colorScheme, isDark),
                    _buildFilterTab(l10n, colorScheme, isDark),
                    _buildSelectionTab(l10n, colorScheme, isDark),
                  ],
                ),
              ),
              _buildBottomBar(l10n, colorScheme, isDark),
            ],
          );
        },
      ),
    );
  }

  // --- Onglet Individuel : recherche par nom ---
  Widget _buildIndividualTab(
    AppLocalizations l,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surface
                  : colorScheme.onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: l.smsRecipientsSearchHint,
                hintStyle: GoogleFonts.montserrat(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),

        // Liste des contacts
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Section Academiciens
              _buildSectionHeader(
                l.smsRecipientsAcademiciens,
                Icons.school_rounded,
                const Color(0xFF3B82F6),
                colorScheme,
              ),
              ..._filteredAcademiciens.map(
                (a) => _buildAcademicienTile(a, colorScheme, isDark),
              ),
              if (_filteredAcademiciens.isEmpty)
                _buildEmptyMessage(l.smsRecipientsNoAcademiciens, colorScheme),

              const SizedBox(height: 12),

              // Section Encadreurs
              _buildSectionHeader(
                l.smsRecipientsEncadreurs,
                Icons.sports_rounded,
                const Color(0xFF8B5CF6),
                colorScheme,
              ),
              ..._filteredEncadreurs.map(
                (e) => _buildEncadreurTile(e, colorScheme, isDark),
              ),
              if (_filteredEncadreurs.isEmpty)
                _buildEmptyMessage(l.smsRecipientsNoEncadreurs, colorScheme),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  List<Academicien> get _filteredAcademiciens {
    if (_searchQuery.isEmpty) return widget.smsState.academiciens;
    final q = _searchQuery.toLowerCase();
    return widget.smsState.academiciens.where((a) {
      return a.nom.toLowerCase().contains(q) ||
          a.prenom.toLowerCase().contains(q);
    }).toList();
  }

  List<Encadreur> get _filteredEncadreurs {
    if (_searchQuery.isEmpty) return widget.smsState.encadreurs;
    final q = _searchQuery.toLowerCase();
    return widget.smsState.encadreurs.where((e) {
      return e.nom.toLowerCase().contains(q) ||
          e.prenom.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicienTile(
    Academicien academicien,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isSelected = widget.smsState.estSelectionne(academicien.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : isDark
            ? colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.3)
              : colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
          child: Text(
            academicien.prenom.isNotEmpty ? academicien.prenom[0] : '?',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3B82F6),
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          '${academicien.prenom} ${academicien.nom}',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          academicien.telephoneParent,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) {
            if (isSelected) {
              widget.smsState.retirerDestinataire(academicien.id);
            } else {
              widget.smsState.ajouterAcademicien(academicien);
            }
          },
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onTap: () {
          if (isSelected) {
            widget.smsState.retirerDestinataire(academicien.id);
          } else {
            widget.smsState.ajouterAcademicien(academicien);
          }
        },
      ),
    );
  }

  Widget _buildEncadreurTile(
    Encadreur encadreur,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final isSelected = widget.smsState.estSelectionne(encadreur.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : isDark
            ? colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.3)
              : colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          child: Text(
            encadreur.prenom.isNotEmpty ? encadreur.prenom[0] : '?',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8B5CF6),
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          '${encadreur.prenom} ${encadreur.nom}',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          encadreur.telephone,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) {
            if (isSelected) {
              widget.smsState.retirerDestinataire(encadreur.id);
            } else {
              widget.smsState.ajouterEncadreur(encadreur);
            }
          },
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onTap: () {
          if (isSelected) {
            widget.smsState.retirerDestinataire(encadreur.id);
          } else {
            widget.smsState.ajouterEncadreur(encadreur);
          }
        },
      ),
    );
  }

  Widget _buildEmptyMessage(String message, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        message,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.3),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // --- Onglet Filtres : selection groupee ---
  Widget _buildFilterTab(
    AppLocalizations l,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Selection rapide
        Text(
          l.smsRecipientsQuickSelection,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickFilterButton(
                l.smsRecipientsAllAcademiciens,
                Icons.school_rounded,
                const Color(0xFF3B82F6),
                () => widget.smsState.selectionnerTousAcademiciens(),
                colorScheme,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickFilterButton(
                l.smsRecipientsAllEncadreurs,
                Icons.sports_rounded,
                const Color(0xFF8B5CF6),
                () => widget.smsState.selectionnerTousEncadreurs(),
                colorScheme,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Filtre par poste de football
        _buildFilterSection(
          l.smsRecipientsByFootballPoste,
          Icons.sports_soccer_rounded,
          AppColors.primary,
          _buildPosteFilters(l, colorScheme, isDark),
          colorScheme,
        ),
        const SizedBox(height: 20),

        // Filtre par niveau scolaire
        _buildFilterSection(
          l.smsRecipientsBySchoolLevel,
          Icons.menu_book_rounded,
          const Color(0xFF10B981),
          _buildNiveauFilters(l, colorScheme, isDark),
          colorScheme,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildQuickFilterButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }

  List<Widget> _buildPosteFilters(
    AppLocalizations l,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // Extraire les postes uniques des academiciens
    final postes = <String>{};
    for (final a in widget.smsState.academiciens) {
      postes.add(a.posteFootballId);
    }

    if (postes.isEmpty) {
      return [
        Text(
          l.smsRecipientsNoPosteAvailable,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ];
    }

    return postes.map((posteId) {
      final count = widget.smsState.academiciens
          .where((a) => a.posteFootballId == posteId)
          .length;
      return _buildFilterChip(
        _getPosteLabel(posteId),
        count,
        AppColors.primary,
        () => widget.smsState.selectionnerParPoste(posteId),
        colorScheme,
        isDark,
      );
    }).toList();
  }

  List<Widget> _buildNiveauFilters(
    AppLocalizations l,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final niveaux = <String>{};
    for (final a in widget.smsState.academiciens) {
      niveaux.add(a.niveauScolaireId);
    }

    if (niveaux.isEmpty) {
      return [
        Text(
          l.smsRecipientsNoLevelAvailable,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ];
    }

    return niveaux.map((niveauId) {
      final count = widget.smsState.academiciens
          .where((a) => a.niveauScolaireId == niveauId)
          .length;
      return _buildFilterChip(
        _getNiveauLabel(niveauId),
        count,
        const Color(0xFF10B981),
        () => widget.smsState.selectionnerParNiveau(niveauId),
        colorScheme,
        isDark,
      );
    }).toList();
  }

  Widget _buildFilterChip(
    String label,
    int count,
    Color color,
    VoidCallback onTap,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPosteLabel(String posteId) {
    return _postesMap[posteId]?.nom ?? posteId;
  }

  String _getNiveauLabel(String niveauId) {
    return _niveauxMap[niveauId]?.nom ?? niveauId;
  }

  // --- Onglet Selection : recapitulatif ---
  Widget _buildSelectionTab(
    AppLocalizations l,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final destinataires = widget.smsState.destinatairesSelectionnes;

    if (destinataires.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_rounded,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),
            Text(
              l.smsRecipientsNoRecipientSelected,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.smsRecipientsNoRecipientSelectedDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // En-tete avec compteur et bouton vider
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l.smsRecipientsSelectedCount(destinataires.length),
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => widget.smsState.viderSelection(),
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: Text(
                  l.smsRecipientsRemoveAll,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ),

        // Liste des destinataires selectionnes
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: destinataires.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final dest = destinataires[index];
              final isAcademicien = dest.type == TypeDestinataire.academicien;
              final color = isAcademicien
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF8B5CF6);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(
                      isAcademicien
                          ? Icons.school_rounded
                          : Icons.sports_rounded,
                      size: 14,
                      color: color,
                    ),
                  ),
                  title: Text(
                    dest.nom,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    dest.telephone,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.remove_circle_rounded,
                      color: AppColors.error.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    onPressed: () =>
                        widget.smsState.retirerDestinataire(dest.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Barre inferieure ---
  Widget _buildBottomBar(
    AppLocalizations l,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final count = widget.smsState.destinatairesSelectionnes.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: count > 0
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 18,
                    color: count > 0
                        ? AppColors.primary
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: count > 0
                          ? AppColors.primary
                          : colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: count > 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SmsConfirmationPage(
                                smsState: widget.smsState,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.3,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.smsRecipientsPreview,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
