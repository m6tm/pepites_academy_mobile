import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../l10n/app_localizations.dart';
import '../../application/services/sync_service.dart';
import '../../domain/entities/dossier_medical.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/dossier_medical_repository.dart';
import '../../infrastructure/services/upload_service.dart';

/// Etat de gestion du formulaire de creation / edition d'un dossier medical.
///
/// Ce ChangeNotifier encapsule la logique de validation, d'upload de signature
/// et de persistance (create / update) via le repository.
class DossierMedicalFormState extends ChangeNotifier {
  final DossierMedicalRepository _repository;
  final UploadService _uploadService;
  final SyncService? _syncService;

  // Champs obligatoires
  DateTime _dateBlessure = DateTime.now();
  String _heureBlessure = '';
  String _lieu = 'entrainement';
  String _lieuPrecision = '';
  String _adversaire = '';

  // Circonstances
  String _circonstancesType = '';
  String _circonstancesTypePrecision = '';
  String _circonstancesPrecision = '';

  // Description / nature
  String _description = '';
  String _partieCorps = '';
  String _partieCorpsPrecision = '';
  String _typeBlessure = '';
  String _typeBlessurePrecision = '';
  String _gravite = '';

  // Premiers soins
  final List<String> _premiersSoins = [];

  // Observations
  String _observations = '';

  // Suivi reeducation
  final List<Map<String, dynamic>> _suiviReeducation = [];

  // Retour progressif
  final List<Map<String, dynamic>> _retourProgressif = [];

  // Validation reprise
  bool _validationRepriseEntrainement = false;
  bool _validationRepriseCompetition = false;
  bool _validationRepriseSurveillance = false;
  String _validationRepriseRecommandation = '';

  // Validation finale
  DateTime? _validationFinaleDate;
  String _responsableMedical = '';
  String _signatureUrl = '';
  File? _signatureFile;

  // Statut
  String _statutReprise = 'en_cours';

  // Meta
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  AppLocalizations? _l10n;

  DossierMedicalFormState(this._repository, this._uploadService, {SyncService? syncService}) : _syncService = syncService;

  /// Met a jour les localisations utilisees pour les messages du state.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  // ------------------------------------------------------------------
  // Getters
  // ------------------------------------------------------------------
  DateTime get dateBlessure => _dateBlessure;
  String get heureBlessure => _heureBlessure;
  String get lieu => _lieu;
  String get lieuPrecision => _lieuPrecision;
  String get adversaire => _adversaire;
  String get circonstancesType => _circonstancesType;
  String get circonstancesTypePrecision => _circonstancesTypePrecision;
  String get circonstancesPrecision => _circonstancesPrecision;
  String get description => _description;
  String get partieCorps => _partieCorps;
  String get partieCorpsPrecision => _partieCorpsPrecision;
  String get typeBlessure => _typeBlessure;
  String get typeBlessurePrecision => _typeBlessurePrecision;
  String get gravite => _gravite;
  List<String> get premiersSoins => List.unmodifiable(_premiersSoins);
  String get observations => _observations;
  List<Map<String, dynamic>> get suiviReeducation =>
      List.unmodifiable(_suiviReeducation);
  List<Map<String, dynamic>> get retourProgressif =>
      List.unmodifiable(_retourProgressif);
  bool get validationRepriseEntrainement => _validationRepriseEntrainement;
  bool get validationRepriseCompetition => _validationRepriseCompetition;
  bool get validationRepriseSurveillance => _validationRepriseSurveillance;
  String get validationRepriseRecommandation => _validationRepriseRecommandation;
  DateTime? get validationFinaleDate => _validationFinaleDate;
  String get responsableMedical => _responsableMedical;
  String get signatureUrl => _signatureUrl;
  File? get signatureFile => _signatureFile;
  String get statutReprise => _statutReprise;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get hasError => _error != null;

  // ------------------------------------------------------------------
  // Setters
  // ------------------------------------------------------------------
  void setDateBlessure(DateTime value) {
    _dateBlessure = value;
    notifyListeners();
  }

