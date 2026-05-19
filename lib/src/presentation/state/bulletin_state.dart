import 'package:flutter/material.dart';
import '../../application/services/bulletin_service.dart';
import '../../core/events/app_events.dart';
import '../../core/events/bulletin_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../domain/entities/bulletin.dart';
import '../../injection_container.dart';

/// State management pour les bulletins de formation.
class BulletinState extends ChangeNotifier with EventBusSubscriberMixin {
  final BulletinService _service;
  final DomainEventBus _eventBus;

  BulletinState(this._service, this._eventBus) {
    listenTo<BulletinCreatedEvent>(_eventBus, (e) => _onBulletinChanged(e.academicienId));
    listenTo<BulletinDeletedEvent>(_eventBus, (e) => _onBulletinChanged(e.academicienId));
    listenTo<AppResumedEvent>(_eventBus, (_) => _onRefreshIfStale());
  }

  List<Bulletin> _bulletins = [];
  List<Bulletin> get bulletins => _bulletins;

  Bulletin? _bulletinCourant;
  Bulletin? get bulletinCourant => _bulletinCourant;

  PeriodeType _typePeriode = PeriodeType.mois;
  PeriodeType get typePeriode => _typePeriode;

  DateTime _dateReference = DateTime.now();
  DateTime get dateReference => _dateReference;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _currentAcademicienId;
  DateTime? _lastFetchedAt;
  bool _isFetching = false;

  void _onBulletinChanged(String academicienId) {
    if (_currentAcademicienId == academicienId) {
      chargerBulletins(academicienId);
    }
  }

  void _onRefreshIfStale() {
    if (_isFetching) return;
    final last = _lastFetchedAt;
    final academicienId = _currentAcademicienId;
    if (last == null || academicienId == null) return;
    final age = DateTime.now().difference(last);
    if (age > const Duration(minutes: 2)) {
      chargerBulletins(academicienId);
    }
  }

  /// Change le type de periode selectionne.
  void changerTypePeriode(PeriodeType type) {
    _typePeriode = type;
    notifyListeners();
  }

  /// Change la date de reference pour la periode.
  void changerDateReference(DateTime date) {
    _dateReference = date;
    notifyListeners();
  }

  /// Charge les bulletins d'un academicien.
  Future<void> chargerBulletins(String academicienId) async {
    if (_isFetching) return;
    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    _currentAcademicienId = academicienId;
    notifyListeners();

    try {
      await DependencyInjection.syncBulletins();
      await DependencyInjection.syncAnnotations();
      await DependencyInjection.syncSeances();
      await DependencyInjection.syncPresences();

      _bulletins = await _service.getBulletinsAcademicien(academicienId);
      _lastFetchedAt = DateTime.now();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des bulletins : $e';
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Genere un nouveau bulletin pour un academicien.
  Future<bool> genererBulletin({
    required String academicienId,
    required String encadreurId,
    String observationsGenerales = '',
  }) async {
    _isGenerating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final dates = BulletinService.calculerDatesPeriode(
        _typePeriode,
        reference: _dateReference,
      );

      final bulletin = await _service.genererBulletin(
        academicienId: academicienId,
        encadreurId: encadreurId,
        typePeriode: _typePeriode,
        dateDebut: dates.debut,
        dateFin: dates.fin,
        observationsGenerales: observationsGenerales,
      );

      _bulletinCourant = bulletin;
      _bulletins.insert(0, bulletin);
      _successMessage = 'Bulletin genere avec succes.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la generation : $e';
      notifyListeners();
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Selectionne un bulletin pour la previsualisation.
  void selectionnerBulletin(Bulletin bulletin) {
    _bulletinCourant = bulletin;
    notifyListeners();
  }

  /// Met a jour les observations generales du bulletin courant.
  Future<bool> mettreAJourObservations(String observations) async {
    if (_bulletinCourant == null) return false;

    try {
      final updated = await _service.mettreAJourObservations(
        _bulletinCourant!.id,
        observations,
      );
      _bulletinCourant = updated;

      final index = _bulletins.indexWhere((b) => b.id == updated.id);
      if (index != -1) _bulletins[index] = updated;

      _successMessage = 'Observations mises a jour.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise a jour : $e';
      notifyListeners();
      return false;
    }
  }

  /// Supprime un bulletin.
  Future<bool> supprimerBulletin(String id) async {
    try {
      await _service.supprimerBulletin(id);
      _bulletins.removeWhere((b) => b.id == id);
      if (_bulletinCourant?.id == id) _bulletinCourant = null;
      _successMessage = 'Bulletin supprime.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      notifyListeners();
      return false;
    }
  }

  /// Recupere le bulletin de la periode precedente pour comparaison.
  Bulletin? getBulletinPrecedent(Bulletin bulletin) {
    final index = _bulletins.indexWhere((b) => b.id == bulletin.id);
    if (index == -1 || index >= _bulletins.length - 1) return null;
    return _bulletins[index + 1];
  }

  /// Efface les messages de succes/erreur.
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
