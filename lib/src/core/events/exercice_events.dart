import 'domain_event.dart';

class ExerciceCreatedEvent extends DomainEvent {
  final String exerciceId;
  final String atelierId;

  const ExerciceCreatedEvent({required this.exerciceId, required this.atelierId});
}

class ExerciceUpdatedEvent extends DomainEvent {
  final String exerciceId;
  final String atelierId;

  const ExerciceUpdatedEvent({required this.exerciceId, required this.atelierId});
}

class ExerciceDeletedEvent extends DomainEvent {
  final String exerciceId;
  final String atelierId;

  const ExerciceDeletedEvent({required this.exerciceId, required this.atelierId});
}

class ExerciceReorderedEvent extends DomainEvent {
  final String atelierId;

  const ExerciceReorderedEvent(this.atelierId);
}

class ExerciceClosedEvent extends DomainEvent {
  final String exerciceId;
  final String atelierId;

  const ExerciceClosedEvent({required this.exerciceId, required this.atelierId});
}
