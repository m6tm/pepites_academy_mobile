import 'package:flutter/foundation.dart';
import '../../core/events/app_events.dart';
import '../../core/events/dossier_medical_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../core/events/invalidation_registry.dart';
import '../../domain/entities/dossier_medical.dart';
import '../../infrastructure/repositories/dossier_medical_repository_impl.dart';

/// Etat de gestion de la liste des dossiers medicaux d'un academicien.
///
/// Ce ChangeNotifier applique la strategie de fraicheur des donnees :
/// - Ecoute les evenements de domaine via [EventBusSubscriberMixin].
/// - Interroge l'[InvalidationRegistry] au chargement initial.
/// - Utilise la variante SWR du repository pour un affichage fluide.
class DossierMedicalState extends ChangeNotifier
    with EventBusSubscriberMixin {
  final DossierMedicalRepositoryImpl _repository;
  final DomainEventBus _eventBus;
  final InvalidationRegistry _invalidationRegistry;

  List<DossierMedical> _dossiers = [];
  bool _isLoading = false;
  String? _error;
  String? _currentAcademicienId;
  DateTime? _lastLoadedAt;
  bool _isFetching = false;

  DossierMedicalState(
    this._repository,
    this._eventBus,
    this._invalidationRegistry,
  ) {
    // Ecoute les mutations pour rafraichir automatiquement
    listenTo<DossierMedicalCreatedEvent>(_eventBus, (_) => _onDossierChanged());
    listenTo<DossierMedicalUpdatedEvent>(_eventBus, (_) => _onDossierChanged());
    listenTo<DossierMedicalDeletedEvent>(_eventBus, (_) => _onDossierChanged());
    // Ecoute le retour au foreground pour rafraichir si les donnees sont perimees
    listenTo<AppResumedEvent>(_eventBus, (_) {
      if (_currentAcademicienId != null) {
        refresh(_currentAcademicienId!);
      }
    });
  }

  List<DossierMedical> get dossiers => List.unmodifiable(_dossiers);
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => !_isLoading && _dossiers.isEmpty;

  void _onDossierChanged() {
    if (_currentAcademicienId != null) {
      refresh(_currentAcademicienId!);
    }
  }

  /// Charge les dossiers medicaux d'un academicien.
  /// Interroge l'invalidation registry pour rattraper les evenements manques.
  Future<void> loadDossiers(String academicienId) async {
    if (_isFetching) return;
    _currentAcademicienId = academicienId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Rattrapage d'evenements emis avant la creation de ce state
      if (_lastLoadedAt != null &&
          (_invalidationRegistry.wasInvalidatedAfter<DossierMedicalCreatedEvent>(
                _lastLoadedAt!,
              ) ||
              _invalidationRegistry.wasInvalidatedAfter<
                DossierMedicalUpdatedEvent
              >(
                _lastLoadedAt!,
              ))) {
        // Les donnees sont potentielment perimees, on invalide le cache
        _repository.clearCache();
      }

      _isFetching = true;
      final list = await _repository.getByAcademicienId(academicienId);
      _dossiers = list;
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
      await loadDossiers(academicienId);
    }
  }

  /// Synchronise les dossiers depuis le backend.
  Future<bool> syncFromApi(String academicienId) async {
    try {
      final success = await _repository.syncFromApi(academicienId);
      if (success) {
        await loadDossiers(academicienId);
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
