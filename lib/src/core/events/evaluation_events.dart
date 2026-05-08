import 'domain_event.dart';

/// Emis apres la creation reussie d'une evaluation multicritere.
/// Les composants dependants (dashboard, historique) doivent s'abonner
/// via `EventBusSubscriberMixin.listenTo` sur ce type.
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
