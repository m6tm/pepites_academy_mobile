import 'domain_event.dart';

/// Emis apres la mise a jour reussie de la configuration d'evaluation d'un atelier.
/// Les composants dependants (EvaluationState, ecrans de seance) doivent s'abonner
/// via `EventBusSubscriberMixin.listenTo` sur ce type pour invalider leur cache.
class ConfigurationAtelierModifieeEvent extends DomainEvent {
  final String atelierId;
  final String seanceId;

  const ConfigurationAtelierModifieeEvent({
    required this.atelierId,
    required this.seanceId,
  });
}
