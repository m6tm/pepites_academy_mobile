import 'package:flutter/material.dart';

/// Gestion de l'état du formulaire d'inscription d'un encadreur.
/// Processus en 2 étapes + récapitulatif.
class EncadreurRegistrationState extends ChangeNotifier {
  // Etape 1 : Informations personnelles
  String? nom;
  String? prenom;
  String? telephone;
  String? photoPath;

  // Etape 2 : Informations sportives
  String? specialite;

  // Controle du flux
  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void setPersonalInfo({
    String? nom,
    String? prenom,
    String? telephone,
    String? photoPath,
  }) {
    if (nom != null) this.nom = nom;
    if (prenom != null) this.prenom = prenom;
    if (telephone != null) this.telephone = telephone;
    if (photoPath != null) this.photoPath = photoPath;
    notifyListeners();
  }

  void setSportInfo({String? specialite}) {
    if (specialite != null) this.specialite = specialite;
    notifyListeners();
  }

  bool get isStep1Valid =>
      nom != null &&
      nom!.isNotEmpty &&
      prenom != null &&
      prenom!.isNotEmpty &&
      telephone != null &&
      telephone!.isNotEmpty;

  bool get isStep2Valid => specialite != null && specialite!.isNotEmpty;

  bool get canConfirm => isStep1Valid && isStep2Valid;

  /// Reinitialise l'etat complet du formulaire.
  void reset() {
    nom = null;
    prenom = null;
    telephone = null;
    photoPath = null;
    specialite = null;
    _currentStep = 0;
    _isLoading = false;
    notifyListeners();
  }
}
