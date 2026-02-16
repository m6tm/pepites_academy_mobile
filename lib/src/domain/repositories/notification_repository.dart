import '../entities/notification_item.dart';

/// Contrat pour la gestion des notifications.
abstract class NotificationRepository {
  /// Recupere toutes les notifications.
  Future<List<NotificationItem>> getAll();

  /// Recupere les notifications filtrees par role cible.
  Future<List<NotificationItem>> getByRole(String role);

  /// Recupere les notifications non lues.
  Future<List<NotificationItem>> getNonLues(String role);

  /// Ajoute une nouvelle notification.
  Future<NotificationItem> add(NotificationItem notification);

  /// Marque une notification comme lue.
  Future<void> marquerCommeLue(String id);

  /// Marque toutes les notifications comme lues pour un role donne.
  Future<void> marquerToutesCommeLues(String role);

  /// Supprime une notification.
  Future<void> delete(String id);

  /// Supprime toutes les notifications lues pour un role donne.
  Future<void> supprimerLues(String role);

  /// Compte le nombre de notifications non lues pour un role.
  Future<int> compterNonLues(String role);
}
