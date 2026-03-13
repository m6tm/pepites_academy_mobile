import 'package:flutter/material.dart';
import '../../application/services/exercice_service.dart';
import '../../domain/entities/exercice.dart';
import 'message_state_mixin.dart';

/// State management pour les exercices d'un atelier.
class ExerciceState extends ChangeNotifier with MessageStateMixin {
  final ExerciceService _service;

  ExerciceState(this._service);

  final Map<String, List<Exercice>> _exercicesParAtelier = {};
  Map<String, List<Exercice>> get exercicesParAtelier => _exercicesParAtelier;

  final Map<String, bool> _loadingStates = {};
  bool isLoading(String atelierId) => _loadingStates[atelierId] ?? false;

  String? _errorMessage;
  @override
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  @override
  String? get successMessage => _successMessage;

  /// Charge les exercices d'un atelier.
  Future<void> chargerExercices(String atelierId) async {
    _loadingStates[atelierId] = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exercices = await _service.getExercicesParAtelier(atelierId);
      _exercicesParAtelier[atelierId] = exercices;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des exercices : $e';
    } finally {
      _loadingStates[atelierId] = false;
      notifyListeners();
    }
  }

  /// Ajoute un exercice.
  Future<bool> ajouterExercice({
    required String atelierId,
    required String nom,
    String description = '',
  }) async {
    _loadingStates[atelierId] = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.ajouterExercice(
        atelierId: atelierId,
        nom: nom,
        description: description,
      );
      _successMessage = 'Exercice "$nom" ajouté avec succès.';
      await chargerExercices(atelierId);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout : $e';
      _loadingStates[atelierId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Modifie un exercice.
  Future<bool> modifierExercice(Exercice exercice) async {
    _loadingStates[exercice.atelierId] = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.modifierExercice(exercice);
      _successMessage = 'Exercice "${exercice.nom}" modifié avec succès.';
      await chargerExercices(exercice.atelierId);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification : $e';
      _loadingStates[exercice.atelierId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Supprime un exercice.
  Future<bool> supprimerExercice(String exerciceId, String atelierId) async {
    _loadingStates[atelierId] = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.supprimerExercice(exerciceId);
      _successMessage = 'Exercice supprimé avec succès.';
      await chargerExercices(atelierId);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      _loadingStates[atelierId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Reordonne les exercices.
  Future<void> reordonnerExercices(String atelierId, int oldIndex, int newIndex) async {
    final list = _exercicesParAtelier[atelierId];
    if (list == null) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    if (oldIndex == newIndex) return;

    final exercice = list.removeAt(oldIndex);
    list.insert(newIndex, exercice);
    notifyListeners();

    try {
      final ids = list.map((e) => e.id).toList();
      await _service.reorderExercices(atelierId, ids);
      await chargerExercices(atelierId);
    } catch (e) {
      _errorMessage = 'Erreur lors de la réorganisation : $e';
      notifyListeners();
    }
  }

  @override
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
