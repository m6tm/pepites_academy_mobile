import 'package:flutter/material.dart';
import '../../application/services/notification_service.dart';
import '../../domain/entities/notification_item.dart';

/// State management pour le module de notifications.
/// Gere le chargement, le filtrage, le marquage et la suppression
/// des notifications pour un role donne.
class NotificationState extends ChangeNotifier {
  final NotificationService _notificationService;

  NotificationState({required NotificationService notificationService})
    : _notificationService = notificationService;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  int _nonLuesCount = 0;
  int get nonLuesCount => _nonLuesCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NotificationType? _filtreType;
  NotificationType? get filtreType => _filtreType;

  bool _afficherNonLuesUniquement = false;
  bool get afficherNonLuesUniquement => _afficherNonLuesUniquement;

  /// Notifications filtrees selon les criteres actifs.
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

  /// Charge les notifications pour un role donne.
  Future<void> chargerNotifications(String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(role);
      _nonLuesCount = await _notificationService.compterNonLues(role);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des notifications : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marque une notification comme lue et rafraichit le compteur.
  Future<void> marquerCommeLue(String id, String role) async {
    try {
      await _notificationService.marquerCommeLue(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(estLue: true);
      }
      _nonLuesCount = await _notificationService.compterNonLues(role);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage : $e';
      notifyListeners();
    }
  }

  /// Marque toutes les notifications comme lues.
  Future<void> marquerToutesCommeLues(String role) async {
    try {
      await _notificationService.marquerToutesCommeLues(role);
      _notifications = _notifications
          .map((n) => n.copyWith(estLue: true))
          .toList();
      _nonLuesCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage : $e';
      notifyListeners();
    }
  }

  /// Supprime une notification.
  Future<void> supprimer(String id, String role) async {
    try {
      await _notificationService.supprimer(id);
      _notifications.removeWhere((n) => n.id == id);
      _nonLuesCount = await _notificationService.compterNonLues(role);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      notifyListeners();
    }
  }

  /// Supprime toutes les notifications lues.
  Future<void> supprimerLues(String role) async {
    try {
      await _notificationService.supprimerLues(role);
      _notifications.removeWhere((n) => n.estLue);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression : $e';
      notifyListeners();
    }
  }

  /// Applique un filtre par type de notification.
  void setFiltreType(NotificationType? type) {
    _filtreType = type;
    notifyListeners();
  }

  /// Active/desactive le filtre "non lues uniquement".
  void toggleNonLuesUniquement() {
    _afficherNonLuesUniquement = !_afficherNonLuesUniquement;
    notifyListeners();
  }

  /// Reinitialise tous les filtres.
  void reinitialiserFiltres() {
    _filtreType = null;
    _afficherNonLuesUniquement = false;
    notifyListeners();
  }

  /// Efface le message d'erreur.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
