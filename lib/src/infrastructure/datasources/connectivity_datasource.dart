import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/connectivity_status.dart';

/// Source de donnees pour la surveillance de la connexion reseau.
/// Encapsule le package connectivity_plus et expose un flux
/// de ConnectivityStatus simplifie pour le domaine.
class ConnectivityDatasource {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  /// Dernier statut connu, mis en cache pour eviter les doublons.
  ConnectivityStatus _lastStatus = ConnectivityStatus.connected;

  ConnectivityDatasource({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  /// Demarre l'ecoute des changements de connectivite.
  /// Emet immediatement l'etat actuel dans le stream, puis ecoute
  /// les changements en continu.
  void startListening() {
    // Emission de l'etat initial dans le stream.
    _emitCurrentStatus();

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final status = _mapResultsToStatus(results);
      debugPrint('[Connectivity] Changement detecte: $results -> $status');
      if (status != _lastStatus) {
        _lastStatus = status;
        _statusController.add(status);
      }
    });
  }

  /// Recupere et emet l'etat actuel dans le stream.
  Future<void> _emitCurrentStatus() async {
    final status = await getCurrentStatus();
    debugPrint('[Connectivity] Etat initial: $status');
    _lastStatus = status;
    _statusController.add(status);
  }

  /// Retourne l'etat actuel de la connexion.
  Future<ConnectivityStatus> getCurrentStatus() async {
    final results = await _connectivity.checkConnectivity();
    return _mapResultsToStatus(results);
  }

  /// Flux continu de l'etat de la connexion.
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  ConnectivityStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    // Si aucun resultat ou uniquement "none", on est deconnecte.
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return ConnectivityStatus.disconnected;
    }
    return ConnectivityStatus.connected;
  }

  /// Libere les ressources.
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
