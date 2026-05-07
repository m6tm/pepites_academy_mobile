import 'package:flutter/material.dart';
import '../../application/services/evaluation_service.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/entities/atelier.dart';
import 'message_state_mixin.dart';

/// State management pour les evaluations multicriteres d'un atelier.
/// Gere la creation d'evaluations et le suivi des scores en temps reel.
class EvaluationState extends ChangeNotifier with MessageStateMixin {
  final EvaluationService _service;
  bool _isDisposed = false;

  EvaluationState(this._service);

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
  double getSousTotalCritere(String critereId, String element1Id, String element2Id) {
    final note1 = getNoteEnCours(critereId, element1Id);
    final note2 = getNoteEnCours(critereId, element2Id);
    return note1 + note2;
  }

  /// Calcule le score total en cours (sur 50).
  double getScoreTotalEnCours(List<ConfigurationElementEvaluation> configuration) {
    double total = 0;
    for (final config in configuration) {
      total += getSousTotalCritere(config.critereId, config.element1Id, config.element2Id);
    }
    return total;
  }

  /// Verifie si tous les elements ont ete notes.
  bool tousLesElementsNotes(List<ConfigurationElementEvaluation> configuration) {
    for (final config in configuration) {
      if (!_notesEnCours.containsKey('${config.critereId}_${config.element1Id}')) {
        return false;
      }
      if (!_notesEnCours.containsKey('${config.critereId}_${config.element2Id}')) {
        return false;
      }
    }
    return true;
  }

  /// Cree l'evaluation a partir des notes en cours.
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
          element1Id: config.element1Id,
          noteElement1: getNoteEnCours(config.critereId, config.element1Id),
          element2Id: config.element2Id,
          noteElement2: getNoteEnCours(config.critereId, config.element2Id),
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

  @override
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
