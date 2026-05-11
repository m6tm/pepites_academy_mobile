import 'domain_event.dart';

/// Evenement emit quand une creation de seance est rejetee par le serveur (409 Conflict).
/// Cela se produit quand une autre session a deja ouvert une seance.
class SeanceConflictEvent extends DomainEvent {
  final String seanceBloqueanteId;

  const SeanceConflictEvent({required this.seanceBloqueanteId});
}