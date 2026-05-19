import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../application/services/notification_service.dart';
import '../../core/events/app_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../core/events/notification_events.dart';
import '../../domain/entities/notification_item.dart';

/// State management pour le module de notifications.
class NotificationState extends ChangeNotifier with EventBusSubscriberMixin {
  final NotificationService _notificationService;
  final DomainEventBus _eventBus;

  NotificationState({
    required NotificationService notificationService,
    required DomainEventBus eventBus,
  })  : _notificationService = notificationService,
        _eventBus = eventBus {
    listenTo<NotificationsReadEvent>(_eventBus, (_) => chargerNotifications(_currentUserRole));
    listenTo<NotificationDeletedEvent>(_eventBus, (_) => chargerNotifications(_currentUserRole));
    listenTo<AppResumedEvent>(_eventBus, (_) => _onRefreshIfStale());
  }

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  String _currentUserRole = 'encadreur';
  String get currentUserRole => _currentUserRole;

  int _nonLuesCount = 0;
  int get nonLuesCount => _nonLuesCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NotificationType? _filtreType;
  NotificationType? get filtreType => _filtreType;

  bool _afficherNonLuesUniquement = false;
  bool get afficherNonLuesUniquement => _afficherNonLuesUniquement;

  DateTime? _lastFetchedAt;
  bool _isFetching = false;

  List<NotificationItem> get notificationsFiltrees {
    var liste = List<NotificationItem>.from(_notifications);
    if (_afficherNonLuesUniquement) {
      liste = liste.where((n) => !n.estLue).toList();
    }
    if (_filtreType != null) {
      liste = liste.where((n) => n.type == _filtreType).toList();
    }
    return liste;
  }

  void _safeNotifyListeners() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _onRefreshIfStale() {
    if (_isFetching) return;
    final last = _lastFetchedAt;
    if (last == null) return;
    final age = DateTime.now().difference(last);
    if (age > const Duration(minutes: 2)) {
      chargerNotifications(_currentUserRole);
    }
  }

  /// Charge les notifications pour un role donne.
  Future<void> chargerNotifications(String role) async {
    if (_isFetching) return;
    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    _currentUserRole = role;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(role);
      _nonLuesCount = await _notificationService.compterNonLues(role);
      _lastFetchedAt = DateTime.now();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des notifications : $e';
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Synchronise les notifications avec le backend.
  Future<void> syncNotifications() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _notificationService.syncFromApi();
      await chargerNotifications(_currentUserRole);
    } catch (e) {
      _errorMessage = 'Erreur de synchronisation : $e';
      _safeNotifyListeners();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Marque une notification comme lue.
  Future<void> marquerCommeLue(String id) async {
    try {
      await _notificationService.marquerCommeLue(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(estLue: true);
        _nonLuesCount = (_nonLuesCount - 1).clamp(0, _notifications.length);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage : $e';
      _safeNotifyListeners();
    }
  }

  /// Marque toutes les notifications comme lues.
  Future<void> marquerToutesCommeLues() async {
    try {
      await _notificationService.marquerToutesCommeLues(_currentUserRole);
      _notifications = _notifications.map((n) => n.copyWith(estLue: true)).toList();
      _nonLuesCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage global : $e';
      _safeNotifyListeners();
    }
  }

  /// Supprime une notification.
  Future<void> supprimer(String id) async {
    try {
      await _notificationService.supprimer(id);
      final removed = _notifications.firstWhere((n) => n.id == id);
      _notifications.removeWhere((n) => n.id == id);
      if (!removed.estLue) {
        _nonLuesCount = (_nonLuesCount - 1).clamp(0, _notifications.length);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      _safeNotifyListeners();
    }
  }

  /// Supprime toutes les notifications lues.
  Future<void> supprimerLues() async {
    try {
      await _notificationService.supprimerLues(_currentUserRole);
      _notifications.removeWhere((n) => n.estLue);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression des lues : $e';
      _safeNotifyListeners();
    }
  }

  /// Definit le filtre par type.
  void setFiltreType(NotificationType? type) {
    _filtreType = type;
    notifyListeners();
  }

  /// Bascule l'affichage des non-lues uniquement.
  void toggleNonLuesUniquement() {
    _afficherNonLuesUniquement = !_afficherNonLuesUniquement;
    notifyListeners();
  }

  /// Rafraichit la liste depuis le cache local.
  void rafraichirDepuisCache() {
    chargerNotifications(_currentUserRole);
  }
}
