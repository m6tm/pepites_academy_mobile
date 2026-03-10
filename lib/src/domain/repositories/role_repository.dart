import '../entities/permission.dart';
import '../entities/role.dart';
import '../entities/user.dart';
import '../failures/network_failure.dart';

/// Interface du dépôt pour les opérations liées aux rôles et permissions.
abstract class RoleRepository {
  /// Récupère le rôle de l'utilisateur actuellement connecté.
  ///
  /// Retourne le rôle stocké localement ou depuis l'API.
  Future<Role> getCurrentUserRole();

  /// Met à jour le rôle de l'utilisateur actuellement connecté.
  ///
  /// Cette méthode est typiquement appelée après une modification
  /// de rôle par un administrateur.
  Future<NetworkFailure?> updateCurrentUserRole(Role newRole);

  /// Récupère la liste de tous les rôles disponibles.
  ///
  /// Utile pour afficher un sélecteur de rôles dans l'interface admin.
  List<Role> getAllRoles();

  /// Récupère les permissions associées à un rôle spécifique.
  ///
  /// Retourne l'ensemble des permissions accordées à ce rôle.
  Set<Permission> getPermissionsForRole(Role role);

  /// Attribue un rôle à un utilisateur spécifique.
  ///
  /// Nécessite la permission `user:assign_role`.
  /// Retourne une [NetworkFailure] en cas d'erreur, ou null si succès.
  Future<NetworkFailure?> assignRoleToUser({
    required String userId,
    required Role newRole,
  });

  /// Récupère la liste des utilisateurs avec un rôle spécifique.
  ///
  /// Nécessite la permission `user:view`.
  Future<(List<User>?, NetworkFailure?)> getUsersByRole(Role role);

  /// Récupère la liste de tous les utilisateurs avec leurs rôles.
  ///
  /// Nécessite la permission `user:view`.
  /// Supporte la pagination avec [page] et [limit].
  /// Si [forceRefresh] est true, ignore le cache et force l'appel API.
  /// Retourne un tuple (utilisateurs, erreur, isFromCache).
  Future<(List<User>?, NetworkFailure?, bool isFromCache)>
  getAllUsersWithRoles({
    int page = 1,
    int limit = 20,
    Role? filterByRole,
    bool forceRefresh = false,
  });

  /// Vérifie si l'utilisateur actuel possède une permission spécifique.
  ///
  /// Cette méthode vérifie localement sans appel API.
  bool hasPermission(Permission permission);

  /// Vérifie si l'utilisateur actuel possède toutes les permissions spécifiées.
  bool hasAllPermissions(Iterable<Permission> permissions);

  /// Vérifie si l'utilisateur actuel possède au moins une des permissions.
  bool hasAnyPermission(Iterable<Permission> permissions);

  /// Récupère l'utilisateur actuellement connecté avec son rôle.
  ///
  /// Retourne null si aucun utilisateur n'est connecté.
  Future<User?> getCurrentUser();

  /// Stocke le rôle de l'utilisateur localement pour le mode hors-ligne.
  ///
  /// Le rôle est persisté localement pour permettre les vérifications
  /// de permissions même sans connexion réseau.
  Future<void> persistRoleLocally(Role role);

  /// Efface le rôle stocké localement (déconnexion).
  Future<void> clearLocalRole();

  /// Récupère l'historique des changements de rôle pour un utilisateur.
  ///
  /// Nécessite la permission `user:view`.
  /// Retourne un tuple (historique, erreur).
  Future<(List<RoleChangeHistory>?, NetworkFailure?)> getRoleChangeHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  });
}

/// Entité représentant une entrée de l'historique des changements de rôle.
class RoleChangeHistory {
  /// Identifiant unique de l'entrée.
  final String id;

  /// Titre de l'événement.
  final String titre;

  /// Description détaillée du changement.
  final String? description;

  /// Date du changement.
  final DateTime date;

  /// Nom de l'utilisateur qui a effectué le changement.
  final String? utilisateurNom;

  const RoleChangeHistory({
    required this.id,
    required this.titre,
    this.description,
    required this.date,
    this.utilisateurNom,
  });

  factory RoleChangeHistory.fromJson(Map<String, dynamic> json) {
    return RoleChangeHistory(
      id: json['id'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      utilisateurNom: json['utilisateur_nom'] as String?,
    );
  }
}
