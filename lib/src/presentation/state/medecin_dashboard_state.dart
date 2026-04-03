import 'package:flutter/foundation.dart';
import '../../domain/entities/medecin_dashboard_stats.dart';
import '../../domain/repositories/medecin_repository.dart';

/// Etat du dashboard medecin avec ChangeNotifier.
class MedecinDashboardState extends ChangeNotifier {
  final MedecinRepository _repository;

  MedecinDashboardStats _stats = MedecinDashboardStats.empty;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFromCache = false;

  MedecinDashboardState(this._repository);

  MedecinDashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFromCache => _isFromCache;

  /// Charge les statistiques du dashboard.
  Future<void> loadStats({bool forceRefresh = false}) async {
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
      }
      
      if (failure != null && stats == null) {
        _errorMessage = failure.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraichit les statistiques.
  Future<void> refresh() => loadStats(forceRefresh: true);
}
