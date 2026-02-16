import '../../domain/entities/notification_item.dart';
import '../../infrastructure/repositories/notification_repository_impl.dart';

/// Service applicatif gerant la logique metier des notifications.
/// Permet de consulter, marquer comme lues et gerer les notifications
/// pour les administrateurs et encadreurs.
class NotificationService {
  final NotificationRepositoryImpl _notificationRepository;

  NotificationService({
    required NotificationRepositoryImpl notificationRepository,
  }) : _notificationRepository = notificationRepository;

  /// Recupere les notifications pour un role donne.
  Future<List<NotificationItem>> getNotifications(String role) async {
    return _notificationRepository.getByRole(role);
  }

  /// Recupere les notifications non lues pour un role.
  Future<List<NotificationItem>> getNotificationsNonLues(String role) async {
    return _notificationRepository.getNonLues(role);
  }

  /// Marque une notification comme lue.
  Future<void> marquerCommeLue(String id) async {
    return _notificationRepository.marquerCommeLue(id);
  }

  /// Marque toutes les notifications comme lues pour un role.
  Future<void> marquerToutesCommeLues(String role) async {
    return _notificationRepository.marquerToutesCommeLues(role);
  }

  /// Supprime une notification.
  Future<void> supprimer(String id) async {
    return _notificationRepository.delete(id);
  }

  /// Supprime toutes les notifications lues pour un role.
  Future<void> supprimerLues(String role) async {
    return _notificationRepository.supprimerLues(role);
  }

  /// Compte le nombre de notifications non lues pour un role.
  Future<int> compterNonLues(String role) async {
    return _notificationRepository.compterNonLues(role);
  }

  /// Cree une nouvelle notification.
  Future<NotificationItem> creerNotification({
    required String titre,
    required String description,
    required NotificationType type,
    NotificationPriority priorite = NotificationPriority.normale,
    String? referenceId,
    String cibleRole = 'tous',
  }) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titre: titre,
      description: description,
      type: type,
      priorite: priorite,
      dateCreation: DateTime.now(),
      referenceId: referenceId,
      cibleRole: cibleRole,
    );
    return _notificationRepository.add(notification);
  }
}
