import 'dart:async';
import 'domain_event.dart';

/// Bus d'evenements global typé.
/// Permet a tout composant d'emettre ou d'ecouter des evenements de domaine
/// sans couplage direct entre emetteur et recepteur.
///
/// Doit etre instancie une seule fois et injecte via DependencyInjection.
/// Ne jamais instancier directement dans le code de presentation.
class DomainEventBus {
  final _controller = StreamController<DomainEvent>.broadcast();

  /// Retourne un stream filtre sur le type d'evenement T.
  Stream<T> on<T extends DomainEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  /// Emet un evenement vers tous les abonnes.
  void emit(DomainEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
