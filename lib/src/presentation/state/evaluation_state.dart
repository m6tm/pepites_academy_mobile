import 'package:flutter/material.dart';
import '../../application/services/evaluation_service.dart';
import '../../core/events/app_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/evaluation_events.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/entities/atelier.dart';
import 'message_state_mixin.dart';

/// State management pour les evaluations multicriteres d'un atelier.
/// Gere la creation d'evaluations et le suivi des scores en temps reel.
class EvaluationState extends ChangeNotifier
    with MessageStateMixin, EventBusSubscriberMixin {
  final EvaluationService _service;
  final DomainEventBus _eventBus;
  bool _isDisposed = false;

  DateTime? _lastFetchedAt;

  EvaluationState(this._service, this._eventBus) {
    listenTo<AppResumedEvent>(_eventBus, _onAppResumed);
    listenTo<EvaluationCreeeEvent>(_eventBus, (e) => _onEvaluationChanged(e.atelierId));
    listenTo<EvaluationUpdatedEvent>(_eventBus, (e) => _onEvaluationChanged(e.atelierId));
    listenTo<EvaluationDeletedEvent>(_eventBus, (_) => _onEvaluationChanged(null));
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  List<Evaluation> _evaluationsAtelier = [];
  List<Evaluation> get evaluationsAtelier => _evaluationsAtelier;

  List<Evaluation> _historiqueAcademicien = [];
  List<Evaluation> get historiqueAcademicien => _historiqueAcademicien;

  String? _atelierId;
  String? get atelierId => _atelierId;

  String? _seanceId;
  String? get seanceId => _seanceId;

  String? _academicienSelectionneId;
  String? get academicienSelectionneId => _academicienSelectionneId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  @override
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  @override
  String? get successMessage => _successMessage;

  // Scores en cours de saisie (mutable pendant l'evaluation)
  final Map<String, double> _notesEnCours = {};
  Map<String, double> get notesEnCours => Map.unmodifiable(_notesEnCours);

  /// Initialise le contexte de l'atelier pour les evaluations.
  Future<void> initialiserContexte({
    required String atelierId,
    required String seanceId,
  }) async {
    _atelierId = atelierId;
    _seanceId = seanceId;
    await chargerEvaluationsAtelier();
  }

  /// Charge toutes les evaluations de l'atelier courant.
  Future<void> chargerEvaluationsAtelier() async {
    if (_atelierId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _evaluationsAtelier = await _service.getEvaluationsAtelier(_atelierId!);
      _lastFetchedAt = DateTime.now();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des evaluations : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selectionne un academicien et charge son historique.
  Future<void> selectionnerAcademicien(String academicienId) async {
    _academicienSelectionneId = academicienId;
    _notesEnCours.clear();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historiqueAcademicien = await _service.getEvaluationsAcademicien(
        academicienId,
      );
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement de l\'historique : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deselectionne l'academicien courant.
  void deselectionnerAcademicien() {
    _academicienSelectionneId = null;
    _historiqueAcademicien = [];
    _notesEnCours.clear();
    notifyListeners();
  }

  /// Met a jour une note en cours de saisie.
  /// La cle est formatee comme "critereId_elementId".
  void mettreAJourNote(String critereId, String elementId, double note) {
    _notesEnCours['${critereId}_$elementId'] = note;
    notifyListeners();
  }

  /// Recupere la note en cours pour un element donne.
  double getNoteEnCours(String critereId, String elementId) {
    return _notesEnCours['${critereId}_$elementId'] ?? 0.0;
  }

  /// Calcule le sous-total d'un critere en cours de saisie.
  double getSousTotalCritere(
    String critereId,
    List<String> elementIds,
  ) {
    final notes = elementIds.map((eid) => getNoteEnCours(critereId, eid)).toList();
    if (notes.isEmpty) return 0.0;
    return notes.fold(0.0, (sum, n) => sum + n) / notes.length;
  }

  /// Calcule le score total en cours (moyenne des criteres, sur 5).
  double getScoreTotalEnCours(
    List<ConfigurationElementEvaluation> configuration,
  ) {
    if (configuration.isEmpty) return 0.0;
    double sommeMoyennes = 0;
    for (final config in configuration) {
      sommeMoyennes += getSousTotalCritere(config.critereId, config.elementIds);
    }
    return sommeMoyennes / configuration.length;
  }

  /// Verifie si tous les elements ont ete notes.
  bool tousLesElementsNotes(
    List<ConfigurationElementEvaluation> configuration,
  ) {
    for (final config in configuration) {
      for (final elementId in config.elementIds) {
        if (!_notesEnCours.containsKey('${config.critereId}_$elementId')) {
          return false;
        }
      }
    }
    return true;
  }

  /// Cree l'evaluation a partir des notes en cours, puis emet EvaluationCreeeEvent.
  Future<bool> creerEvaluation({
    required String encadreurId,
    required List<ConfigurationElementEvaluation> configuration,
    String? commentaire,
  }) async {
    if (_academicienSelectionneId == null ||
        _atelierId == null ||
        _seanceId == null) {
      _errorMessage = 'Contexte incomplet pour creer une evaluation.';
      notifyListeners();
      return false;
    }

    if (!tousLesElementsNotes(configuration)) {
      _errorMessage = 'Tous les elements doivent etre notes.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    _successMessage = null;

    try {
      final scores = configuration.map((config) {
        return ScoreCritere(
          critereId: config.critereId,
          elements: config.elementIds.map((eid) => ScoreElement(
            elementId: eid,
            note: getNoteEnCours(config.critereId, eid),
          )).toList(),
        );
      }).toList();

      final evaluation = await _service.creerEvaluation(
        academicienId: _academicienSelectionneId!,
        atelierId: _atelierId!,
        seanceId: _seanceId!,
        encadreurId: encadreurId,
        scores: scores,
        commentaire: commentaire,
      );

      _evaluationsAtelier.insert(0, evaluation);
      _historiqueAcademicien.insert(0, evaluation);
      _notesEnCours.clear();
      _successMessage = 'Evaluation enregistree.';
      notifyListeners();

      _eventBus.emit(EvaluationCreeeEvent(
        evaluationId: evaluation.id,
        academicienId: evaluation.academicienId,
        atelierId: evaluation.atelierId,
        seanceId: evaluation.seanceId,
      ));

      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'enregistrement : $e';
      notifyListeners();
      return false;
    }
  }

  /// Recupere les evaluations de l'atelier pour un academicien donne.
  List<Evaluation> evaluationsPourAcademicien(String academicienId) {
    return _evaluationsAtelier
        .where((e) => e.academicienId == academicienId)
        .toList();
  }

  /// Compte le nombre d'evaluations pour un academicien dans l'atelier.
  int nbEvaluationsPourAcademicien(String academicienId) {
    return _evaluationsAtelier
        .where((e) => e.academicienId == academicienId)
        .length;
  }

  /// Retourne l'historique filtre d'un academicien.
  /// Tous les parametres sont optionnels et peuvent etre combines.
  List<Evaluation> getHistoriqueFiltre({
    DateTime? dateDebut,
    DateTime? dateFin,
    String? atelierId,
    String? critereId,
  }) {
    return _historiqueAcademicien.where((e) {
      if (dateDebut != null && e.horodate.isBefore(dateDebut)) return false;
      if (dateFin != null && e.horodate.isAfter(dateFin)) return false;
      if (atelierId != null && e.atelierId != atelierId) return false;
      if (critereId != null) {
        final concerneParCritere = e.scores.any((s) => s.critereId == critereId);
        if (!concerneParCritere) return false;
      }
      return true;
    }).toList();
  }

  /// Retourne les moyennes par critere sur l'historique filtre.
  /// La cle est le critereId, la valeur est la moyenne des totaux du critere.
  Map<String, double> getMoyennesParCritere({
    DateTime? dateDebut,
    DateTime? dateFin,
    String? atelierId,
  }) {
    final evaluationsFiltrees = getHistoriqueFiltre(
      dateDebut: dateDebut,
      dateFin: dateFin,
      atelierId: atelierId,
    );

    final totauxParCritere = <String, List<double>>{};
    for (final evaluation in evaluationsFiltrees) {
      for (final score in evaluation.scores) {
        totauxParCritere
            .putIfAbsent(score.critereId, () => [])
            .add(score.totalCritere);
      }
    }

    return {
      for (final entry in totauxParCritere.entries)
        entry.key: entry.value.reduce((a, b) => a + b) / entry.value.length,
    };
  }

  @override
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _onEvaluationChanged(String? atelierId) {
    if (atelierId == null || atelierId == _atelierId) {
      chargerEvaluationsAtelier();
    }
  }

  /// Rafraichit les evaluations de l'atelier si les donnees ont plus de 2 minutes.
  /// Appele automatiquement a la reprise de l'application (AppResumedEvent).
  void _onAppResumed(AppResumedEvent _) {
    if (_atelierId == null) return;
    final age = DateTime.now().difference(_lastFetchedAt ?? DateTime(0));
    if (age > const Duration(minutes: 2)) {
      chargerEvaluationsAtelier();
    }
  }
}
