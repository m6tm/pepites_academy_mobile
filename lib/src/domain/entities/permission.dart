import 'role.dart';

/// Définit les permissions granulaires pour le contrôle d'accès.
///
/// Chaque permission représente une action spécifique qui peut être
/// effectuée sur une ressource de l'application.
enum Permission {
  // ===== Gestion des Utilisateurs =====
  /// Créer un utilisateur.
  userCreate('user:create', 'Créer un utilisateur'),

  /// Modifier un utilisateur.
  userUpdate('user:update', 'Modifier un utilisateur'),

  /// Supprimer un utilisateur.
  userDelete('user:delete', 'Supprimer un utilisateur'),

  /// Attribuer un rôle à un utilisateur.
  userAssignRole('user:assign_role', 'Attribuer un rôle'),

  /// Voir les utilisateurs.
  userView('user:view', 'Voir les utilisateurs'),

  // ===== Gestion des Saisons =====
  /// Ouvrir une saison.
  seasonOpen('season:open', 'Ouvrir une saison'),

  /// Fermer une saison.
  seasonClose('season:close', 'Fermer une saison'),

  /// Voir les saisons.
  seasonView('season:view', 'Voir les saisons'),

  // ===== Gestion des Académiciens =====
  /// Créer un académicien.
  academicienCreate('academicien:create', 'Créer un académicien'),

  /// Modifier un académicien.
  academicienUpdate('academicien:update', 'Modifier un académicien'),

  /// Supprimer un académicien.
  academicienDelete('academicien:delete', 'Supprimer un académicien'),

  /// Voir les académiciens.
  academicienView('academicien:view', 'Voir les académiciens'),

  // ===== Gestion des Encadreurs =====
  /// Créer un encadreur.
  encadreurCreate('encadreur:create', 'Créer un encadreur'),

  /// Modifier un encadreur.
  encadreurUpdate('encadreur:update', 'Modifier un encadreur'),

  /// Supprimer un encadreur.
  encadreurDelete('encadreur:delete', 'Supprimer un encadreur'),

  /// Voir les encadreurs.
  encadreurView('encadreur:view', 'Voir les encadreurs'),

  // ===== Gestion des Séances =====
  /// Ouvrir une séance.
  seanceOpen('seance:open', 'Ouvrir une séance'),

  /// Fermer une séance.
  seanceClose('seance:close', 'Fermer une séance'),

  /// Voir les séances.
  seanceView('seance:view', 'Voir les séances'),

  // ===== Gestion des Entraînements =====
  /// Créer un entraînement.
  entrainementCreate('entrainement:create', 'Créer un entraînement'),

  /// Modifier un entraînement.
  entrainementUpdate('entrainement:update', 'Modifier un entraînement'),

  /// Supprimer un entraînement.
  entrainementDelete('entrainement:delete', 'Supprimer un entraînement'),

  /// Appliquer un entraînement à une séance.
  entrainementApply('entrainement:apply', 'Appliquer un entraînement'),

  /// Voir les entraînements.
  entrainementView('entrainement:view', 'Voir les entraînements'),

  // ===== Gestion des Ateliers et Exercices =====
  /// Créer un atelier.
  atelierCreate('atelier:create', 'Créer un atelier'),

  /// Modifier un atelier.
  atelierUpdate('atelier:update', 'Modifier un atelier'),

  /// Supprimer un atelier.
  atelierDelete('atelier:delete', 'Supprimer un atelier'),

  /// Créer un exercice.
  exerciceCreate('exercice:create', 'Créer un exercice'),

  /// Modifier un exercice.
  exerciceUpdate('exercice:update', 'Modifier un exercice'),

  /// Supprimer un exercice.
  exerciceDelete('exercice:delete', 'Supprimer un exercice'),

  /// Valider un exercice.
  exerciceValidate('exercice:validate', 'Valider un exercice'),

  /// Voir les ateliers.
  atelierView('atelier:view', 'Voir les ateliers'),

  // ===== Évaluations et Annotations =====
  /// Créer une annotation.
  annotationCreate('annotation:create', 'Créer une annotation'),

  /// Modifier une annotation.
  annotationUpdate('annotation:update', 'Modifier une annotation'),

  /// Faire une évaluation.
  evaluationCreate('evaluation:create', 'Faire une évaluation'),

  /// Valider une évaluation.
  evaluationValidate('evaluation:validate', 'Valider une évaluation'),

  /// Voir les annotations.
  annotationView('annotation:view', 'Voir les annotations'),

  /// Voir les évaluations.
  evaluationView('evaluation:view', 'Voir les évaluations'),

