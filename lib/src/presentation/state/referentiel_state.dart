import 'package:flutter/material.dart';
import '../../application/services/referentiel_service.dart';
import '../../domain/entities/poste_football.dart';
import '../../domain/entities/niveau_scolaire.dart';

/// State management pour les referentiels (postes de football et niveaux scolaires).
/// Gere le chargement, la creation, la modification et la suppression.
class ReferentielState extends ChangeNotifier {
  final ReferentielService _service;

  ReferentielState(this._service);

  // --- Postes de football ---
  List<PosteFootball> _postes = [];
  List<PosteFootball> get postes => _postes;

  // --- Niveaux scolaires ---
  List<NiveauScolaire> _niveaux = [];
  List<NiveauScolaire> get niveaux => _niveaux;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  /// Charge tous les postes de football.
  Future<void> chargerPostes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _postes = await _service.getAllPostes();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des postes : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cree un nouveau poste de football.
  Future<bool> creerPoste({
    required String nom,
    String? description,
  }) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _service.creerPoste(
        nom: nom,
        description: description,
      );
      if (result.success) {
        _successMessage = result.message;
        await chargerPostes();
        return true;
      } else {
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la creation : $e';
      notifyListeners();
      return false;
    }
  }

  /// Modifie un poste de football existant.
  Future<bool> modifierPoste(PosteFootball poste) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _service.modifierPoste(poste);
      if (result.success) {
        _successMessage = result.message;
        await chargerPostes();
        return true;
      } else {
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification : $e';
      notifyListeners();
      return false;
    }
  }

  /// Supprime un poste de football.
  Future<bool> supprimerPoste(String id) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _service.supprimerPoste(id);
      if (result.success) {
        _successMessage = result.message;
        await chargerPostes();
        return true;
      } else {
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      notifyListeners();
      return false;
    }
  }

  /// Charge tous les niveaux scolaires.
  Future<void> chargerNiveaux() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _niveaux = await _service.getAllNiveaux();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des niveaux : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cree un nouveau niveau scolaire.
  Future<bool> creerNiveau({
    required String nom,
    required int ordre,
  }) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _service.creerNiveau(nom: nom, ordre: ordre);
      if (result.success) {
        _successMessage = result.message;
        await chargerNiveaux();
        return true;
      } else {
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la creation : $e';
      notifyListeners();
      return false;
    }
  }

  /// Modifie un niveau scolaire existant.
  Future<bool> modifierNiveau(NiveauScolaire niveau) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _service.modifierNiveau(niveau);
      if (result.success) {
        _successMessage = result.message;
        await chargerNiveaux();
        return true;
      } else {
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification : $e';
      notifyListeners();
      return false;
    }
  }

  /// Supprime un niveau scolaire.
  Future<bool> supprimerNiveau(String id) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _service.supprimerNiveau(id);
      if (result.success) {
        _successMessage = result.message;
        await chargerNiveaux();
        return true;
      } else {
        _errorMessage = result.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      notifyListeners();
      return false;
    }
  }

  /// Efface les messages de succes/erreur.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
