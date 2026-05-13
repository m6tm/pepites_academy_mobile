import 'package:flutter/material.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../core/events/seance_events.dart';
import '../../application/services/seance_service.dart';
import '../../domain/entities/seance.dart';
import '../../injection_container.dart';

enum SeanceFilter { toutes, enCours, terminees, aVenir }

class SeanceState extends ChangeNotifier with EventBusSubscriberMixin {
  final SeanceService _service;

  SeanceState(this._service, DomainEventBus eventBus) {
    _listenToConflict(eventBus);
    listenTo<SeanceStatsChangedEvent>(eventBus, (e) {
      DependencyInjection.seanceRepository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<SeanceClosedEvent>(eventBus, (e) {
      DependencyInjection.seanceRepository.invalidateSeanceEncoursCache();
      chargerSeances();
    });
    listenTo<PresenceRecordedEvent>(eventBus, (e) {
      DependencyInjection.seanceRepository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<AtelierCreatedEvent>(eventBus, (e) {
      DependencyInjection.seanceRepository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<AtelierDeletedEvent>(eventBus, (e) {
      DependencyInjection.seanceRepository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
    listenTo<AnnotationCreatedEvent>(eventBus, (e) {
      DependencyInjection.seanceRepository.invalidateSeanceEncoursCache();
      _refreshStatsSilently();
    });
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _seances = await _service.getAllSeances();
      _seanceOuverte = await _service.getSeanceOuverte();
      DependencyInjection.seanceRepository.invalidateSeanceEncoursCache();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des seances : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isRefreshingStats = false;

  Future<void> _refreshStatsSilently() async {
    if (_isRefreshingStats) return;
    _isRefreshingStats = true;
    try {
      await DependencyInjection.seanceRepository.getSeanceEncoursWithStats();
    } finally {
      _isRefreshingStats = false;
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
