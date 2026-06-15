import 'package:flutter/foundation.dart';
import '../../core/events/app_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../application/services/app_preferences.dart';

/// Etat du profil utilisateur courant.
/// Charge les informations locales (preferences) et rafraichit automatiquement
/// lorsque l'application reprend ou lors d'un appel explicite.
class CurrentUserProfileState extends ChangeNotifier
    with EventBusSubscriberMixin {
  final AppPreferences _preferences;

  CurrentUserProfileState(this._preferences, DomainEventBus eventBus) {
    listenTo<AppResumedEvent>(eventBus, (_) => _onRefreshIfStale());
  }

  String? _userName;
  String? _fullName;
  String? _email;
  String? _photoUrl;
  bool _isLoading = false;
  bool _hasLoadedOnce = false;

  DateTime? _lastLoadedAt;
  bool _isFetching = false;

  String? get userName => _userName;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get photoUrl => _photoUrl;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;

  /// Charge les informations du profil utilisateur.
  Future<void> load({bool forceRefresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    _isLoading = true;
    notifyListeners();

    try {
      final userName = await _preferences.getUserName();
      final fullName = await _preferences.getUserFullName();
      final email = await _preferences.getUserEmail();
      final photoUrl = await _preferences.getUserPhoto();

      _userName = userName;
      _fullName = fullName.isEmpty ? null : fullName;
      _email = email;
      _photoUrl = photoUrl;
      _lastLoadedAt = DateTime.now();
      _hasLoadedOnce = true;
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraichit les informations du profil.
  Future<void> refresh() => load(forceRefresh: true);

  void _onRefreshIfStale() {
    if (_isFetching) return;
    final last = _lastLoadedAt;
    if (last == null) {
      load();
      return;
    }
    final age = DateTime.now().difference(last);
    if (age > const Duration(minutes: 2)) {
      refresh();
    }
  }
}
