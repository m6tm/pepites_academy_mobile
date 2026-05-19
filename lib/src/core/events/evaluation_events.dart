import 'domain_event.dart';

/// Emis apres la creation reussie d'une evaluation multicritere.
class EvaluationCreeeEvent extends DomainEvent {
  final String evaluationId;
  final String academicienId;
  final String atelierId;
  final String seanceId;

  const EvaluationCreeeEvent({
    required this.evaluationId,
    required this.academicienId,
    required this.atelierId,
    required this.seanceId,
  });
}

class EvaluationUpdatedEvent extends DomainEvent {
  final String evaluationId;
  final String academicienId;
  final String atelierId;
  final String seanceId;

  const EvaluationUpdatedEvent({
    required this.evaluationId,
    required this.academicienId,
    required this.atelierId,
    required this.seanceId,
  });
}

class EvaluationDeletedEvent extends DomainEvent {
  final String evaluationId;

  const EvaluationDeletedEvent(this.evaluationId);
}
