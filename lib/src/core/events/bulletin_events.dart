import 'domain_event.dart';

class BulletinCreatedEvent extends DomainEvent {
  final String bulletinId;
  final String academicienId;

  const BulletinCreatedEvent({required this.bulletinId, required this.academicienId});
}

class BulletinDeletedEvent extends DomainEvent {
  final String bulletinId;
  final String academicienId;

  const BulletinDeletedEvent({required this.bulletinId, required this.academicienId});
}