  void setHeureBlessure(String value) {
    _heureBlessure = value;
    notifyListeners();
  }

  void setLieu(String value) {
    _lieu = value;
    notifyListeners();
  }

  void setLieuPrecision(String value) {
    _lieuPrecision = value;
    notifyListeners();
  }

  void setAdversaire(String value) {
    _adversaire = value;
    notifyListeners();
  }

  void setCirconstancesType(String value) {
    _circonstancesType = value;
    notifyListeners();
  }

  void setCirconstancesTypePrecision(String value) {
    _circonstancesTypePrecision = value;
    notifyListeners();
  }

  void setCirconstancesPrecision(String value) {
    _circonstancesPrecision = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setPartieCorps(String value) {
    _partieCorps = value;
    notifyListeners();
  }

  void setPartieCorpsPrecision(String value) {
    _partieCorpsPrecision = value;
    notifyListeners();
  }

  void setTypeBlessure(String value) {
    _typeBlessure = value;
    notifyListeners();
  }

  void setTypeBlessurePrecision(String value) {
    _typeBlessurePrecision = value;
    notifyListeners();
  }

  void setGravite(String value) {
    _gravite = value;
    notifyListeners();
  }

  void setObservations(String value) {
    _observations = value;
    notifyListeners();
  }

  void setValidationRepriseEntrainement(bool value) {
    _validationRepriseEntrainement = value;
    notifyListeners();
  }

  void setValidationRepriseCompetition(bool value) {
    _validationRepriseCompetition = value;
    notifyListeners();
  }

  void setValidationRepriseSurveillance(bool value) {
    _validationRepriseSurveillance = value;
    notifyListeners();
  }

  void setValidationRepriseRecommandation(String value) {
    _validationRepriseRecommandation = value;
    notifyListeners();
  }

  void setValidationFinaleDate(DateTime? value) {
    _validationFinaleDate = value;
    notifyListeners();
  }

  void setResponsableMedical(String value) {
    _responsableMedical = value;
    notifyListeners();
  }

  void setStatutReprise(String value) {
    _statutReprise = value;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Premiers soins
  // ------------------------------------------------------------------
  void addPremiersSoins(String soin) {
    if (soin.trim().isNotEmpty) {
      _premiersSoins.add(soin.trim());
      notifyListeners();
    }
  }

  void removePremiersSoins(int index) {
    if (index >= 0 && index < _premiersSoins.length) {
      _premiersSoins.removeAt(index);
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // Suivi reeducation
  // ------------------------------------------------------------------
  void addSuiviReeducation({
    DateTime? date,
    String travaux = '',
    int douleur = 5,
    String observations = '',
  }) {
    _suiviReeducation.add({
      'id': 'sr_${DateTime.now().millisecondsSinceEpoch}_${_suiviReeducation.length}',
      'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'travaux': travaux,
      'douleur': douleur,
      'observations': observations,
    });
    notifyListeners();
  }

  void updateSuiviReeducation(int index, Map<String, dynamic> data) {
    if (index >= 0 && index < _suiviReeducation.length) {
      _suiviReeducation[index] = data;
      notifyListeners();
    }
  }

  void removeSuiviReeducation(int index) {
    if (index >= 0 && index < _suiviReeducation.length) {
      _suiviReeducation.removeAt(index);
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // Retour progressif
  // ------------------------------------------------------------------
  void addRetourProgressif({
    DateTime? date,
    String activite = '',
    String validation = '',
  }) {
    _retourProgressif.add({
      'id': 'rp_${DateTime.now().millisecondsSinceEpoch}_${_retourProgressif.length}',
      'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'activite': activite,
      'validation': validation,
    });
    notifyListeners();
  }

  void updateRetourProgressif(int index, Map<String, dynamic> data) {
    if (index >= 0 && index < _retourProgressif.length) {
      _retourProgressif[index] = data;
      notifyListeners();
    }
  }

  void removeRetourProgressif(int index) {
    if (index >= 0 && index < _retourProgressif.length) {
      _retourProgressif.removeAt(index);
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // Signature
  // ------------------------------------------------------------------
  void setSignatureFile(File? file) {
    _signatureFile = file;
    notifyListeners();
  }

  void setSignatureUrl(String url) {
    _signatureUrl = url;
    notifyListeners();
  }

  Future<bool> uploadSignature() async {
    final file = _signatureFile;
    if (file == null) return false;

    final result = await _uploadService.uploadImage(file, UploadType.signatureMedical);
    if (result.success && result.url != null) {
      _signatureUrl = result.url!;
      _signatureFile = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  // ------------------------------------------------------------------
  // Chargement depuis un dossier existant (mode edition)
  // ------------------------------------------------------------------
  void loadFromDossier(DossierMedical dossier) {
    _dateBlessure = dossier.dateBlessure;
    _heureBlessure = dossier.heureBlessure ?? '';
    _lieu = dossier.lieu;
    _lieuPrecision = dossier.circonstances?['lieu_precision']?.toString() ?? '';
    _adversaire = dossier.adversaire ?? '';

    final circonstances = dossier.circonstances;
    if (circonstances != null) {
      _circonstancesType = circonstances['type']?.toString() ?? '';
      _circonstancesTypePrecision =
          circonstances['type_precision']?.toString() ?? '';
      _circonstancesPrecision = circonstances['precision']?.toString() ?? '';
      _partieCorpsPrecision =
          circonstances['partie_corps_precision']?.toString() ?? '';
      _typeBlessurePrecision =
          circonstances['type_blessure_precision']?.toString() ?? '';
    } else {
      _circonstancesType = '';
      _circonstancesTypePrecision = '';
      _circonstancesPrecision = '';
      _partieCorpsPrecision = '';
      _typeBlessurePrecision = '';
    }

    _description = dossier.description ?? '';
    _partieCorps = dossier.partieCorps ?? '';
    _typeBlessure = dossier.typeBlessure ?? '';
    _gravite = dossier.gravite ?? '';

    _premiersSoins.clear();
    if (dossier.premiersSoins != null) {
      _premiersSoins.addAll(dossier.premiersSoins!);
    }

    _observations = dossier.observations ?? '';

    _suiviReeducation.clear();
    if (dossier.suiviReeducation != null) {
      _suiviReeducation.addAll(dossier.suiviReeducation!);
    }

    _retourProgressif.clear();
    if (dossier.retourProgressif != null) {
      _retourProgressif.addAll(dossier.retourProgressif!);
    }

    final validationReprise = dossier.validationReprise;
    if (validationReprise != null) {
      _validationRepriseEntrainement =
          validationReprise['entrainement'] == true;
      _validationRepriseCompetition = validationReprise['competition'] == true;
      _validationRepriseSurveillance =
          validationReprise['surveillance'] == true;
      _validationRepriseRecommandation =
          validationReprise['recommandation']?.toString() ?? '';
    } else {
      _validationRepriseEntrainement = false;
      _validationRepriseCompetition = false;
      _validationRepriseSurveillance = false;
      _validationRepriseRecommandation = '';
    }

    _validationFinaleDate = dossier.validationFinaleDate;
    _responsableMedical = dossier.responsableMedical ?? '';
    _signatureUrl = dossier.signatureUrl;
    _statutReprise = dossier.statutReprise;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Validation
  // ------------------------------------------------------------------
  String _t(String fallback, String localized) => localized.isNotEmpty ? localized : fallback;

  bool validate() {
    final l10n = _l10n;

    // Date de blessure obligatoire et non dans le futur
    if (_dateBlessure.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      _error = _t(
        'La date de blessure ne peut pas etre dans le futur.',
        l10n?.medicalRecordErrorInjuryDateFuture ?? '',
      );
      notifyListeners();
      return false;
    }

    // Heure au format HH:mm si renseignee
    if (_heureBlessure.isNotEmpty) {
      final timeRegex = RegExp(r'^(0[0-9]|1[0-9]|2[0-3]):([0-5][0-9])$');
      if (!timeRegex.hasMatch(_heureBlessure)) {
        _error = _t(
          'L\'heure de blessure doit etre au format HH:mm.',
          l10n?.medicalRecordErrorInjuryTimeFormat ?? '',
        );
        notifyListeners();
        return false;
      }
    }

    // Champs "Autre" obligatoirement precises
    if (_lieu == 'autre' && _lieuPrecision.trim().isEmpty) {
      _error = _t(
        'Veuillez preciser le lieu.',
        l10n?.medicalRecordErrorLocationRequired ?? '',
      );
      notifyListeners();
      return false;
    }
    if (_circonstancesType == 'autre' && _circonstancesTypePrecision.trim().isEmpty) {
      _error = _t(
        'Veuillez preciser le type de circonstance.',
        l10n?.medicalRecordErrorCircumstanceTypeRequired ?? '',
      );
      notifyListeners();
      return false;
    }
    if (_partieCorps == 'autre' && _partieCorpsPrecision.trim().isEmpty) {
      _error = _t(
        'Veuillez preciser la partie du corps touchee.',
        l10n?.medicalRecordErrorBodyPartRequired ?? '',
      );
      notifyListeners();
      return false;
    }
    if (_typeBlessure == 'autre' && _typeBlessurePrecision.trim().isEmpty) {
      _error = _t(
        'Veuillez preciser le type de blessure.',
        l10n?.medicalRecordErrorInjuryTypeRequired ?? '',
      );
      notifyListeners();
      return false;
    }

    // Validation finale : date non dans le futur si renseignee
    if (_validationFinaleDate != null &&
        _validationFinaleDate!.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      _error = _t(
        'La date de validation finale ne peut pas etre dans le futur.',
        l10n?.medicalRecordErrorFinalValidationDateFuture ?? '',
      );
      notifyListeners();
      return false;
    }

    // Signature obligatoire
    if (_signatureUrl.isEmpty) {
      _error = _t(
        'La signature du responsable medical est obligatoire.',
        l10n?.medicalRecordErrorSignatureRequired ?? '',
      );
      notifyListeners();
      return false;
    }

    _error = null;
    notifyListeners();
    return true;
  }

  /// Deduit le statut de reprise en fonction des validations saisies.
  /// - Validation finale complete => 'fini'
  /// - Apte competition => 'apte_competition'
  /// - Apte entrainement => 'apte_entrainement'
  /// - Sinon => 'en_cours'
  String _deduceStatutReprise() {
    final validationFinaleComplete = _validationFinaleDate != null &&
        _responsableMedical.trim().isNotEmpty &&
        _signatureUrl.isNotEmpty;
    if (validationFinaleComplete) return 'fini';
    if (_validationRepriseCompetition) return 'apte_competition';
    if (_validationRepriseEntrainement) return 'apte_entrainement';
    return 'en_cours';
  }

  // ------------------------------------------------------------------
  // Sauvegarde
  // ------------------------------------------------------------------
  Future<bool> save(String academicienId, {DossierMedical? existing}) async {
    if (!validate()) return false;

    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final circonstances = <String, dynamic>{};
      if (_circonstancesType.isNotEmpty) {
        circonstances['type'] = _circonstancesType;
      }
      if (_circonstancesType == 'autre' &&
          _circonstancesTypePrecision.isNotEmpty) {
        circonstances['type_precision'] = _circonstancesTypePrecision;
      }
      if (_circonstancesPrecision.isNotEmpty) {
        circonstances['precision'] = _circonstancesPrecision;
      }
      if (_lieu == 'autre' && _lieuPrecision.isNotEmpty) {
        circonstances['lieu_precision'] = _lieuPrecision;
      }
      if (_partieCorps == 'autre' && _partieCorpsPrecision.isNotEmpty) {
        circonstances['partie_corps_precision'] = _partieCorpsPrecision;
      }
      if (_typeBlessure == 'autre' && _typeBlessurePrecision.isNotEmpty) {
        circonstances['type_blessure_precision'] = _typeBlessurePrecision;
      }

      final validationReprise = <String, dynamic>{};
      validationReprise['entrainement'] = _validationRepriseEntrainement;
      validationReprise['competition'] = _validationRepriseCompetition;
      validationReprise['surveillance'] = _validationRepriseSurveillance;
      if (_validationRepriseRecommandation.isNotEmpty) {
        validationReprise['recommandation'] = _validationRepriseRecommandation;
      }

      final statutReprise = _deduceStatutReprise();

      final dossier = DossierMedical(
        id: existing?.id ?? 'dm_${DateTime.now().millisecondsSinceEpoch}',
        academicienId: academicienId,
        dateBlessure: _dateBlessure,
        heureBlessure: _heureBlessure.isNotEmpty ? _heureBlessure : null,
        lieu: _lieu,
        adversaire: _adversaire.isNotEmpty ? _adversaire : null,
        circonstances: circonstances.isNotEmpty ? circonstances : null,
        description: _description.isNotEmpty ? _description : null,
        partieCorps: _partieCorps.isNotEmpty ? _partieCorps : null,
        typeBlessure: _typeBlessure.isNotEmpty ? _typeBlessure : null,
        gravite: _gravite.isNotEmpty ? _gravite : null,
        premiersSoins: _premiersSoins.isNotEmpty ? _premiersSoins : null,
        observations: _observations.isNotEmpty ? _observations : null,
        suiviReeducation:
            _suiviReeducation.isNotEmpty ? _suiviReeducation : null,
        retourProgressif:
            _retourProgressif.isNotEmpty ? _retourProgressif : null,
        validationReprise:
            validationReprise.isNotEmpty ? validationReprise : null,
        validationFinaleDate: _validationFinaleDate,
        responsableMedical:
            _responsableMedical.isNotEmpty ? _responsableMedical : null,
        signatureUrl: _signatureUrl,
        statutReprise: statutReprise,
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (existing != null) {
        await _repository.update(dossier);
      } else {
        await _repository.create(dossier);
      }

      // Si connecte, attend le resultat de la synchronisation pour verifier
      // que la requete API a bien reussi avant de fermer le formulaire.
      if (await _syncService?.isConnected() ?? false) {
        final result = await _syncService?.syncPendingOperationsAndWait();
        final medicalErrors = result?.errors
                .where((err) => err.contains(SyncEntityType.dossierMedical.name))
                .toList() ??
            [];
        if (medicalErrors.isNotEmpty) {
          _error = medicalErrors.join('\n');
          _successMessage = null;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _successMessage = existing != null
          ? _t(
              'Dossier medical mis a jour avec succes.',
              _l10n?.medicalRecordSuccessUpdated ?? '',
            )
          : _t(
              'Dossier medical cree avec succes.',
              _l10n?.medicalRecordSuccessCreated ?? '',
            );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _t(
        'Erreur lors de l\'enregistrement : $e',
        _l10n?.medicalRecordErrorSave(e.toString()) ?? '',
      );
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ------------------------------------------------------------------
  // Reinitialisation
  // ------------------------------------------------------------------
  void reset() {
    _dateBlessure = DateTime.now();
    _heureBlessure = '';
    _lieu = 'entrainement';
    _lieuPrecision = '';
    _adversaire = '';
    _circonstancesType = '';
    _circonstancesTypePrecision = '';
    _circonstancesPrecision = '';
    _description = '';
    _partieCorps = '';
    _partieCorpsPrecision = '';
    _typeBlessure = '';
    _typeBlessurePrecision = '';
    _gravite = '';
    _premiersSoins.clear();
    _observations = '';
    _suiviReeducation.clear();
    _retourProgressif.clear();
    _validationRepriseEntrainement = false;
    _validationRepriseCompetition = false;
    _validationRepriseSurveillance = false;
    _validationRepriseRecommandation = '';
    _validationFinaleDate = null;
    _responsableMedical = '';
    _signatureUrl = '';
    _signatureFile = null;
    _statutReprise = 'en_cours';
    _isLoading = false;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
