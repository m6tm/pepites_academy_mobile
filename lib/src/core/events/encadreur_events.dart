import 'domain_event.dart';

/// Emis après toute mutation de la liste des encadreurs
/// (création ou suppression). Permet aux écrans consommateurs
/// de rafraîchir leur état sans polling.
class EncadreurListChangedEvent extends DomainEvent {
  const EncadreurListChangedEvent();
}

/// Emis lorsqu'un encadreur cree offline est en conflit d'email (409)
/// avec une entite existante sur le serveur.
class EncadreurEmailConflictEvent extends DomainEvent {
  final String? email;
  const EncadreurEmailConflictEvent({this.email});
}
