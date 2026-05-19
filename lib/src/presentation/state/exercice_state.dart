import 'package:flutter/material.dart';
import '../../application/services/exercice_service.dart';
import '../../core/events/app_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../core/events/exercice_events.dart';
import '../../domain/entities/exercice.dart';
import 'message_state_mixin.dart';
import '../../../l10n/app_localizations.dart';

/// State management pour les exercices d'un atelier.
class ExerciceState extends ChangeNotifier
    with MessageStateMixin, EventBusSubscriberMixin {
  final ExerciceService _service;
  final DomainEventBus _eventBus;
  AppLocalizations? _l10n;
  bool _isDisposed = false;

  DateTime? _lastFetchedAt;
  bool _isFetching = false;

  ExerciceState(this._service, this._eventBus) {
    listenTo<ExerciceCreatedEvent>(_eventBus, (e) => _onExerciceChanged(e.atelierId));
    listenTo<ExerciceUpdatedEvent>(_eventBus, (e) => _onExerciceChanged(e.atelierId));
    listenTo<ExerciceDeletedEvent>(_eventBus, (e) => _onExerciceChanged(e.atelierId));
    listenTo<ExerciceReorderedEvent>(_eventBus, (e) => _onExerciceChanged(e.atelierId));
    listenTo<ExerciceClosedEvent>(_eventBus, (e) => _onExerciceChanged(e.atelierId));
    listenTo<AppResumedEvent>(_eventBus, (_) => _onRefreshIfStale());
  }

  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
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

  final Map<String, List<Exercice>> _exercicesParAtelier = {};
  Map<String, List<Exercice>> get exercicesParAtelier => _exercicesParAtelier;

  final Map<String, bool> _loadingStates = {};
  bool isLoading(String atelierId) => _loadingStates[atelierId] ?? false;

  String? _errorMessage;
  @override
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  @override
  String? get successMessage => _successMessage;

  void _onExerciceChanged(String atelierId) {
    if (_exercicesParAtelier.containsKey(atelierId)) {
      chargerExercices(atelierId);
    }
  }

  void _onRefreshIfStale() {
    if (_isFetching) return;
    final last = _lastFetchedAt;
    if (last == null) return;
    final age = DateTime.now().difference(last);
    if (age > const Duration(minutes: 2)) {
      for (final atelierId in _exercicesParAtelier.keys) {
        chargerExercices(atelierId);
      }
    }
  }

  /// Charge les exercices d'un atelier.
  Future<void> chargerExercices(String atelierId) async {
    if (_isFetching) return;
    _isFetching = true;
    _loadingStates[atelierId] = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exercices = await _service.getExercicesParAtelier(atelierId);
      _exercicesParAtelier[atelierId] = exercices;
      _lastFetchedAt = DateTime.now();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des exercices : $e';
    } finally {
      _isFetching = false;
      _loadingStates[atelierId] = false;
      notifyListeners();
    }
  }

  /// Ajoute un exercice.
  Future<bool> ajouterExercice({
    required String atelierId,
    required String nom,
    String description = '',
    ExerciceStatut statut = ExerciceStatut.cree,
  }) async {
    _loadingStates[atelierId] = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.ajouterExercice(
        atelierId: atelierId,
        nom: nom,
        description: description,
        statut: statut,
      );
      _successMessage = 'Exercice "$nom" ajoute avec succes.';
      await chargerExercices(atelierId);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout : $e';
      _loadingStates[atelierId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Modifie un exercice.
  Future<bool> modifierExercice(Exercice exercice) async {
    _loadingStates[exercice.atelierId] = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.modifierExercice(exercice);
      _successMessage = 'Exercice "${exercice.nom}" modifie avec succes.';
      await chargerExercices(exercice.atelierId);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification : $e';
      _loadingStates[exercice.atelierId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Applique un exercice en seance.
  Future<bool> appliquerExercice(String exerciceId, String atelierId) async {
    _loadingStates[atelierId] = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.appliquerExercice(exerciceId);
      _successMessage = _l10n?.serviceExerciceAppliedSuccess ?? 'Exercice applique avec succes en seance.';
      await chargerExercices(atelierId);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'application : $e';
      _loadingStates[atelierId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Ferme un exercice (statut 'ferme').
  Future<bool> fermerExercice(String exerciceId, String atelierId, String nom) async {
    _loadingStates[atelierId] = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final isAtelierClosed = await _service.fermerExercice(exerciceId);
      _successMessage = _l10n?.serviceExerciceClosedSuccess(nom) ?? 'Exercice "$nom" ferme avec succes.';
      if (isAtelierClosed) {
        _successMessage = '${_successMessage!}\n${_l10n?.serviceAtelierClosedAuto ?? "L'atelier a ete ferme automatiquement."}';
      }
      await chargerExercices(atelierId);
      return isAtelierClosed;
    } catch (e) {
      _errorMessage = 'Erreur lors de la fermeture : $e';
      _loadingStates[atelierId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Supprime un exercice.
  Future<bool> supprimerExercice(String exerciceId, String atelierId) async {
    _loadingStates[atelierId] = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.supprimerExercice(exerciceId);
      _successMessage = 'Exercice supprime avec succes.';
      await chargerExercices(atelierId);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      _loadingStates[atelierId] = false;
      notifyListeners();
      return false;
    }
  }

  /// Reordonne les exercices.
  Future<void> reordonnerExercices(String atelierId, int oldIndex, int newIndex) async {
    final list = _exercicesParAtelier[atelierId];
    if (list == null) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    if (oldIndex == newIndex) return;

    final exercice = list.removeAt(oldIndex);
    list.insert(newIndex, exercice);
    notifyListeners();

    try {
      final ids = list.map((e) => e.id).toList();
      await _service.reorderExercices(atelierId, ids);
      await chargerExercices(atelierId);
    } catch (e) {
      _errorMessage = 'Erreur lors de la reorganisation : $e';
      notifyListeners();
    }
  }

  @override
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
