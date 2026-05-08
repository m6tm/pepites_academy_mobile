import 'dart:async';
import 'package:flutter/foundation.dart';
import 'domain_event.dart';
import 'domain_event_bus.dart';

/// Mixin de gestion automatique des abonnements au bus d'evenements.
/// Adapte pour ChangeNotifier : annule toutes les subscriptions dans dispose().
///
/// Usage :
///   class MyState extends ChangeNotifier with EventBusSubscriberMixin { ... }
mixin EventBusSubscriberMixin on ChangeNotifier {
  final List<StreamSubscription<dynamic>> _busSubscriptions = [];

  /// Abonne ce composant a un type d'evenement T du bus.
  /// L'abonnement est automatiquement annule dans dispose().
  void listenTo<T extends DomainEvent>(
    DomainEventBus bus,
    void Function(T) handler,
  ) {
    _busSubscriptions.add(bus.on<T>().listen(handler));
  }

  void _cancelBusSubscriptions() {
    for (final sub in _busSubscriptions) {
      sub.cancel();
    }
    _busSubscriptions.clear();
  }

  @override
  void dispose() {
    _cancelBusSubscriptions();
    super.dispose();
  }
}
