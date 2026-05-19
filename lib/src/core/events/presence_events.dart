import 'domain_event.dart';

/// Emis apres l'enregistrement reussi d'une presence (scan QR ou manuel).
class PresenceCreatedEvent extends DomainEvent {
  final String presenceId;
  final String seanceId;
  final String profilId;

  const PresenceCreatedEvent({
    required this.presenceId,
    required this.seanceId,
    required this.profilId,
  });
}

/// Emis apres la suppression d'une presence.
class PresenceDeletedEvent extends DomainEvent {
  final String presenceId;
  final String seanceId;

  const PresenceDeletedEvent({
    required this.presenceId,
    required this.seanceId,
  });
}
