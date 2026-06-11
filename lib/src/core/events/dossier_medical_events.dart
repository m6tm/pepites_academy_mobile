import 'domain_event.dart';

/// Evenement emis lors de la creation d'un dossier medical.
class DossierMedicalCreatedEvent extends DomainEvent {
  final String dossierId;
  final String academicienId;

  const DossierMedicalCreatedEvent(this.dossierId, this.academicienId);
}

/// Evenement emis lors de la mise a jour d'un dossier medical.
class DossierMedicalUpdatedEvent extends DomainEvent {
  final String dossierId;
  final String academicienId;

  const DossierMedicalUpdatedEvent(this.dossierId, this.academicienId);
}

/// Evenement emis lors de la suppression d'un dossier medical.
class DossierMedicalDeletedEvent extends DomainEvent {
  final String dossierId;
  final String academicienId;

  const DossierMedicalDeletedEvent(this.dossierId, this.academicienId);
}