  // ===== Bulletins de Formation =====
  /// Générer un bulletin.
  bulletinGenerate('bulletin:generate', 'Générer un bulletin'),

  /// Valider un bulletin.
  bulletinValidate('bulletin:validate', 'Valider un bulletin'),

  /// Voir les bulletins.
  bulletinView('bulletin:view', 'Voir les bulletins'),

  // ===== Suivi Médical =====
  /// Créer une fiche médicale.
  medicalCreate('medical:create', 'Créer une fiche médicale'),

  /// Modifier une fiche médicale.
  medicalUpdate('medical:update', 'Modifier une fiche médicale'),

  /// Voir les fiches médicales.
  medicalView('medical:view', 'Voir les fiches médicales'),

  /// Conseiller les encadreurs (suivi médical).
  medicalAdvise('medical:advise', 'Conseiller les encadreurs'),

  // ===== Gestion du Matériel =====
  /// Ajouter du matériel.
  materielCreate('materiel:create', 'Ajouter du matériel'),

  /// Modifier le matériel.
  materielUpdate('materiel:update', 'Modifier le matériel'),

  /// Supprimer du matériel.
  materielDelete('materiel:delete', 'Supprimer du matériel'),

  /// Affecter du matériel à une séance.
  materielAssign('materiel:assign', 'Affecter du matériel'),

  /// Voir le matériel.
  materielView('materiel:view', 'Voir le matériel'),

  // ===== Discipline et Suivi Comportemental =====
  /// Enregistrer un incident disciplinaire.
  incidentCreate('incident:create', 'Enregistrer un incident'),

  /// Modifier un incident disciplinaire.
  incidentUpdate('incident:update', 'Modifier un incident'),

  /// Voir les incidents disciplinaires.
  incidentView('incident:view', 'Voir les incidents'),

  /// Suivi discipline des encadreurs.
  disciplineEncadreur('discipline:encadreur', 'Suivi discipline encadreurs'),

  /// Suivi discipline des académiciens.
  disciplineAcademicien('discipline:academicien', 'Suivi discipline académiciens'),

  // ===== Scanner QR et Présences =====
  /// Scanner un QR code.
  qrScan('qr:scan', 'Scanner un QR'),

  /// Enregistrer une présence.
  presenceCreate('presence:create', 'Enregistrer une présence'),

  /// Voir les présences.
  presenceView('presence:view', 'Voir les présences'),

  // ===== Communication (SMS) =====
  /// Envoyer un SMS.
  smsSend('sms:send', 'Envoyer un SMS'),

  /// Voir l'historique SMS.
  smsView('sms:view', 'Voir l\'historique SMS'),

  // ===== Référentiels =====
  /// Ajouter un poste football.
  referentielPosteCreate('referentiel:poste_create', 'Ajouter un poste'),

  /// Modifier un poste football.
  referentielPosteUpdate('referentiel:poste_update', 'Modifier un poste'),

  /// Supprimer un poste football.
  referentielPosteDelete('referentiel:poste_delete', 'Supprimer un poste'),

  /// Ajouter un niveau scolaire.
  referentielNiveauCreate('referentiel:niveau_create', 'Ajouter un niveau scolaire'),

  /// Modifier un niveau scolaire.
  referentielNiveauUpdate('referentiel:niveau_update', 'Modifier un niveau scolaire'),

  /// Supprimer un niveau scolaire.
  referentielNiveauDelete('referentiel:niveau_delete', 'Supprimer un niveau scolaire'),

  /// Voir les référentiels.
  referentielView('referentiel:view', 'Voir les référentiels');

  /// L'identifiant textuel de la permission.
  final String id;

  /// La description de la permission.
  final String description;

  const Permission(this.id, this.description);

  /// Récupère une [Permission] à partir de son identifiant textuel.
  ///
  /// Retourne null si l'identifiant n'est pas trouvé.
  static Permission? tryFromId(String id) {
    for (final permission in Permission.values) {
      if (permission.id == id.toLowerCase()) {
        return permission;
      }
    }
    return null;
  }

  /// Récupère une [Permission] à partir de son identifiant textuel.
  ///
  /// Lance une exception si l'identifiant n'est pas trouvé.
  static Permission fromId(String id) {
    return Permission.values.firstWhere(
      (permission) => permission.id == id.toLowerCase(),
      orElse: () => throw ArgumentError('Permission non trouvée: $id'),
    );
  }
}

