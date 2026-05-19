import 'domain_event.dart';

/// Emis apres la creation reussie d'un academicien.
class AcademicienCreatedEvent extends DomainEvent {
  final String academicienId;
  const AcademicienCreatedEvent(this.academicienId);
}

/// Emis apres la mise a jour reussie d'un academicien.
class AcademicienUpdatedEvent extends DomainEvent {
  final String academicienId;
  const AcademicienUpdatedEvent(this.academicienId);
}

/// Emis apres la suppression reussie d'un academicien.
class AcademicienDeletedEvent extends DomainEvent {
  final String academicienId;
  const AcademicienDeletedEvent(this.academicienId);
}
