import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/niveau_scolaire.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';

/// Page de gestion des niveaux scolaires.
/// Permet de lister, ajouter, modifier et supprimer des niveaux.
class NiveauxScolairesPage extends StatefulWidget {
  const NiveauxScolairesPage({super.key});

  @override
  State<NiveauxScolairesPage> createState() => _NiveauxScolairesPageState();
}

class _NiveauxScolairesPageState extends State<NiveauxScolairesPage> {
  List<NiveauScolaire> _niveaux = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerNiveaux();
  }

  Future<void> _chargerNiveaux() async {
    setState(() => _isLoading = true);
    try {
      final niveaux = await DependencyInjection.referentielService
          .getAllNiveaux();
      setState(() {
        _niveaux = niveaux;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AcademyToast.show(
          context,
          title: 'Erreur de chargement',
          isError: true,
        );
      }
    }
  }

  Future<void> _ajouterNiveau() async {
    final result = await _showNiveauDialog();
    if (result == true) {
      _chargerNiveaux();
    }
  }

  Future<void> _modifierNiveau(NiveauScolaire niveau) async {
    final result = await _showNiveauDialog(niveau: niveau);
    if (result == true) {
      _chargerNiveaux();
    }
  }

  Future<void> _supprimerNiveau(NiveauScolaire niveau) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Supprimer le niveau',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer le niveau "${niveau.nom}" ?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler', style: GoogleFonts.montserrat()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'Supprimer',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final res = await DependencyInjection.referentielService.supprimerNiveau(
        niveau.id,
      );
      if (mounted) {
        AcademyToast.show(
          context,
          title: res.message,
          isSuccess: res.success,
          isError: !res.success,
        );
        if (res.success) _chargerNiveaux();
      }
    }
  }

  Future<bool?> _showNiveauDialog({NiveauScolaire? niveau}) {
    final nomController = TextEditingController(text: niveau?.nom ?? '');
    final ordreController = TextEditingController(
      text: niveau?.ordre.toString() ?? '${_niveaux.length + 1}',
    );
    final formKey = GlobalKey<FormState>();
    final isEdit = niveau != null;

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEdit ? 'Modifier le niveau' : 'Nouveau niveau',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom du niveau',
                    labelStyle: GoogleFonts.montserrat(fontSize: 13),
                    prefixIcon: const Icon(Icons.school_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: GoogleFonts.montserrat(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Le nom est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ordreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Ordre d\'affichage',
                    labelStyle: GoogleFonts.montserrat(fontSize: 13),
                    prefixIcon: const Icon(Icons.sort_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: GoogleFonts.montserrat(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'L\'ordre est obligatoire';
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'Veuillez saisir un nombre';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Annuler',
                style: GoogleFonts.montserrat(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final navigator = Navigator.of(ctx);
                late final dynamic res;

                if (isEdit) {
                  final updated = niveau.copyWith(
                    nom: nomController.text.trim(),
                    ordre: int.parse(ordreController.text.trim()),
                  );
                  res = await DependencyInjection.referentielService
                      .modifierNiveau(updated);
                } else {
                  res = await DependencyInjection.referentielService
                      .creerNiveau(
                        nom: nomController.text.trim(),
                        ordre: int.parse(ordreController.text.trim()),
                      );
                }

                navigator.pop(res.success);

                if (ctx.mounted) {
                  AcademyToast.show(
                    ctx,
                    title: res.message,
                    isSuccess: res.success,
                    isError: !res.success,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                isEdit ? 'Modifier' : 'Ajouter',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(colorScheme)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_niveaux.length} niveau(x)',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_niveaux.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(colorScheme))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildNiveauCard(
                      _niveaux[index],
                      colorScheme,
                      isDark,
                      index,
                    ),
                    childCount: _niveaux.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterNiveau,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          'Ajouter',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveaux scolaires',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gestion des niveaux academiques',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF3B82F6),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNiveauCard(
    NiveauScolaire niveau,
    ColorScheme colorScheme,
    bool isDark,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${niveau.ordre}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3B82F6),
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
                    niveau.nom,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Ordre : ${niveau.ordre}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _modifierNiveau(niveau),
              icon: Icon(
                Icons.edit_rounded,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: 'Modifier',
            ),
            IconButton(
              onPressed: () => _supprimerNiveau(niveau),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error.withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: 'Supprimer',
            ),
          ],
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
                Icons.school_rounded,
                size: 48,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun niveau',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier niveau scolaire\npour commencer.',
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
