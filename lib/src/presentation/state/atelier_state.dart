import 'package:flutter/material.dart';
import '../../application/services/atelier_service.dart';
import '../../domain/entities/atelier.dart';

/// State management pour les ateliers d'une seance.
/// Gere le chargement, l'ajout, la modification, la suppression
/// et la reorganisation des ateliers.
class AtelierState extends ChangeNotifier {
  final AtelierService _service;

  AtelierState(this._service);

  List<Atelier> _ateliers = [];
  List<Atelier> get ateliers => _ateliers;

  String? _seanceId;
  String? get seanceId => _seanceId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  /// Charge les ateliers d'une seance.
  Future<void> chargerAteliers(String seanceId) async {
    _seanceId = seanceId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ateliers = await _service.getAteliersParSeance(seanceId);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des ateliers : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute un atelier a la seance courante.
  Future<bool> ajouterAtelier({
    required String nom,
    required AtelierType type,
    String description = '',
  }) async {
    if (_seanceId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.ajouterAtelier(
        seanceId: _seanceId!,
        nom: nom,
        type: type,
        description: description,
      );
      _successMessage = 'Atelier "$nom" ajoute avec succes.';
      await chargerAteliers(_seanceId!);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Modifie un atelier existant.
  Future<bool> modifierAtelier(Atelier atelier) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.modifierAtelier(atelier);
      _successMessage = 'Atelier "${atelier.nom}" modifie avec succes.';
      if (_seanceId != null) {
        await chargerAteliers(_seanceId!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Supprime un atelier.
  Future<bool> supprimerAtelier(String atelierId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.supprimerAtelier(atelierId);
      _successMessage = 'Atelier supprime avec succes.';
      if (_seanceId != null) {
        await chargerAteliers(_seanceId!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reordonne les ateliers par glisser-deposer.
  Future<void> reordonnerAteliers(int oldIndex, int newIndex) async {
    if (_seanceId == null) return;

    // Ajustement de l'index pour le ReorderableListView
    if (newIndex > oldIndex) newIndex--;

    final atelier = _ateliers.removeAt(oldIndex);
    _ateliers.insert(newIndex, atelier);
    notifyListeners();

    try {
      final ids = _ateliers.map((a) => a.id).toList();
      await _service.reordonnerAteliers(_seanceId!, ids);
      await chargerAteliers(_seanceId!);
    } catch (e) {
      _errorMessage = 'Erreur lors de la reorganisation : $e';
      notifyListeners();
    }
  }

  /// Efface les messages de succes/erreur.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
