import 'package:flutter/widgets.dart';
import '../events/app_events.dart';
import '../events/domain_event_bus.dart';

/// Observe le cycle de vie de l'application et emet AppResumedEvent
/// sur le bus de domaine lorsque l'app revient au premier plan.
///
/// Doit etre instancie une seule fois dans DependencyInjection.init()
/// pour que l'observateur soit enregistre au demarrage.
class AppLifecycleService with WidgetsBindingObserver {
  final DomainEventBus _bus;

  AppLifecycleService(this._bus) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bus.emit(const AppResumedEvent());
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
