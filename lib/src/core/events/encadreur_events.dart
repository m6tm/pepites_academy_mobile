import 'domain_event.dart';

/// Emis après toute mutation de la liste des encadreurs
/// (création ou suppression). Permet aux écrans consommateurs
/// de rafraîchir leur état sans polling.
class EncadreurListChangedEvent extends DomainEvent {
  const EncadreurListChangedEvent();
}
