import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/role.dart';
import '../../../domain/entities/permission.dart';
import '../../../domain/repositories/role_repository.dart';
import '../../../domain/failures/network_failure.dart';
import '../../../injection_container.dart';
import '../../theme/app_colors.dart';

/// Page de gestion des rôles utilisateurs.
/// Permet aux administrateurs de voir et modifier les rôles des utilisateurs.
class UsersRolesPage extends StatefulWidget {
  const UsersRolesPage({super.key});

  @override
  State<UsersRolesPage> createState() => _UsersRolesPageState();
}

class _UsersRolesPageState extends State<UsersRolesPage>
    with TickerProviderStateMixin {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false; // Seulement true si pas de cache disponible
  // Indicateur discret pour le chargement en arrière-plan
  bool _isBackgroundLoading = false;
  final _searchController = TextEditingController();
  Role? _selectedRoleFilter;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final int _pageSize = 20;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadCachedUsersFirst();
  }

  /// Charge d'abord le cache synchrone, puis lance le rafraîchissement.
  void _loadCachedUsersFirst() {
    // Essayer de charger le cache synchrone immédiatement (sans filtre)
    final cachedUsers = DependencyInjection.roleService.getCachedUsersSync();

    if (cachedUsers != null && cachedUsers.isNotEmpty) {
      // Afficher le cache immédiatement (le filtrage se fait dans _applyFilters)
      setState(() {
        _users = cachedUsers;
        _applyFilters();
      });
      _fadeController.forward();
      // Puis rafraîchir en arrière-plan avec le filtre actuel
      _refreshInBackground();
    } else {
      // Pas de cache, charger normalement
      _loadUsers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Charge la liste des utilisateurs depuis le cache puis l'API.
  ///
  /// Affiche d'abord les données en cache si disponibles,
  /// puis effectue une requête en arrière-plan pour mettre à jour.
  Future<void> _loadUsers({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (loadMore && !_hasMorePages) return;

    // Si ce n'est pas un chargement supplémentaire, réinitialiser
    if (!loadMore) {
      setState(() {
        _errorMessage = null;
        _currentPage = 1;
        // Afficher le spinner si pas de données (premier chargement)
        if (_users.isEmpty) {
          _isLoading = true;
        }
      });
    }

    try {
      // Charger toutes les données sans filtre API (le filtrage se fait localement)
      final (users, failure, isFromCache) = await DependencyInjection
          .roleService
          .getAllUsersWithRoles(
            page: loadMore ? _currentPage + 1 : _currentPage,
            limit: _pageSize,
            filterByRole: null, // Pas de filtre API - on charge tout
            forceRefresh: forceRefresh,
          );

      if (failure != null) {
        setState(() {
          // Si on a déjà des données du cache, on affiche juste une erreur discrète
          if (_users.isEmpty) {
            _errorMessage = failure.message;
            _isLoading = false;
          }
          _isBackgroundLoading = false;
        });
        return;
      }

      if (users != null) {
        setState(() {
          if (loadMore) {
            _users = [..._users, ...users];
            _currentPage++;
          } else {
            _users = users;
          }
          _hasMorePages = users.length == _pageSize;
          _applyFilters();
          _isLoading = false;
          _isBackgroundLoading = false;
        });
        _fadeController.forward();

        // Si les données viennent du cache, rafraîchir en arrière-plan
        if (isFromCache && users.isNotEmpty) {
          _refreshInBackground();
        }
      }
    } catch (e) {
      setState(() {
        if (_users.isEmpty) {
          _errorMessage = e.toString();
          _isLoading = false;
        }
        _isBackgroundLoading = false;
      });
    }
  }

  /// Rafraîchit les données en arrière-plan de manière discrète.
  Future<void> _refreshInBackground() async {
    if (_isBackgroundLoading) return;

    setState(() => _isBackgroundLoading = true);

    try {
      // Charger toutes les données sans filtre API (le filtrage se fait localement)
      final (users, failure, _) = await DependencyInjection.roleService
          .getAllUsersWithRoles(
            page: 1,
            limit: _pageSize,
            filterByRole: null, // Pas de filtre API - on charge tout
            forceRefresh: true,
          );

      if (!mounted) return;

      if (failure == null && users != null) {
        setState(() {
          _users = users;
          _hasMorePages = users.length == _pageSize;
          _applyFilters(); // Filtrage local
          _isBackgroundLoading = false;
        });
      } else {
        setState(() => _isBackgroundLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBackgroundLoading = false);
    }
  }

  /// Applique les filtres de recherche et de rôle.
  void _applyFilters() {
    List<User> result = List.from(_users);

    // Filtre par rôle
    if (_selectedRoleFilter != null) {
      result = result.where((u) => u.role == _selectedRoleFilter).toList();
    }

    // Filtre par recherche textuelle
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((u) {
        return u.fullName.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredUsers = result);
  }

  /// Affiche le dialogue de confirmation pour le changement de rôle.
  Future<void> _showRoleChangeDialog(User user) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    Role? selectedRole = user.role;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.changeUserRoleTitle,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Utilisateur concerné
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            user.initials,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                user.email,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sélection du rôle
                  Text(
                    l10n.selectNewRole,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: Role.values.map((role) {
                        final isSelected = selectedRole == role;
                        return InkWell(
                          onTap: () =>
                              setDialogState(() => selectedRole = role),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : null,
                              borderRadius: BorderRadius.vertical(
                                top: role == Role.values.first
                                    ? const Radius.circular(11)
                                    : Radius.zero,
                                bottom: role == Role.values.last
                                    ? const Radius.circular(11)
                                    : Radius.zero,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getRoleIcon(role),
                                  size: 20,
                                  color: isSelected
                                      ? AppColors.primary
                                      : colorScheme.onSurface.withValues(
                                          alpha: 0.4,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _getRoleDisplayName(role, l10n),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? AppColors.primary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Avertissement
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.roleChangeWarning,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                // Bouton historique
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showRoleHistoryDialog(user);
                  },
                  icon: Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  label: Text(
                    l10n.history,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedRole != null && selectedRole != user.role
                      ? () async {
                          Navigator.of(context).pop();
                          await _changeUserRole(user, selectedRole!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.confirmChange,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Effectue le changement de rôle côté serveur.
  Future<void> _changeUserRole(User user, Role newRole) async {
    final l10n = AppLocalizations.of(context)!;

    // Vérifier la permission
    final hasPermission = DependencyInjection.roleService.hasPermission(
      Permission.userAssignRole,
    );
    if (!hasPermission) {
      _showSnackBar(l10n.permissionDenied, isError: true);
      return;
    }

    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.updatingRole, style: GoogleFonts.montserrat()),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final failure = await DependencyInjection.roleService.assignRoleToUser(
        userId: user.id,
        newRole: newRole,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer le loader

      if (failure != null) {
        _showSnackBar(failure.message ?? l10n.roleChangeError, isError: true);
        return;
      }

      // Mettre à jour l'utilisateur localement
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user.copyWith(role: newRole);
          _applyFilters();
        }
      });

      // Invalider le cache pour forcer le rafraichissement
      await DependencyInjection.roleService.invalidateUsersCache();

      _showSnackBar(l10n.roleChangeSuccess);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer le loader
      _showSnackBar(e.toString(), isError: true);
    }
  }

  /// Affiche le dialogue d'historique des changements de rôle.
  Future<void> _showRoleHistoryDialog(User user) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.history_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.roleChangeHistoryTitle,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: FutureBuilder<(List<RoleChangeHistory>?, NetworkFailure?)>(
              future: DependencyInjection.roleService.getRoleChangeHistory(
                userId: user.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data?.$2 != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.loadingError,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final history = snapshot.data?.$1 ?? [];

                if (history.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 48,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noRoleChangeHistory,
                          style: GoogleFonts.montserrat(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        entry.titre,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (entry.description != null)
                            Text(
                              entry.description!,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(entry.date),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: entry.description != null,
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.close,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Affiche un message snackbar.
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Retourne l'icône associée à un rôle.
  IconData _getRoleIcon(Role role) {
    switch (role) {
      case Role.supAdmin:
        return Icons.security_rounded;
      case Role.admin:
        return Icons.admin_panel_settings_rounded;
      case Role.encadreurChef:
        return Icons.sports_rounded;
      case Role.medecinChef:
        return Icons.medical_services_rounded;
      case Role.encadreur:
        return Icons.sports_soccer_rounded;
      case Role.surveillantGeneral:
        return Icons.visibility_rounded;
      case Role.visiteur:
        return Icons.remove_red_eye_rounded;
    }
  }

  /// Retourne le nom d'affichage du rôle traduit.
  String _getRoleDisplayName(Role role, AppLocalizations l10n) {
    switch (role) {
      case Role.supAdmin:
        return l10n.roleSupAdmin;
      case Role.admin:
        return l10n.roleAdmin;
      case Role.encadreurChef:
        return l10n.roleEncadreurChef;
      case Role.medecinChef:
        return l10n.roleMedecinChef;
      case Role.encadreur:
        return l10n.roleEncadreur;
      case Role.surveillantGeneral:
        return l10n.roleSurveillantGeneral;
      case Role.visiteur:
        return l10n.roleVisiteur;
    }
  }

  /// Retourne la couleur associée à un rôle.
  Color _getRoleColor(Role role) {
    switch (role) {
      case Role.supAdmin:
        return const Color(0xFFE74C3C);
      case Role.admin:
        return AppColors.primary;
      case Role.encadreurChef:
        return const Color(0xFF8B5CF6);
      case Role.medecinChef:
        return const Color(0xFF10B981);
      case Role.encadreur:
        return const Color(0xFF3B82F6);
      case Role.surveillantGeneral:
        return const Color(0xFFF59E0B);
      case Role.visiteur:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(colorScheme, l10n)),
            SliverToBoxAdapter(
              child: _buildSearchBar(colorScheme, isDark, l10n),
            ),
            SliverToBoxAdapter(child: _buildRoleFilterChips(colorScheme, l10n)),
            SliverToBoxAdapter(
              child: _buildQuickStats(colorScheme, isDark, l10n),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildContent(colorScheme, isDark, l10n),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Flexible(
                      child: Text(
                        l10n.usersRolesTitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Loader horizontal discret sous le titre
                if (_isBackgroundLoading)
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      l10n.usersRolesSubtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_users.length}',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
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
            Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: l10n.searchUserHint,
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _applyFilters();
                },
                child: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilterChips(ColorScheme colorScheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: Role.values.length + 1, // +1 pour "Tous"
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isAllFilter = index == 0;
            final role = isAllFilter ? null : Role.values[index - 1];
            final isSelected = _selectedRoleFilter == role;
            final label = isAllFilter
                ? l10n.all_masculine
                : _getRoleDisplayName(role!, l10n);

            return GestureDetector(
              onTap: () {
                setState(() => _selectedRoleFilter = role);
                _loadUsers();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Compter les utilisateurs par rôle
    final roleCounts = <Role, int>{};
    for (final role in Role.values) {
      roleCounts[role] = _users.where((u) => u.role == role).length;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: l10n.totalLabel,
              value: '${_users.length}',
              icon: Icons.people_rounded,
              color: AppColors.primary,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStat(
              label: l10n.administrators,
              value:
                  '${(roleCounts[Role.supAdmin] ?? 0) + (roleCounts[Role.admin] ?? 0)}',
              icon: Icons.admin_panel_settings_rounded,
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStat(
              label: l10n.coaches,
              value:
                  '${(roleCounts[Role.encadreurChef] ?? 0) + (roleCounts[Role.encadreur] ?? 0)}',
              icon: Icons.sports_rounded,
              color: const Color(0xFF10B981),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    ColorScheme colorScheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(child: _buildErrorState(colorScheme, l10n));
    }

    if (_filteredUsers.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(colorScheme, l10n));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final user = _filteredUsers[index];
          return _buildUserCard(user, colorScheme, isDark, index, l10n);
        }, childCount: _filteredUsers.length),
      ),
    );
  }

  Widget _buildUserCard(
    User user,
    ColorScheme colorScheme,
    bool isDark,
    int index,
    AppLocalizations l10n,
  ) {
    final roleColor = _getRoleColor(user.role);

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
        onTap: () => _showRoleChangeDialog(user),
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
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: roleColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? Image.network(
                          user.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildInitialsAvatar(user, roleColor),
                        )
                      : _buildInitialsAvatar(user, roleColor),
                ),
              ),
              const SizedBox(width: 14),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!user.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.inactive,
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getRoleIcon(user.role),
                                size: 12,
                                color: roleColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getRoleDisplayName(user.role, l10n),
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: roleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.email_outlined,
                          size: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.email,
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Icône de modification
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(User user, Color roleColor) {
    return Container(
      color: roleColor.withValues(alpha: 0.08),
      child: Center(
        child: Text(
          user.initials,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: roleColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    final hasActiveFilter =
        _searchController.text.isNotEmpty || _selectedRoleFilter != null;

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
                Icons.people_outline_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noUsersFound,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilter ? l10n.noSearchResult : l10n.noUsersRegistered,
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

  Widget _buildErrorState(ColorScheme colorScheme, AppLocalizations l10n) {
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
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.loadingError,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? l10n.unknownError,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                l10n.retry,
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
}

/// Widget de statistique compacte.
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final ColorScheme colorScheme;

  const _MiniStat({
    required this.label,
    required this.value,
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
