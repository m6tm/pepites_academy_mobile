import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/poste_football.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';

/// Page de gestion des postes de football.
/// Permet de lister, ajouter, modifier et supprimer des postes.
class PostesFootballPage extends StatefulWidget {
  const PostesFootballPage({super.key});

  @override
  State<PostesFootballPage> createState() => _PostesFootballPageState();
}

class _PostesFootballPageState extends State<PostesFootballPage> {
  List<PosteFootball> _postes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerPostes();
  }

  Future<void> _chargerPostes() async {
    setState(() => _isLoading = true);
    try {
      final postes = await DependencyInjection.referentielService
          .getAllPostes();
      setState(() {
        _postes = postes;
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

  Future<void> _ajouterPoste() async {
    final result = await _showPosteDialog();
    if (result == true) {
      _chargerPostes();
    }
  }

  Future<void> _modifierPoste(PosteFootball poste) async {
    final result = await _showPosteDialog(poste: poste);
    if (result == true) {
      _chargerPostes();
    }
  }

  Future<void> _supprimerPoste(PosteFootball poste) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Supprimer le poste',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer le poste "${poste.nom}" ?',
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
      final res = await DependencyInjection.referentielService.supprimerPoste(
        poste.id,
      );
      if (mounted) {
        AcademyToast.show(
          context,
          title: res.message,
          isSuccess: res.success,
          isError: !res.success,
        );
        if (res.success) _chargerPostes();
      }
    }
  }

  Future<bool?> _showPosteDialog({PosteFootball? poste}) {
    final nomController = TextEditingController(text: poste?.nom ?? '');
    final descController = TextEditingController(
      text: poste?.description ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final isEdit = poste != null;

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEdit ? 'Modifier le poste' : 'Nouveau poste',
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
                    labelText: 'Nom du poste',
                    labelStyle: GoogleFonts.montserrat(fontSize: 13),
                    prefixIcon: const Icon(Icons.sports_soccer_rounded),
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
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description (optionnelle)',
                    labelStyle: GoogleFonts.montserrat(fontSize: 13),
                    prefixIcon: const Icon(Icons.description_outlined),
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
                  maxLines: 2,
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
                  final updated = poste.copyWith(
                    nom: nomController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  );
                  res = await DependencyInjection.referentielService
                      .modifierPoste(updated);
                } else {
                  res = await DependencyInjection.referentielService.creerPoste(
                    nom: nomController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_postes.length} poste(s)',
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
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_postes.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(colorScheme))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPosteCard(
                      _postes[index],
                      colorScheme,
                      isDark,
                      index,
                    ),
                    childCount: _postes.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterPoste,
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
                  'Postes de football',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gestion des postes de jeu',
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.sports_soccer_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosteCard(
    PosteFootball poste,
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
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.sports_soccer_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poste.nom,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (poste.description != null &&
                      poste.description!.isNotEmpty)
                    Text(
                      poste.description!,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _modifierPoste(poste),
              icon: Icon(
                Icons.edit_rounded,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: 'Modifier',
            ),
            IconButton(
              onPressed: () => _supprimerPoste(poste),
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
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun poste',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier poste de football\npour commencer.',
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
