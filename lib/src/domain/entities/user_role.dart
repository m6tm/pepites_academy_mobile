/// Définit les rôles (profiles) d'utilisateurs autorisés à utiliser l'application.
enum UserRole {
  /// Administrateur : Possède un accès total à toutes les fonctionnalités de l'application,
  /// y compris la gestion des référentiels, des inscriptions et des SMS.
  admin('admin'),

  /// Encadreur : Possède un accès aux fonctionnalités de terrain telles que
  /// le scan de présence, la gestion des séances, les ateliers et les annotations.
  encadreur('encadreur');

  /// La valeur textuelle du rôle utilisée pour l'identification (ex: stockage BDD ou Auth).
  final String id;

  const UserRole(this.id);

  /// Récupère un [UserRole] à partir de son identifiant textuel.
  static UserRole fromId(String id) {
    return UserRole.values.firstWhere(
      (role) => role.id == id.toLowerCase(),
      orElse: () => UserRole.encadreur,
    );
  }
}
