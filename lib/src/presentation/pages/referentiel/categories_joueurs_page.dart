import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../domain/entities/categorie_joueur.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';
import '../../widgets/academy_toast.dart';

/// Page de gestion des categories de joueurs.
/// Permet de lister, ajouter, modifier et supprimer des categories.
class CategoriesJoueursPage extends StatefulWidget {
  const CategoriesJoueursPage({super.key});

  @override
  State<CategoriesJoueursPage> createState() => _CategoriesJoueursPageState();
}

class _CategoriesJoueursPageState extends State<CategoriesJoueursPage> {
  static const Color _accent = Color(0xFF8B5CF6);

  List<CategorieJoueur> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerCategories();
  }

  Future<void> _chargerCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await DependencyInjection.referentielService
          .getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AcademyToast.show(context, title: l10n.loadingError, isError: true);
      }
    }
  }

  Future<void> _syncFromBackend() async {
    setState(() => _isLoading = true);
    final success = await DependencyInjection.syncCategoriesJoueurs();
    if (mounted) {
      if (success) {
        await _chargerCategories();
      } else {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        AcademyToast.show(context, title: l10n.loadingError, isError: true);
      }
    }
  }

  Future<void> _ajouterCategorie() async {
    final result = await _showCategorieDialog();
    if (result == true) {
      _chargerCategories();
    }
  }

  Future<void> _modifierCategorie(CategorieJoueur categorie) async {
    final result = await _showCategorieDialog(categorie: categorie);
    if (result == true) {
      _chargerCategories();
    }
  }

  Future<void> _supprimerCategorie(CategorieJoueur categorie) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.deleteCategory,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.deleteCategoryConfirmation(categorie.nom),
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: GoogleFonts.montserrat()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              l10n.delete,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final res = await DependencyInjection.referentielService
          .supprimerCategorie(categorie.id);
      if (mounted) {
        AcademyToast.show(
          context,
          title: res.message,
          isSuccess: res.success,
          isError: !res.success,
        );
        if (res.success) _chargerCategories();
      }
    }
  }

  Future<bool?> _showCategorieDialog({CategorieJoueur? categorie}) {
    final nomController = TextEditingController(text: categorie?.nom ?? '');
    final descController = TextEditingController(
      text: categorie?.description ?? '',
    );
    final ordreController = TextEditingController(
      text: categorie?.ordre.toString() ?? '${_categories.length + 1}',
    );
    final formKey = GlobalKey<FormState>();
    final isEdit = categorie != null;

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final l10n = AppLocalizations.of(ctx)!;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEdit ? l10n.editCategory : l10n.newCategory,
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
                    labelText: l10n.categoryName,
                    labelStyle: GoogleFonts.montserrat(fontSize: 13),
                    prefixIcon: const Icon(Icons.groups_rounded),
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
                      return l10n.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionOptional,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: ordreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.displayOrder,
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
                      return l10n.orderRequired;
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return l10n.enterNumberError;
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
                l10n.cancel,
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
                final descText = descController.text.trim();

                if (isEdit) {
                  final updated = categorie.copyWith(
                    nom: nomController.text.trim(),
                    description: descText.isEmpty ? null : descText,
                    clearDescription: descText.isEmpty,
                    ordre: int.parse(ordreController.text.trim()),
                  );
                  res = await DependencyInjection.referentielService
                      .modifierCategorie(updated);
                } else {
                  res = await DependencyInjection.referentielService
                      .creerCategorie(
                        nom: nomController.text.trim(),
                        description: descText.isEmpty ? null : descText,
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
                isEdit ? l10n.edit : l10n.add,
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
    final l10n = AppLocalizations.of(context)!;

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
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l10n.playerCategoriesCount(_categories.length),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _accent,
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
            else if (_categories.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(colorScheme))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCategorieCard(
                      _categories[index],
                      colorScheme,
                      isDark,
                      index,
                    ),
                    childCount: _categories.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterCategorie,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(
          l10n.add,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.playerCategories,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.managePlayerCategories,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _syncFromBackend,
            icon: const Icon(Icons.sync_rounded),
            color: _accent,
            tooltip: l10n.syncNowLabel,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: _accent,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorieCard(
    CategorieJoueur categorie,
    ColorScheme colorScheme,
    bool isDark,
    int index,
  ) {
    final l10n = AppLocalizations.of(context)!;
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
                color: _accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${categorie.ordre}',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _accent,
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
                    categorie.nom,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (categorie.description != null &&
                      categorie.description!.isNotEmpty)
                    Text(
                      categorie.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  Text(
                    '${l10n.displayOrder} : ${categorie.ordre}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _modifierCategorie(categorie),
              icon: Icon(
                Icons.edit_rounded,
                color: _accent.withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: l10n.edit,
            ),
            IconButton(
              onPressed: () => _supprimerCategorie(categorie),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error.withValues(alpha: 0.7),
                size: 20,
              ),
              tooltip: l10n.delete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
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
                color: _accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_rounded,
                size: 48,
                color: _accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noCategory,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addFirstCategory,
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
