import 'domain_event.dart';

/// Evenement emis lors de la creation d'un bilan medical mensuel.
class BilanMedicalMensuelCreatedEvent extends DomainEvent {
  final String bilanId;
  final String academicienId;

  const BilanMedicalMensuelCreatedEvent(this.bilanId, this.academicienId);
}

/// Evenement emis lors de la mise a jour d'un bilan medical mensuel.
class BilanMedicalMensuelUpdatedEvent extends DomainEvent {
  final String bilanId;
  final String academicienId;

  const BilanMedicalMensuelUpdatedEvent(this.bilanId, this.academicienId);
}

/// Evenement emis lors de la suppression d'un bilan medical mensuel.
class BilanMedicalMensuelDeletedEvent extends DomainEvent {
  final String bilanId;
  final String academicienId;

  const BilanMedicalMensuelDeletedEvent(this.bilanId, this.academicienId);
}
