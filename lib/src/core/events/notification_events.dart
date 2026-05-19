import 'domain_event.dart';

class NotificationsReadEvent extends DomainEvent {
  const NotificationsReadEvent();
}

class NotificationDeletedEvent extends DomainEvent {
  final String notificationId;

  const NotificationDeletedEvent(this.notificationId);
}
