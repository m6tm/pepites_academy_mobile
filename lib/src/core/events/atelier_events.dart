import 'domain_event.dart';

/// Emis apres la creation reussie d'un atelier.
/// Les composants dependants (AteliersProgressCard, seance composites) doivent
/// s'abonner via `EventBusSubscriberMixin.listenTo` sur ce type.
class AtelierCreeEvent extends DomainEvent {
  final String atelierId;
  final String seanceId;

  const AtelierCreeEvent({required this.atelierId, required this.seanceId});
}

/// Emis apres la mise a jour reussie de la configuration d'evaluation d'un atelier.
/// Les composants dependants (EvaluationState, ecrans de seance) doivent s'abonner
/// via `EventBusSubscriberMixin.listenTo` sur ce type pour invalider leur cache.
class AtelierUpdatedEvent extends DomainEvent {
  final String atelierId;
  final String seanceId;

  const AtelierUpdatedEvent({required this.atelierId, required this.seanceId});
}

class AtelierDeletedEvent extends DomainEvent {
  final String seanceId;

  const AtelierDeletedEvent(this.seanceId);
}

class ConfigurationAtelierModifieeEvent extends DomainEvent {
  final String atelierId;
  final String seanceId;

  const ConfigurationAtelierModifieeEvent({
    required this.atelierId,
    required this.seanceId,
  });
}

/// Emis apres la fermeture reussie d'un atelier.
class AtelierClosedEvent extends DomainEvent {
  final String atelierId;
  final String seanceId;

  const AtelierClosedEvent({required this.atelierId, required this.seanceId});
}

/// Emis apres l'application reussie d'un atelier.
class AtelierAppliedEvent extends DomainEvent {
  final String atelierId;
  final String seanceId;

  const AtelierAppliedEvent({required this.atelierId, required this.seanceId});
}
