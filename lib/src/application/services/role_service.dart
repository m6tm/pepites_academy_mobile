import '../../domain/entities/permission.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/role_repository.dart';
import '../../infrastructure/repositories/role_repository_impl.dart';

/// Service applicatif pour la gestion des rôles et permissions.
///
/// Fournit une couche d'abstraction pour les opérations liées aux rôles,
/// incluant la vérification des permissions et la gestion du cache local.
class RoleService {
  final RoleRepository _roleRepository;

  RoleService({required RoleRepository roleRepository})
    : _roleRepository = roleRepository;

  /// Récupère le rôle de l'utilisateur actuellement connecté.
  ///
  /// Retourne le rôle depuis le cache local ou le stockage persistant.
  Future<Role> getCurrentUserRole() async {
    return _roleRepository.getCurrentUserRole();
  }

  /// Met à jour le rôle de l'utilisateur actuel.
  ///
  /// Retourne une [NetworkFailure] en cas d'erreur, ou null si succès.
  Future<NetworkFailure?> updateCurrentUserRole(Role newRole) async {
    return _roleRepository.updateCurrentUserRole(newRole);
  }

  /// Récupère la liste de tous les rôles disponibles.
  List<Role> getAllRoles() {
    return _roleRepository.getAllRoles();
  }

  /// Récupère les permissions associées à un rôle spécifique.
  Set<Permission> getPermissionsForRole(Role role) {
    return _roleRepository.getPermissionsForRole(role);
  }

  /// Attribue un rôle à un utilisateur spécifique.
  ///
  /// Nécessite la permission `user:assign_role`.
  Future<NetworkFailure?> assignRoleToUser({
    required String userId,
    required Role newRole,
  }) async {
    return _roleRepository.assignRoleToUser(userId: userId, newRole: newRole);
  }

  /// Récupère la liste des utilisateurs avec un rôle spécifique.
  Future<(List<User>?, NetworkFailure?)> getUsersByRole(Role role) async {
    return _roleRepository.getUsersByRole(role);
  }

  /// Récupère la liste de tous les utilisateurs avec leurs rôles.
  ///
  /// Si [forceRefresh] est true, ignore le cache et force l'appel API.
  /// Retourne un tuple (utilisateurs, erreur, isFromCache).
  Future<(List<User>?, NetworkFailure?, bool isFromCache)>
  getAllUsersWithRoles({
    int page = 1,
    int limit = 20,
    Role? filterByRole,
    bool forceRefresh = false,
  }) async {
    return _roleRepository.getAllUsersWithRoles(
      page: page,
      limit: limit,
      filterByRole: filterByRole,
      forceRefresh: forceRefresh,
    );
  }

  /// Récupère les utilisateurs en cache de manière synchrone.
  ///
  /// Retourne le cache mémoire si disponible, null sinon.
  /// Le filtrage se fait côté UI.
  List<User>? getCachedUsersSync() {
    final repo = _roleRepository;
    if (repo is RoleRepositoryImpl) {
      return repo.getCachedUsersSync();
    }
    return null;
  }

  /// Vérifie si l'utilisateur actuel possède une permission spécifique.
  ///
  /// Cette vérification se fait localement sans appel API.
  bool hasPermission(Permission permission) {
    return _roleRepository.hasPermission(permission);
  }

  /// Vérifie si l'utilisateur actuel possède toutes les permissions spécifiées.
  bool hasAllPermissions(Iterable<Permission> permissions) {
    return _roleRepository.hasAllPermissions(permissions);
  }

  /// Vérifie si l'utilisateur actuel possède au moins une des permissions.
  bool hasAnyPermission(Iterable<Permission> permissions) {
    return _roleRepository.hasAnyPermission(permissions);
  }

  /// Récupère l'utilisateur actuellement connecté avec son rôle.
  ///
  /// Retourne null si aucun utilisateur n'est connecté.
  Future<User?> getCurrentUser() async {
    return _roleRepository.getCurrentUser();
  }

  /// Stocke le rôle de l'utilisateur localement pour le mode hors-ligne.
  Future<void> persistRoleLocally(Role role) async {
    return _roleRepository.persistRoleLocally(role);
  }

  /// Efface le rôle stocké localement (déconnexion).
  Future<void> clearLocalRole() async {
    return _roleRepository.clearLocalRole();
  }

