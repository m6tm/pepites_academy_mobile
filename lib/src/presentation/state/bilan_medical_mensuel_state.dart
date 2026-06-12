import 'package:flutter/foundation.dart';
import '../../core/events/app_events.dart';
import '../../core/events/bilan_medical_mensuel_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../core/events/invalidation_registry.dart';
import '../../domain/entities/bilan_medical_mensuel.dart';
import '../../domain/repositories/bilan_medical_mensuel_repository.dart';

/// Etat de gestion de la liste des bilans medicaux mensuels d'un academicien.
///
/// Ce ChangeNotifier applique la strategie de fraicheur des donnees :
/// - Ecoute les evenements de domaine via [EventBusSubscriberMixin].
/// - Interroge l'[InvalidationRegistry] au chargement initial.
/// - Utilise le repository avec cache et synchronisation.
class BilanMedicalMensuelState extends ChangeNotifier
    with EventBusSubscriberMixin {
  final BilanMedicalMensuelRepository _repository;
  final DomainEventBus _eventBus;
  final InvalidationRegistry _invalidationRegistry;

  List<BilanMedicalMensuel> _bilans = [];
  bool _isLoading = false;
  String? _error;
  String? _currentAcademicienId;
  DateTime? _lastLoadedAt;
  bool _isFetching = false;

  BilanMedicalMensuelState(
    this._repository,
    this._eventBus,
    this._invalidationRegistry,
  ) {
    // Ecoute les mutations pour rafraichir automatiquement
    listenTo<BilanMedicalMensuelCreatedEvent>(_eventBus, (_) => _onBilanChanged());
    listenTo<BilanMedicalMensuelUpdatedEvent>(_eventBus, (_) => _onBilanChanged());
    listenTo<BilanMedicalMensuelDeletedEvent>(_eventBus, (_) => _onBilanChanged());
    // Ecoute le retour au foreground pour rafraichir si les donnees sont perimees
    listenTo<AppResumedEvent>(_eventBus, (_) {
      if (_currentAcademicienId != null) {
        refresh(_currentAcademicienId!);
      }
    });
  }

  List<BilanMedicalMensuel> get bilans => List.unmodifiable(_bilans);
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => !_isLoading && _bilans.isEmpty;

  void _onBilanChanged() {
    if (_currentAcademicienId != null) {
      refresh(_currentAcademicienId!);
    }
  }

  /// Charge les bilans medicaux mensuels d'un academicien.
  /// Interroge l'invalidation registry pour rattraper les evenements manques.
  Future<void> loadBilans(String academicienId) async {
    if (_isFetching) return;
    _currentAcademicienId = academicienId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Rattrapage d'evenements emis avant la creation de ce state
      if (_lastLoadedAt != null &&
          (_invalidationRegistry.wasInvalidatedAfter<
                BilanMedicalMensuelCreatedEvent
              >(
                _lastLoadedAt!,
              ) ||
              _invalidationRegistry.wasInvalidatedAfter<
                BilanMedicalMensuelUpdatedEvent
              >(
                _lastLoadedAt!,
              ) ||
              _invalidationRegistry.wasInvalidatedAfter<
                BilanMedicalMensuelDeletedEvent
              >(
                _lastLoadedAt!,
              ))) {
        // Les donnees sont potentiellement perimees, on invalide le cache
        _repository.clearCache();
      }

      _isFetching = true;
      final list = await _repository.getByAcademicienId(academicienId);
      _bilans = list;
      _lastLoadedAt = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isFetching = false;
      notifyListeners();
    }
  }

  /// Rafraichit la liste si les donnees sont potentiellement perimees
  /// et qu'aucun fetch n'est en cours.
  Future<void> refresh(String academicienId) async {
    if (_isFetching) return;

    final age = DateTime.now().difference(_lastLoadedAt ?? DateTime(0));
    if (age > const Duration(minutes: 2)) {
      await loadBilans(academicienId);
    }
  }

  /// Synchronise les bilans depuis le backend.
  Future<bool> syncFromApi(String academicienId) async {
    try {
      final success = await _repository.syncFromApi(academicienId);
      if (success) {
        await loadBilans(academicienId);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _currentAcademicienId = null;
    super.dispose();
  }
}
