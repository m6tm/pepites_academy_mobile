import 'domain_event.dart';

/// Emis par AppLifecycleService lorsque l'application revient au premier plan.
/// Les states qui gerent des donnees sensibles au temps doivent s'abonner
/// pour declencher un rafraichissement si les donnees sont perimees.
class AppResumedEvent extends DomainEvent {
  const AppResumedEvent();
}