  /// Rafraîchit le rôle depuis l'API.
  ///
  /// Utile pour vérifier si le rôle a changé côté serveur.
  Future<Role?> refreshRoleFromApi() async {
    final repo = _roleRepository;
    if (repo is RoleRepositoryImpl) {
      return repo.refreshRoleFromApi();
    }
    return null;
  }

  /// Détermine le dashboard approprié selon le rôle de l'utilisateur.
  ///
  /// Retourne le type de dashboard à afficher.
  DashboardType getDashboardForRole(Role role) {
    switch (role) {
      case Role.supAdmin:
      case Role.admin:
        return DashboardType.admin;
      case Role.encadreurChef:
      case Role.encadreur:
        return DashboardType.encadreur;
      case Role.medecinChef:
        return DashboardType.medecin;
      case Role.surveillantGeneral:
        return DashboardType.surveillant;
      case Role.visiteur:
        return DashboardType.visiteur;
    }
  }

  /// Vérifie si l'utilisateur peut accéder aux fonctionnalités d'administration.
  bool canAccessAdminFeatures(Role role) {
    return role.isHigherOrEqualTo(Role.admin);
  }

  /// Vérifie si l'utilisateur peut gérer les séances.
  bool canManageSeances(Role role) {
    return role.hasPermission(Permission.seanceOpen) &&
        role.hasPermission(Permission.seanceClose);
  }

  /// Vérifie si l'utilisateur peut scanner les QR codes.
  bool canScanQr(Role role) {
    return role.hasPermission(Permission.qrScan);
  }

  /// Vérifie si l'utilisateur peut envoyer des SMS.
  bool canSendSms(Role role) {
    return role.hasPermission(Permission.smsSend);
  }

  /// Vérifie si l'utilisateur peut gérer les académiciens.
  bool canManageAcademiciens(Role role) {
    return role.hasPermission(Permission.academicienCreate) ||
        role.hasPermission(Permission.academicienUpdate);
  }

  /// Vérifie si l'utilisateur peut gérer les entraînements.
  bool canManageEntrainements(Role role) {
    return role.hasPermission(Permission.entrainementCreate) ||
        role.hasPermission(Permission.entrainementUpdate);
  }

  /// Vérifie si l'utilisateur peut valider les évaluations.
  bool canValidateEvaluations(Role role) {
    return role.hasPermission(Permission.evaluationValidate);
  }

  /// Vérifie si l'utilisateur peut gérer le suivi médical.
  bool canManageMedical(Role role) {
    return role.hasPermission(Permission.medicalCreate) ||
        role.hasPermission(Permission.medicalUpdate);
  }

  /// Vérifie si l'utilisateur peut gérer le matériel.
  bool canManageMateriel(Role role) {
    return role.hasPermission(Permission.materielCreate) ||
        role.hasPermission(Permission.materielUpdate);
  }

  /// Vérifie si l'utilisateur peut gérer la discipline.
  bool canManageDiscipline(Role role) {
    return role.hasPermission(Permission.incidentCreate) ||
        role.hasPermission(Permission.incidentUpdate);
  }

  /// Récupère l'historique des changements de rôle pour un utilisateur.
  ///
  /// Nécessite la permission `user:view`.
  Future<(List<RoleChangeHistory>?, NetworkFailure?)> getRoleChangeHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    return _roleRepository.getRoleChangeHistory(
      userId: userId,
      page: page,
      limit: limit,
    );
  }

  /// Invalide le cache des utilisateurs.
  ///
  /// À appeler après une modification de rôle pour forcer le rafraîchissement.
  Future<void> invalidateUsersCache() async {
    final repo = _roleRepository;
    if (repo is RoleRepositoryImpl) {
      await repo.invalidateUsersCache();
    }
  }
}

/// Types de dashboards disponibles selon le rôle.
enum DashboardType {
  /// Dashboard administrateur (supAdmin, admin).
  admin,

  /// Dashboard encadreur (encadreurChef, encadreur).
  encadreur,

  /// Dashboard médecin (medecinChef).
  medecin,

  /// Dashboard surveillant général.
  surveillant,

  /// Dashboard visiteur (lecture seule).
  visiteur,
}
