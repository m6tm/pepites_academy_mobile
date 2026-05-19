import 'package:flutter/material.dart';

/// Notifie les listeners quand la route courante change via Navigator.
///
/// Usage avec un RouteObserver dans MaterialApp :
/// ```dart
/// final routeObserver = RouteObserver<ModalRoute>();
/// MaterialApp(
///   navigatorObservers: [routeObserver],
///   ...
/// )
/// ```
///
/// Puis dans la page :
/// ```dart
/// class _MyPageState extends State<MyPage> with RouteAware {
///   late final RouterRefreshNotifier _notifier;
///
///   @override
///   void didChangeDependencies() {
///     super.didChangeDependencies();
///     routeObserver.subscribe(this, ModalRoute.of(context)!);
///   }
///
///   @override
///   void dispose() {
///     routeObserver.unsubscribe(this);
///     super.dispose();
///   }
///
///   @override
///   void didPopNext() {
///     _notifier.notifyReturned();
///   }
/// }
/// ```
///
/// Alternative sans RouteAware : utiliser un ValueNotifier `[String]`
/// que la sous-page met a true lors de son pop.
class RouterRefreshNotifier extends ChangeNotifier {
  bool _returned = false;

  bool get returned => _returned;

  void notifyReturned() {
    _returned = true;
    notifyListeners();
    _returned = false;
  }

  void consume() {
    _returned = false;
  }
}
