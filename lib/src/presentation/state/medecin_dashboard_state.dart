import 'package:flutter/foundation.dart';
import '../../core/events/app_events.dart';
import '../../core/events/dashboard_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/event_bus_subscriber_mixin.dart';
import '../../domain/entities/medecin_dashboard_stats.dart';
import '../../domain/repositories/medecin_repository.dart';

/// Etat du dashboard medecin avec ChangeNotifier.
class MedecinDashboardState extends ChangeNotifier with EventBusSubscriberMixin {
  final MedecinRepository _repository;

  MedecinDashboardState(this._repository, DomainEventBus eventBus) {
    listenTo<AppResumedEvent>(eventBus, (_) => _onRefreshIfStale());
    listenTo<DashboardStatsUpdatedEvent>(eventBus, (_) => refresh());
  }

  MedecinDashboardStats _stats = MedecinDashboardStats.empty;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFromCache = false;

  DateTime? _lastFetchedAt;
  bool _isFetching = false;

  MedecinDashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFromCache => _isFromCache;

  /// Charge les statistiques du dashboard.
  Future<void> loadStats({bool forceRefresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final (stats, failure, fromCache) = await _repository.getStats(
        forceRefresh: forceRefresh,
      );

      if (stats != null) {
        _stats = stats;
        _isFromCache = fromCache;
        _lastFetchedAt = DateTime.now();
      }

      if (failure != null && stats == null) {
        _errorMessage = failure.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isFetching = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraichit les statistiques.
  Future<void> refresh() => loadStats(forceRefresh: true);

  void _onRefreshIfStale() {
    if (_isFetching) return;
    final last = _lastFetchedAt;
    if (last == null) return;
    final age = DateTime.now().difference(last);
    if (age > const Duration(minutes: 2)) {
      refresh();
    }
  }
}
