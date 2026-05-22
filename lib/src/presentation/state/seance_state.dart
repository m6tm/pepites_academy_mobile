import 'package:flutter/material.dart';
import '../../core/events/annotation_events.dart';
import '../../core/events/app_events.dart';
import '../../core/events/atelier_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../core/events/seance_events.dart';
import '../../application/services/seance_service.dart';
import '../../domain/repositories/seance_repository.dart';
import '../../domain/entities/seance.dart';


enum SeanceFilter { toutes, enCours, terminees, aVenir }

class SeanceState extends ChangeNotifier with EventBusSubscriberMixin {
  final SeanceService _service;
  final SeanceRepository _repository;

  SeanceState(this._service, this._repository, DomainEventBus eventBus) {
    _listenToConflict(eventBus);
    listenTo<SeanceCreatedEvent>(eventBus, (_) => chargerSeances());
    listenTo<SeanceUpdatedEvent>(eventBus, (_) => chargerSeances());
    listenTo<AtelierAppliedEvent>(eventBus, (_) {
      _repository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<AtelierClosedEvent>(eventBus, (_) {
      _repository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<SeanceStatsChangedEvent>(eventBus, (e) {
      _repository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<SeanceClosedEvent>(eventBus, (e) {
      _repository.invalidateSeanceEncoursCache();
      chargerSeances();
    });
    listenTo<PresenceRecordedEvent>(eventBus, (e) {
      _repository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<AtelierCreeEvent>(eventBus, (e) {
      _repository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<AtelierDeletedEvent>(eventBus, (e) {
      _repository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<AnnotationCreatedEvent>(eventBus, (e) {
      _repository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<AppResumedEvent>(eventBus, (_) => _onAppResumed());
  }

  String? _pendingConflictMessage;

  void _listenToConflict(DomainEventBus eventBus) {
    listenTo<SeanceConflictEvent>(
      eventBus,
      (event) async {
        await chargerSeances();
        _pendingConflictMessage =
            'Impossible de créer la séance. Une autre séance est déjà ouverte.';
        notifyListeners();
      },
    );
  }

  List<Seance> _seances = [];
  List<Seance> get seances => _seancesFiltrees;

  Seance? _seanceOuverte;
  Seance? get seanceOuverte => _seanceOuverte;

  SeanceFilter _filtre = SeanceFilter.toutes;
  SeanceFilter get filtre => _filtre;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage {
    if (_pendingConflictMessage != null) {
      final msg = _pendingConflictMessage;
      _pendingConflictMessage = null;
      return msg;
    }
    return _errorMessage;
  }

  String? _successMessage;
  String? get successMessage => _successMessage;

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

  Future<void> chargerSeances() async {
    if (_isFetching) return;
    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _seances = await _service.getAllSeances();
      _seanceOuverte = await _service.getSeanceOuverte();
      _repository.invalidateSeanceEncoursCache();
      _lastFetchedAt = DateTime.now();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des seances : $e';
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isRefreshingStats = false;

  Future<void> _refreshStatsSilently() async {
    if (_isRefreshingStats) return;
    _isRefreshingStats = true;
    try {
      await _repository.getSeanceEncoursWithStats();
    } finally {
      _isRefreshingStats = false;
    }
  }

  bool _isFetching = false;
  DateTime? _lastFetchedAt;

  Future<void> _onAppResumed() async {
    if (_isFetching) return;
    if (_lastFetchedAt == null) return;
    final age = DateTime.now().difference(_lastFetchedAt!);
    if (age > const Duration(minutes: 2)) {
      await chargerSeances();
    }
  }

  void setFiltre(SeanceFilter filtre) {
    _filtre = filtre;
    notifyListeners();
  }

  Future<OuvertureResult> ouvrirSeance({
    required String titre,
    required DateTime date,
    required DateTime heureDebut,
    required DateTime heureFin,
    required String encadreurResponsableId,
    List<String> encadreurInvitesIds = const [],
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
        encadreurInvitesIds: encadreurInvitesIds,
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

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
