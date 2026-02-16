import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import 'app_preferences.dart';

/// Service applicatif gerant le journal d'activites.
/// Centralise l'enregistrement et la recuperation des evenements
/// pour le fil d'activites du dashboard.
class ActivityService {
  final ActivityRepository _repository;
  final AppPreferences _preferences;

  ActivityService({
    required ActivityRepository repository,
    required AppPreferences preferences,
  }) : _repository = repository,
       _preferences = preferences;

  /// Enregistre une activite dans le journal.
  /// L'utilisateur est automatiquement recupere depuis les preferences.
  Future<Activity> enregistrer({
    required ActivityType type,
    required String titre,
    required String description,
    String? referenceId,
  }) async {
    final utilisateurId = await _preferences.getUserId();
    final utilisateurNom = await _preferences.getUserName();
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      titre: titre,
      description: description,
      date: DateTime.now(),
      referenceId: referenceId,
      utilisateurId: utilisateurId,
      utilisateurNom: utilisateurNom,
    );
    return _repository.add(activity);
  }

  /// Recupere les N dernieres activites (par defaut 15).
  Future<List<Activity>> getActivitesRecentes({int limit = 15}) async {
    return _repository.getRecent(limit);
  }

  /// Recupere toutes les activites.
  Future<List<Activity>> getAllActivites() async {
    return _repository.getAll();
  }

  /// Purge les activites de plus de 30 jours.
  Future<void> purgerAnciennesActivites() async {
    final limite = DateTime.now().subtract(const Duration(days: 30));
    await _repository.purgeOlderThan(limite);
  }

  // --- Methodes utilitaires pour chaque type d'activite ---

  /// Enregistre l'ouverture d'une seance.
  Future<void> enregistrerSeanceOuverte(String titre, String seanceId) async {
    await enregistrer(
      type: ActivityType.seanceOuverte,
      titre: 'Seance ouverte',
      description: titre,
      referenceId: seanceId,
    );
  }

  /// Enregistre la cloture d'une seance.
  Future<void> enregistrerSeanceCloturee(
    String titre,
    int nbPresents,
    String seanceId,
  ) async {
    await enregistrer(
      type: ActivityType.seanceCloturee,
      titre: 'Seance cloturee',
      description: '$titre - $nbPresents presents',
      referenceId: seanceId,
    );
  }

  /// Enregistre la programmation d'une seance.
  Future<void> enregistrerSeanceProgrammee(
    String titre,
    String seanceId,
  ) async {
    await enregistrer(
      type: ActivityType.seanceProgrammee,
      titre: 'Seance programmee',
      description: titre,
      referenceId: seanceId,
    );
  }

  /// Enregistre l'inscription d'un academicien.
  Future<void> enregistrerAcademicienInscrit(
    String nomComplet,
    String academicienId,
  ) async {
    await enregistrer(
      type: ActivityType.academicienInscrit,
      titre: 'Nouvel academicien',
      description: '$nomComplet inscrit avec succes',
      referenceId: academicienId,
    );
  }

  /// Enregistre la suppression d'un academicien.
  Future<void> enregistrerAcademicienSupprime(
    String nomComplet,
    String academicienId,
  ) async {
    await enregistrer(
      type: ActivityType.academicienSupprime,
      titre: 'Academicien supprime',
      description: '$nomComplet supprime du systeme',
      referenceId: academicienId,
    );
  }

  /// Enregistre l'inscription d'un encadreur.
  Future<void> enregistrerEncadreurInscrit(
    String nomComplet,
    String specialite,
    String encadreurId,
  ) async {
    await enregistrer(
      type: ActivityType.encadreurInscrit,
      titre: 'Nouvel encadreur',
      description: '$nomComplet - $specialite',
      referenceId: encadreurId,
    );
  }

  /// Enregistre un scan de presence.
  Future<void> enregistrerPresence(
    String typeProfil,
    String nomComplet,
    String presenceId,
  ) async {
    await enregistrer(
      type: ActivityType.presenceEnregistree,
      titre: 'Presence enregistree',
      description: '$typeProfil : $nomComplet',
      referenceId: presenceId,
    );
  }

  /// Enregistre l'envoi d'un SMS.
  Future<void> enregistrerSmsEnvoye(
    int nbDestinataires,
    String apercu,
    String smsId,
  ) async {
    await enregistrer(
      type: ActivityType.smsEnvoye,
      titre: 'SMS envoye',
      description: '$nbDestinataires destinataires - $apercu',
      referenceId: smsId,
    );
  }

  /// Enregistre un echec d'envoi SMS.
  Future<void> enregistrerSmsEchec(String smsId) async {
    await enregistrer(
      type: ActivityType.smsEchec,
      titre: 'SMS en echec',
      description: 'Echec de l\'envoi du message',
      referenceId: smsId,
    );
  }

  /// Enregistre la generation d'un bulletin.
  Future<void> enregistrerBulletinGenere(
    String periodeLabel,
    String academicienNom,
    String bulletinId,
  ) async {
    await enregistrer(
      type: ActivityType.bulletinGenere,
      titre: 'Bulletin genere',
      description: '$periodeLabel - $academicienNom',
      referenceId: bulletinId,
    );
  }

  /// Enregistre l'ajout d'un poste de football.
  Future<void> enregistrerPosteAjoute(String nom) async {
    await enregistrer(
      type: ActivityType.referentielPosteAjoute,
      titre: 'Referentiel mis a jour',
      description: 'Nouveau poste : $nom',
    );
  }

  /// Enregistre la modification d'un poste de football.
  Future<void> enregistrerPosteModifie(String nom) async {
    await enregistrer(
      type: ActivityType.referentielPosteModifie,
      titre: 'Referentiel mis a jour',
      description: 'Poste modifie : $nom',
    );
  }

  /// Enregistre la suppression d'un poste de football.
  Future<void> enregistrerPosteSupprime(String nom) async {
    await enregistrer(
      type: ActivityType.referentielPosteSupprime,
      titre: 'Referentiel mis a jour',
      description: 'Poste supprime : $nom',
    );
  }

  /// Enregistre l'ajout d'un niveau scolaire.
  Future<void> enregistrerNiveauAjoute(String nom) async {
    await enregistrer(
      type: ActivityType.referentielNiveauAjoute,
      titre: 'Referentiel mis a jour',
      description: 'Nouveau niveau : $nom',
    );
  }

  /// Enregistre la modification d'un niveau scolaire.
  Future<void> enregistrerNiveauModifie(String nom) async {
    await enregistrer(
      type: ActivityType.referentielNiveauModifie,
      titre: 'Referentiel mis a jour',
      description: 'Niveau modifie : $nom',
    );
  }

  /// Enregistre la suppression d'un niveau scolaire.
  Future<void> enregistrerNiveauSupprime(String nom) async {
    await enregistrer(
      type: ActivityType.referentielNiveauSupprime,
      titre: 'Referentiel mis a jour',
      description: 'Niveau supprime : $nom',
    );
  }
}
