import 'domain_event.dart';

class AnnotationCreatedEvent extends DomainEvent {
  final String annotationId;
  final String atelierId;
  final String academicienId;
  final String? exerciceId;

  const AnnotationCreatedEvent({
    required this.annotationId,
    required this.atelierId,
    required this.academicienId,
    this.exerciceId,
  });
}

class AnnotationUpdatedEvent extends DomainEvent {
  final String annotationId;
  final String atelierId;
  final String academicienId;

  const AnnotationUpdatedEvent({
    required this.annotationId,
    required this.atelierId,
    required this.academicienId,
  });
}

class AnnotationDeletedEvent extends DomainEvent {
  final String annotationId;
  final String atelierId;

  const AnnotationDeletedEvent({required this.annotationId, required this.atelierId});
}
