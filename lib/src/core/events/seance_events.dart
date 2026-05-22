import 'domain_event.dart';

class SeanceCreatedEvent extends DomainEvent {
  final String seanceId;
  const SeanceCreatedEvent(this.seanceId);
}

class SeanceUpdatedEvent extends DomainEvent {
  final String seanceId;
  const SeanceUpdatedEvent(this.seanceId);
}

class SeanceConflictEvent extends DomainEvent {
  final String seanceBloqueanteId;
  const SeanceConflictEvent({required this.seanceBloqueanteId});
}

class SeanceStatsChangedEvent extends DomainEvent {
  final String seanceId;
  const SeanceStatsChangedEvent(this.seanceId);
}

class SeanceClosedEvent extends DomainEvent {
  final String seanceId;
  const SeanceClosedEvent(this.seanceId);
}

class PresenceRecordedEvent extends DomainEvent {
  final String seanceId;
  const PresenceRecordedEvent(this.seanceId);
}