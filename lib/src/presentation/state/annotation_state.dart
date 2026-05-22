import 'package:flutter/material.dart';
import '../../application/services/annotation_service.dart';
import '../../core/events/annotation_events.dart';
import '../../core/events/app_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../domain/entities/annotation.dart';

class AnnotationState extends ChangeNotifier with EventBusSubscriberMixin {
  final AnnotationService _service;
  final DomainEventBus _eventBus;
  bool _isDisposed = false;

  DateTime? _lastFetchedAt;
  bool _isFetching = false;

  AnnotationState(this._service, this._eventBus) {
    listenTo<AnnotationCreatedEvent>(_eventBus, (e) => _onAnnotationChanged(e.atelierId));
    listenTo<AnnotationUpdatedEvent>(_eventBus, (e) => _onAnnotationChanged(e.atelierId));
    listenTo<AnnotationDeletedEvent>(_eventBus, (e) => _onAnnotationChanged(e.atelierId));
    listenTo<AppResumedEvent>(_eventBus, (_) => _onRefreshIfStale());
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

  List<Annotation> _annotationsAtelier = [];
  List<Annotation> get annotationsAtelier => _annotationsAtelier;

  List<Annotation> _historiqueAcademicien = [];
  List<Annotation> get historiqueAcademicien => _historiqueAcademicien;

  String? _atelierId;
  String? get atelierId => _atelierId;

  String? _seanceId;
  String? get seanceId => _seanceId;

  String? _exerciceId;
  String? get exerciceId => _exerciceId;

  String? _academicienSelectionneId;
  String? get academicienSelectionneId => _academicienSelectionneId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  void _onAnnotationChanged(String atelierId) {
    if (_atelierId == atelierId) {
      chargerAnnotationsAtelier();
    }
  }

  void _onRefreshIfStale() {
    if (_isFetching) return;
    final last = _lastFetchedAt;
    if (last == null) return;
    final age = DateTime.now().difference(last);
    if (age > const Duration(minutes: 2)) {
      chargerAnnotationsAtelier();
    }
  }

  Future<void> initialiserContexte({
    required String atelierId,
    required String seanceId,
    String? exerciceId,
  }) async {
    _atelierId = atelierId;
    _seanceId = seanceId;
    _exerciceId = exerciceId;
    _academicienSelectionneId = null;
    _historiqueAcademicien = [];
    await chargerAnnotationsAtelier(forceRefresh: true);
  }

  Future<void> chargerAnnotationsAtelier({bool forceRefresh = false}) async {
    if (_atelierId == null) return;
    if (_isFetching) return;

    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _annotationsAtelier = await _service.getAnnotationsAtelier(
        _atelierId!,
        forceRefresh: forceRefresh,
      );
      _lastFetchedAt = DateTime.now();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des annotations : $e';
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectionnerAcademicien(String academicienId) async {
    _academicienSelectionneId = academicienId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historiqueAcademicien = await _service.getAnnotationsAcademicien(
        academicienId,
      );
      if (_exerciceId != null) {
        _historiqueAcademicien.sort((a, b) {
          if (a.exerciceId == _exerciceId && b.exerciceId != _exerciceId) {
            return -1;
          }
          if (a.exerciceId != _exerciceId && b.exerciceId == _exerciceId) {
            return 1;
          }
          return b.horodate.compareTo(a.horodate);
        });
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement de l\'historique : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void deselectionnerAcademicien() {
    _academicienSelectionneId = null;
    _historiqueAcademicien = [];
    notifyListeners();
  }

  Future<bool> creerAnnotation({
    required List<ScoreAnnotation> scores,
    String? commentaire,
    required String encadreurId,
  }) async {
    if (_academicienSelectionneId == null ||
        _atelierId == null ||
        _seanceId == null) {
      _errorMessage = 'Contexte incomplet pour creer une annotation.';
      notifyListeners();
      return false;
    }

    for (final score in scores) {
      if (score.noteElement1 == 0 || score.noteElement2 == 0) {
        _errorMessage = 'Tous les elements doivent etre notes (pas de 0).';
        notifyListeners();
        return false;
      }
    }

    if (_exerciceId != null) {
      final dejaAnnote = _historiqueAcademicien.any(
        (a) => a.exerciceId == _exerciceId,
      );
      if (dejaAnnote) {
        _errorMessage =
            'Cet exercice a deja ete annote. Vous ne pouvez pas creer deux annotations pour le meme exercice.';
        notifyListeners();
        return false;
      }
    }

    _errorMessage = null;
    _successMessage = null;

    try {
      final annotation = await _service.creerAnnotation(
        scores: scores,
        commentaire: commentaire,
        academicienId: _academicienSelectionneId!,
        atelierId: _atelierId!,
        exerciceId: _exerciceId,
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

  Annotation? get annotationPourExerciceActuel {
    if (_academicienSelectionneId == null || _atelierId == null) return null;
    try {
      return _historiqueAcademicien.firstWhere(
        (a) =>
            a.atelierId == _atelierId &&
            a.academicienId == _academicienSelectionneId &&
            (_exerciceId == null || a.exerciceId == _exerciceId),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> modifierAnnotation({
    required String annotationId,
    required List<ScoreAnnotation> scores,
    String? commentaire,
  }) async {
    for (final score in scores) {
      if (score.noteElement1 == 0 || score.noteElement2 == 0) {
        _errorMessage = 'Tous les elements doivent etre notes (pas de 0).';
        notifyListeners();
        return false;
      }
    }

    _errorMessage = null;
    _successMessage = null;

    try {
      final existing = _historiqueAcademicien.firstWhere(
        (a) => a.id == annotationId,
      );
      final updated = existing.copyWith(scores: scores, commentaire: commentaire);

      await _service.modifierAnnotation(updated);

      _annotationsAtelier = _annotationsAtelier
          .map((a) => a.id == annotationId ? updated : a)
          .toList();
      _historiqueAcademicien = _historiqueAcademicien
          .map((a) => a.id == annotationId ? updated : a)
          .toList();
      _successMessage = 'Annotation mise a jour.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise a jour : $e';
      notifyListeners();
      return false;
    }
  }

  List<Annotation> annotationsPourAcademicien(String academicienId) {
    return _annotationsAtelier
        .where((a) => a.academicienId == academicienId)
        .toList();
  }

  int nbAnnotationsPourAcademicien(String academicienId) {
    return _annotationsAtelier
        .where((a) => a.academicienId == academicienId)
        .length;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
