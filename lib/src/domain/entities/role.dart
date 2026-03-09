/// Définit les rôles (profils) d'utilisateurs autorisés dans l'application.
///
/// Chaque rôle possède un niveau hiérarchique qui détermine ses droits
/// et les permissions associées.
enum Role {
  /// Super Administrateur - Tous les droits.
  /// Niveau 1 - Accès complet à toutes les fonctionnalités.
  supAdmin('sup_admin', 'SupAdmin', 1),

  /// Administrateur - Gestion complète de l'application.
  /// Niveau 2 - Gestion des utilisateurs, saisons, académiciens, etc.
  admin('admin', 'Admin', 2),

  /// Chef des encadreurs - Structuration et validation.
  /// Niveau 3 - Création entraînements, ateliers, validation évaluations.
  encadreurChef('encadreur_chef', 'EncadreurChef', 3),

  /// Chef médical - Suivi sanitaire.
  /// Niveau 4 - Fiches médicales, conseils aux encadreurs.
  medecinChef('medecin_chef', 'MedecinChef', 4),

  /// Coach terrain - Application et suivi.
  /// Niveau 5 - Séances, annotations, suivi académiciens.
  encadreur('encadreur', 'Encadreur', 5),

  /// Gestionnaire matériel et discipline.
  /// Niveau 6 - Matériel, incidents, présences.
  surveillantGeneral('surveillant_general', 'SurveillantGeneral', 6),

  /// Lecture seule - Consultation résultats.
  /// Niveau 7 - Consultation uniquement.
  visiteur('visiteur', 'Visiteur', 7);

  /// L'identifiant textuel du rôle utilisé pour le stockage (BDD, API).
  final String id;

  /// Le nom d'affichage du rôle.
  final String displayName;

  /// Le niveau hiérarchique du rôle (1 = plus élevé).
  final int level;

  const Role(this.id, this.displayName, this.level);

  /// Récupère un [Role] à partir de son identifiant textuel.
  ///
  /// Retourne [Role.visiteur] par défaut si l'identifiant n'est pas trouvé.
  static Role fromId(String id) {
    return Role.values.firstWhere(
      (role) => role.id == id.toLowerCase(),
      orElse: () => Role.visiteur,
    );
  }

  /// Récupère un [Role] à partir de son nom d'affichage.
  ///
  /// Retourne [Role.visiteur] par défaut si le nom n'est pas trouvé.
  static Role fromDisplayName(String displayName) {
    return Role.values.firstWhere(
      (role) => role.displayName == displayName,
      orElse: () => Role.visiteur,
    );
  }

  /// Vérifie si ce rôle a un niveau hiérarchique supérieur ou égal à [other].
  ///
  /// Un rôle de niveau inférieur est plus élevé dans la hiérarchie.
  bool isHigherOrEqualTo(Role other) => level <= other.level;

  /// Vérifie si ce rôle a un niveau hiérarchique strictement supérieur à [other].
  bool isHigherThan(Role other) => level < other.level;

  /// Vérifie si ce rôle a un niveau hiérarchique inférieur ou égal à [other].
  bool isLowerOrEqualTo(Role other) => level >= other.level;

  /// Vérifie si ce rôle a un niveau hiérarchique strictement inférieur à [other].
  bool isLowerThan(Role other) => level > other.level;

  /// Retourne la liste des rôles de niveau inférieur ou égal.
  List<Role> get lowerOrEqualRoles =>
      Role.values.where((r) => r.level >= level).toList();

  /// Retourne la liste des rôles de niveau supérieur ou égal.
  List<Role> get higherOrEqualRoles =>
      Role.values.where((r) => r.level <= level).toList();
}
