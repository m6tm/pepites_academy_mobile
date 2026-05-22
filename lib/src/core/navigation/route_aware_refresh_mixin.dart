import 'package:flutter/material.dart';
import 'router_refresh_notifier.dart';

/// Mixin pour les StateFulWidget qui doivent rafraichir leur contenu
/// lorsque l'utilisateur revient d'une sous-page.
///
/// Usage :
/// ```dart
/// class _MyPageState extends State<MyPage>
///     with RouteAware, RouteAwareRefreshMixin<MyPage> {
///   @override
///   void didChangeDependencies() {
///     super.didChangeDependencies();
///     subscribeRouteObserver(context);
///   }
///
///   @override
///   void dispose() {
///     unsubscribeRouteObserver();
///     super.dispose();
///   }
///
///   @override
///   void didPopNext() {
///     refreshNotifier.notifyReturned();
///   }
/// }
/// ```
mixin RouteAwareRefreshMixin<T extends StatefulWidget> on State<T>, RouteAware {
  final RouterRefreshNotifier refreshNotifier = RouterRefreshNotifier();

  void subscribeRouteObserver(BuildContext context, RouteObserver<ModalRoute> observer) {
    final route = ModalRoute.of(context);
    if (route != null) {
      observer.subscribe(this, route);
    }
  }

  void unsubscribeRouteObserver(RouteObserver<ModalRoute> observer) {
    observer.unsubscribe(this);
  }
}
