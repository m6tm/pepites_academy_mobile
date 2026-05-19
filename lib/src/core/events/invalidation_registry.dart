import 'dart:collection';
import 'domain_event.dart';

/// Registre d'invalidation global permettant aux BLoCs/States crees
/// apres une mutation de detecter qu'un re-fetch est necessaire.
///
/// Doit etre injecte via DependencyInjection (getIt) — jamais instancie
/// directement dans le code de presentation.
class InvalidationRegistry {
  final _invalidated = HashMap<Type, DateTime>();

  /// Marque un type d'evenement comme invalide a l'instant present.
  void markInvalidated<T extends DomainEvent>() {
    _invalidated[T] = DateTime.now();
  }

  /// Retourne true si le type T a ete invalide apres [loadedAt].
  bool wasInvalidatedAfter<T extends DomainEvent>(DateTime loadedAt) {
    final inv = _invalidated[T];
    return inv != null && inv.isAfter(loadedAt);
  }

  /// Retourne la date de derniere invalidation pour le type T, ou null.
  DateTime? lastInvalidationOf<T extends DomainEvent>() => _invalidated[T];

  /// Efface le registre (utile lors de la deconnexion).
  void clear() => _invalidated.clear();
}