/// Map des permissions par rôle selon la matrice des habilitations.
///
/// Cette map définit quelles permissions sont accordées à chaque rôle.
/// Les rôles de niveau supérieur héritent des permissions des rôles inférieurs.
const Map<Role, Set<Permission>> rolePermissions = {
  Role.supAdmin: {
    // SupAdmin possède toutes les permissions
    ...Permission.values,
  },
  Role.admin: {
    // Gestion des utilisateurs
    Permission.userCreate,
    Permission.userUpdate,
    Permission.userDelete,
    Permission.userAssignRole,
    Permission.userView,
    // Gestion des saisons
    Permission.seasonOpen,
    Permission.seasonClose,
    Permission.seasonView,
    // Gestion des académiciens
    Permission.academicienCreate,
    Permission.academicienUpdate,
    Permission.academicienDelete,
    Permission.academicienView,
    // Gestion des encadreurs
    Permission.encadreurCreate,
    Permission.encadreurUpdate,
    Permission.encadreurDelete,
    Permission.encadreurView,
    // Gestion des séances
    Permission.seanceOpen,
    Permission.seanceClose,
    Permission.seanceView,
    // Gestion des entraînements
    Permission.entrainementCreate,
    Permission.entrainementUpdate,
    Permission.entrainementDelete,
    Permission.entrainementApply,
    Permission.entrainementView,
    // Gestion des ateliers
    Permission.atelierCreate,
    Permission.atelierUpdate,
    Permission.atelierDelete,
    Permission.exerciceCreate,
    Permission.exerciceUpdate,
    Permission.exerciceDelete,
    Permission.exerciceValidate,
    Permission.atelierView,
    // Évaluations et annotations
    Permission.annotationCreate,
    Permission.annotationUpdate,
    Permission.evaluationCreate,
    Permission.evaluationValidate,
    Permission.annotationView,
    Permission.evaluationView,
    // Bulletins
    Permission.bulletinGenerate,
    Permission.bulletinValidate,
    Permission.bulletinView,
    // Suivi médical
    Permission.medicalCreate,
    Permission.medicalUpdate,
    Permission.medicalView,
    Permission.medicalAdvise,
    // Matériel
    Permission.materielCreate,
    Permission.materielUpdate,
    Permission.materielDelete,
    Permission.materielAssign,
    Permission.materielView,
    // Discipline
    Permission.incidentCreate,
    Permission.incidentUpdate,
    Permission.incidentView,
    Permission.disciplineEncadreur,
    Permission.disciplineAcademicien,
    // QR et présences
    Permission.qrScan,
    Permission.presenceCreate,
    Permission.presenceView,
    // SMS
    Permission.smsSend,
    Permission.smsView,
    // Référentiels
    Permission.referentielPosteCreate,
    Permission.referentielPosteUpdate,
    Permission.referentielPosteDelete,
    Permission.referentielNiveauCreate,
    Permission.referentielNiveauUpdate,
    Permission.referentielNiveauDelete,
    Permission.referentielView,
  },
  Role.encadreurChef: {
    // Utilisateurs (lecture seule)
    Permission.userView,
    // Saisons (lecture seule)
    Permission.seasonView,
    // Académiciens
    Permission.academicienCreate,
    Permission.academicienUpdate,
    Permission.academicienView,
    // Encadreurs
    Permission.encadreurCreate,
    Permission.encadreurUpdate,
    Permission.encadreurView,
    // Séances
    Permission.seanceOpen,
    Permission.seanceClose,
    Permission.seanceView,
    // Entraînements
    Permission.entrainementCreate,
    Permission.entrainementUpdate,
    Permission.entrainementDelete,
    Permission.entrainementApply,
    Permission.entrainementView,
    // Ateliers
    Permission.atelierCreate,
    Permission.atelierUpdate,
    Permission.atelierDelete,
    Permission.exerciceCreate,
    Permission.exerciceUpdate,
    Permission.exerciceDelete,
    Permission.exerciceValidate,
    Permission.atelierView,
    // Évaluations et annotations
    Permission.annotationCreate,
    Permission.annotationUpdate,
    Permission.evaluationCreate,
    Permission.evaluationValidate,
    Permission.annotationView,
    Permission.evaluationView,
    // Bulletins
    Permission.bulletinGenerate,
    Permission.bulletinValidate,
    Permission.bulletinView,
    // Médical (lecture seule)
    Permission.medicalView,
    // Matériel (lecture seule)
    Permission.materielView,
    // Discipline
    Permission.incidentCreate,
    Permission.incidentUpdate,
    Permission.incidentView,
    Permission.disciplineEncadreur,
    Permission.disciplineAcademicien,
    // QR et présences
    Permission.qrScan,
    Permission.presenceCreate,
    Permission.presenceView,
    // SMS
    Permission.smsSend,
    Permission.smsView,
    // Référentiels (lecture seule)
    Permission.referentielView,
  },
  Role.medecinChef: {
    // Utilisateurs (lecture seule)
    Permission.userView,
    // Saisons (lecture seule)
    Permission.seasonView,
    // Académiciens (lecture seule)
    Permission.academicienView,
    // Encadreurs (lecture seule)
    Permission.encadreurView,
    // Séances (lecture seule)
    Permission.seanceView,
    // Entraînements (lecture seule)
    Permission.entrainementView,
    // Ateliers (lecture seule)
    Permission.atelierView,
    // Évaluations (lecture seule)
    Permission.annotationView,
    Permission.evaluationView,
    // Bulletins (lecture seule)
    Permission.bulletinView,
    // Médical (complet)
    Permission.medicalCreate,
    Permission.medicalUpdate,
    Permission.medicalView,
    Permission.medicalAdvise,
    // Incidents (lecture seule)
    Permission.incidentView,
    // Présences (lecture seule)
    Permission.presenceView,
    // Référentiels (lecture seule)
    Permission.referentielView,
  },
  Role.encadreur: {
    // Utilisateurs (lecture seule)
    Permission.userView,
    // Saisons (lecture seule)
    Permission.seasonView,
    // Académiciens
    Permission.academicienCreate,
    Permission.academicienUpdate,
    Permission.academicienView,
    // Encadreurs (lecture seule)
    Permission.encadreurView,
    // Séances
    Permission.seanceOpen,
    Permission.seanceClose,
    Permission.seanceView,
    // Entraînements (appliquer et voir)
    Permission.entrainementApply,
    Permission.entrainementView,
    // Ateliers (lecture seule)
    Permission.atelierView,
    // Évaluations et annotations
    Permission.annotationCreate,
    Permission.annotationUpdate,
    Permission.evaluationCreate,
    Permission.annotationView,
    Permission.evaluationView,
    // Bulletins
    Permission.bulletinGenerate,
    Permission.bulletinView,
    // Incidents
    Permission.incidentCreate,
    Permission.incidentView,
    Permission.disciplineAcademicien,
    // QR et présences
    Permission.qrScan,
    Permission.presenceCreate,
    Permission.presenceView,
    // SMS
    Permission.smsSend,
    Permission.smsView,
    // Référentiels (lecture seule)
    Permission.referentielView,
  },
  Role.surveillantGeneral: {
    // Utilisateurs (lecture seule)
    Permission.userView,
    // Saisons (lecture seule)
    Permission.seasonView,
    // Académiciens (lecture seule)
    Permission.academicienView,
    // Encadreurs (lecture seule)
    Permission.encadreurView,
    // Séances (lecture seule)
    Permission.seanceView,
    // Entraînements (lecture seule)
    Permission.entrainementView,
    // Ateliers (lecture seule)
    Permission.atelierView,
    // Évaluations (lecture seule)
    Permission.annotationView,
    Permission.evaluationView,
    // Bulletins (lecture seule)
    Permission.bulletinView,
    // Matériel (complet sauf suppression)
    Permission.materielCreate,
    Permission.materielUpdate,
    Permission.materielAssign,
    Permission.materielView,
    // Discipline
    Permission.incidentCreate,
    Permission.incidentUpdate,
    Permission.incidentView,
    Permission.disciplineEncadreur,
    Permission.disciplineAcademicien,
    // QR et présences
    Permission.qrScan,
    Permission.presenceCreate,
    Permission.presenceView,
    // Référentiels (lecture seule)
    Permission.referentielView,
  },
  Role.visiteur: {
    // Lecture seule sur toutes les ressources
    Permission.userView,
    Permission.seasonView,
    Permission.academicienView,
    Permission.encadreurView,
    Permission.seanceView,
    Permission.entrainementView,
    Permission.atelierView,
    Permission.annotationView,
    Permission.evaluationView,
    Permission.bulletinView,
    Permission.materielView,
    Permission.incidentView,
    Permission.presenceView,
    Permission.referentielView,
  },
};

/// Extension pour vérifier les permissions d'un rôle.
extension RolePermissionsExtension on Role {
  /// Retourne l'ensemble des permissions accordées à ce rôle.
  Set<Permission> get permissions => rolePermissions[this] ?? {};

  /// Vérifie si ce rôle possède une permission spécifique.
  bool hasPermission(Permission permission) => permissions.contains(permission);

  /// Vérifie si ce rôle possède toutes les permissions spécifiées.
  bool hasAllPermissions(Iterable<Permission> perms) =>
      perms.every(permissions.contains);

  /// Vérifie si ce rôle possède au moins une des permissions spécifiées.
  bool hasAnyPermission(Iterable<Permission> perms) =>
      perms.any(permissions.contains);
}
