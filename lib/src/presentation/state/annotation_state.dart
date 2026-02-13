import 'package:flutter/material.dart';
import '../../application/services/annotation_service.dart';
import '../../domain/entities/annotation.dart';

/// State management pour les annotations d'un atelier.
/// Gere le chargement, la creation et l'affichage des annotations
/// par academicien dans le contexte d'un atelier.
class AnnotationState extends ChangeNotifier {
  final AnnotationService _service;

  AnnotationState(this._service);

  List<Annotation> _annotationsAtelier = [];
  List<Annotation> get annotationsAtelier => _annotationsAtelier;

  List<Annotation> _historiqueAcademicien = [];
  List<Annotation> get historiqueAcademicien => _historiqueAcademicien;

  String? _atelierId;
  String? get atelierId => _atelierId;

  String? _seanceId;
  String? get seanceId => _seanceId;

  String? _academicienSelectionneId;
  String? get academicienSelectionneId => _academicienSelectionneId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  /// Initialise le contexte de l'atelier pour les annotations.
  Future<void> initialiserContexte({
    required String atelierId,
    required String seanceId,
  }) async {
    _atelierId = atelierId;
    _seanceId = seanceId;
    await chargerAnnotationsAtelier();
  }

  /// Charge toutes les annotations de l'atelier courant.
  Future<void> chargerAnnotationsAtelier() async {
    if (_atelierId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _annotationsAtelier = await _service.getAnnotationsAtelier(_atelierId!);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des annotations : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selectionne un academicien et charge son historique.
  Future<void> selectionnerAcademicien(String academicienId) async {
    _academicienSelectionneId = academicienId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historiqueAcademicien = await _service.getAnnotationsAcademicien(
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
    notifyListeners();
  }

  /// Cree une annotation pour l'academicien selectionne.
  Future<bool> creerAnnotation({
    required String contenu,
    required List<String> tags,
    double? note,
    required String encadreurId,
  }) async {
    if (_academicienSelectionneId == null ||
        _atelierId == null ||
        _seanceId == null) {
      _errorMessage = 'Contexte incomplet pour creer une annotation.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    _successMessage = null;

    try {
      final annotation = await _service.creerAnnotation(
        contenu: contenu,
        tags: tags,
        note: note,
        academicienId: _academicienSelectionneId!,
        atelierId: _atelierId!,
        seanceId: _seanceId!,
        encadreurId: encadreurId,
      );

      _annotationsAtelier.insert(0, annotation);
      _historiqueAcademicien.insert(0, annotation);
      _successMessage = 'Annotation enregistree.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'enregistrement : $e';
      notifyListeners();
      return false;
    }
  }

  /// Recupere les annotations de l'atelier pour un academicien donne.
  List<Annotation> annotationsPourAcademicien(String academicienId) {
    return _annotationsAtelier
        .where((a) => a.academicienId == academicienId)
        .toList();
  }

  /// Compte le nombre d'annotations pour un academicien dans l'atelier.
  int nbAnnotationsPourAcademicien(String academicienId) {
    return _annotationsAtelier
        .where((a) => a.academicienId == academicienId)
        .length;
  }

  /// Efface les messages de succes/erreur.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
