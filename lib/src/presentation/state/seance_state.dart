import 'package:flutter/material.dart';
import '../../application/services/seance_service.dart';
import '../../domain/entities/seance.dart';

/// Filtre applicable sur la liste des seances.
enum SeanceFilter { toutes, enCours, terminees, aVenir }

/// State management pour les seances d'entrainement.
/// Gere le chargement, le filtrage, l'ouverture et la fermeture des seances.
class SeanceState extends ChangeNotifier {
  final SeanceService _service;

  SeanceState(this._service);

  List<Seance> _seances = [];
  List<Seance> get seances => _seancesFiltrees;

  Seance? _seanceOuverte;
  Seance? get seanceOuverte => _seanceOuverte;

  SeanceFilter _filtre = SeanceFilter.toutes;
  SeanceFilter get filtre => _filtre;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  /// Retourne les seances filtrees selon le filtre actif.
  List<Seance> get _seancesFiltrees {
    switch (_filtre) {
      case SeanceFilter.toutes:
        return _seances;
      case SeanceFilter.enCours:
        return _seances.where((s) => s.estOuverte).toList();
      case SeanceFilter.terminees:
        return _seances.where((s) => s.estFermee).toList();
      case SeanceFilter.aVenir:
        return _seances.where((s) => s.estAVenir).toList();
    }
  }

  /// Charge toutes les seances et la seance ouverte.
  Future<void> chargerSeances() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _seances = await _service.getAllSeances();
      _seanceOuverte = await _service.getSeanceOuverte();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des seances : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change le filtre actif.
  void setFiltre(SeanceFilter filtre) {
    _filtre = filtre;
    notifyListeners();
  }

  /// Tente d'ouvrir une nouvelle seance.
  Future<OuvertureResult> ouvrirSeance({
    required String titre,
    required DateTime date,
    required DateTime heureDebut,
    required DateTime heureFin,
    required String encadreurResponsableId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _service.ouvrirSeance(
        titre: titre,
        date: date,
        heureDebut: heureDebut,
        heureFin: heureFin,
        encadreurResponsableId: encadreurResponsableId,
      );

      if (result.success) {
        _successMessage = result.message;
        await chargerSeances();
      } else {
        _errorMessage = result.message;
        _isLoading = false;
        notifyListeners();
      }

      return result;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ouverture : $e';
      _isLoading = false;
      notifyListeners();
      return OuvertureResult(
        success: false,
        message: _errorMessage!,
      );
    }
  }

  /// Ferme la seance specifiee et retourne un recapitulatif.
  Future<FermetureResult> fermerSeance(String seanceId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _service.fermerSeance(seanceId);

      if (result.success) {
        _successMessage = result.message;
        await chargerSeances();
      } else {
        _errorMessage = result.message;
        _isLoading = false;
        notifyListeners();
      }

      return result;
    } catch (e) {
      _errorMessage = 'Erreur lors de la fermeture : $e';
      _isLoading = false;
      notifyListeners();
      return FermetureResult(
        success: false,
        message: _errorMessage!,
      );
    }
  }

  /// Efface les messages de succes/erreur.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
