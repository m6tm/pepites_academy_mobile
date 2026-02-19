import '../../../l10n/app_localizations.dart';
import '../../domain/entities/seance.dart';
import '../../domain/repositories/presence_repository.dart';
import '../../domain/repositories/seance_repository.dart';
import 'activity_service.dart';

/// Resultat d'une tentative d'ouverture de seance.
class OuvertureResult {
  final bool success;
  final String message;
  final Seance? seance;
  final Seance? seanceBloqueante;

  const OuvertureResult({
    required this.success,
    required this.message,
    this.seance,
    this.seanceBloqueante,
  });
}

/// Resultat de la fermeture d'une seance avec recapitulatif.
class FermetureResult {
  final bool success;
  final String message;
  final Seance? seance;
  final int nbPresents;
  final int nbAteliers;

  const FermetureResult({
    required this.success,
    required this.message,
    this.seance,
    this.nbPresents = 0,
    this.nbAteliers = 0,
  });
}

/// Service applicatif gerant la logique metier des seances.
/// Gere le cycle de vie complet : creation, ouverture, fermeture.
class SeanceService {
  final SeanceRepository _seanceRepository;
  final PresenceRepository _presenceRepository;
  ActivityService? _activityService;
  AppLocalizations? _l10n;

  SeanceService({
    required SeanceRepository seanceRepository,
    required PresenceRepository presenceRepository,
  }) : _seanceRepository = seanceRepository,
       _presenceRepository = presenceRepository;

  /// Injecte le service d'activites.
  void setActivityService(ActivityService service) {
    _activityService = service;
  }

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Recupere toutes les seances triees par date decroissante.
  Future<List<Seance>> getAllSeances() async {
    final seances = await _seanceRepository.getAll();
    seances.sort((a, b) => b.date.compareTo(a.date));
    return seances;
  }

  /// Recupere une seance par son identifiant.
  Future<Seance?> getSeanceById(String id) async {
    return _seanceRepository.getById(id);
  }

  /// Recupere la seance actuellement ouverte.
  Future<Seance?> getSeanceOuverte() async {
    return _seanceRepository.getSeanceOuverte();
  }

  /// Tente d'ouvrir une nouvelle seance.
  /// Verifie qu'aucune seance n'est deja ouverte avant d'autoriser l'ouverture.
  Future<OuvertureResult> ouvrirSeance({
    required String titre,
    required DateTime date,
    required DateTime heureDebut,
    required DateTime heureFin,
    required String encadreurResponsableId,
  }) async {
    final seanceOuverte = await _seanceRepository.getSeanceOuverte();

    if (seanceOuverte != null) {
      return OuvertureResult(
        success: false,
        message:
            _l10n?.serviceSeanceCannotOpen(seanceOuverte.titre) ??
            'Impossible d\'ouvrir une nouvelle seance. '
                'La seance "${seanceOuverte.titre}" est encore ouverte. '
                'Veuillez la cloturer avant d\'en ouvrir une nouvelle.',
        seanceBloqueante: seanceOuverte,
      );
    }

    final seance = Seance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titre: titre,
      date: date,
      heureDebut: heureDebut,
      heureFin: heureFin,
      statut: SeanceStatus.ouverte,
      encadreurResponsableId: encadreurResponsableId,
    );

    final created = await _seanceRepository.create(seance);
    await _activityService?.enregistrerSeanceOuverte(titre, created.id);
    return OuvertureResult(
      success: true,
      message:
          _l10n?.serviceSeanceOpenedSuccess(titre) ??
          'Seance "$titre" ouverte avec succes.',
      seance: created,
    );
  }

  /// Cloture une seance et retourne un recapitulatif.
  Future<FermetureResult> fermerSeance(String seanceId) async {
    final seance = await _seanceRepository.getById(seanceId);
    if (seance == null) {
      return FermetureResult(
        success: false,
        message: _l10n?.serviceSeanceNotFound ?? 'Seance introuvable.',
      );
    }

    if (seance.estFermee) {
      return FermetureResult(
        success: false,
        message:
            _l10n?.serviceSeanceAlreadyClosed ??
            'Cette seance est deja cloturee.',
        seance: seance,
      );
    }

    final presences = await _presenceRepository.getBySeance(seanceId);
    final nbPresents = presences.length;
    final nbAteliers = seance.atelierIds.length;

    final updated = seance.copyWith(
      statut: SeanceStatus.fermee,
      nbPresents: nbPresents,
      nbAteliers: nbAteliers,
    );

    final fermee = await _seanceRepository.update(updated);
    await _activityService?.enregistrerSeanceCloturee(
      seance.titre,
      nbPresents,
      fermee.id,
    );

    return FermetureResult(
      success: true,
      message:
          _l10n?.serviceSeanceClosedSuccess(seance.titre) ??
          'Seance "${seance.titre}" cloturee avec succes.',
      seance: fermee,
      nbPresents: nbPresents,
      nbAteliers: nbAteliers,
    );
  }

  /// Recupere le nombre de presents pour une seance.
  Future<int> getNbPresents(String seanceId) async {
    final presences = await _presenceRepository.getBySeance(seanceId);
    return presences.length;
  }

  /// Filtre les seances par statut.
  Future<List<Seance>> getSeancesParStatut(SeanceStatus statut) async {
    final seances = await getAllSeances();
    return seances.where((s) => s.statut == statut).toList();
  }
}
