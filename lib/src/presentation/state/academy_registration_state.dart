import 'package:flutter/material.dart';

class AcademyRegistrationState extends ChangeNotifier {
  // Step 1: Personal Info
  String? nom;
  String? prenom;
  DateTime? dateNaissance;
  String? telephoneParent;
  String? photoPath;

  // Step 2: Football Info
  String? posteFootballId;
  String? piedFort; // Gaucher, Droitier, Ambidextre

  // Step 3: School Info
  String? niveauScolaireId;

  // Flow control
  int _currentStep = 0;
  int get currentStep => _currentStep;

  void nextStep() {
    if (_currentStep < 3) {
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

  void setPersonalInfo({
    String? nom,
    String? prenom,
    DateTime? dateNaissance,
    String? telephoneParent,
    String? photoPath,
  }) {
    if (nom != null) this.nom = nom;
    if (prenom != null) this.prenom = prenom;
    if (dateNaissance != null) this.dateNaissance = dateNaissance;
    if (telephoneParent != null) this.telephoneParent = telephoneParent;
    if (photoPath != null) this.photoPath = photoPath;
    notifyListeners();
  }

  void setFootballInfo({String? posteId, String? piedFort}) {
    if (posteId != null) posteFootballId = posteId;
    if (piedFort != null) this.piedFort = piedFort;
    notifyListeners();
  }

  void setSchoolInfo({String? niveauId}) {
    if (niveauId != null) niveauScolaireId = niveauId;
    notifyListeners();
  }

  bool get isStep1Valid =>
      nom != null &&
      nom!.isNotEmpty &&
      prenom != null &&
      prenom!.isNotEmpty &&
      dateNaissance != null &&
      telephoneParent != null &&
      telephoneParent!.isNotEmpty;

  bool get isStep2Valid => posteFootballId != null && piedFort != null;

  bool get isStep3Valid => niveauScolaireId != null;

  bool get canConfirm => isStep1Valid && isStep2Valid && isStep3Valid;
}
