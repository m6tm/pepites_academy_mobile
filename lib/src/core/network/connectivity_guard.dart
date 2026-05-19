import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Verifie l'etat de la connexion reseau avant les appels API.
///
/// Doit etre injecte via DependencyInjection. Ne jamais instancier
/// directement dans les repositories.
class ConnectivityGuard {
  final Connectivity _connectivity;

  ConnectivityGuard({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Retourne true si l'appareil est connecte a Internet.
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result.isNotEmpty && result.first != ConnectivityResult.none;
  }

  /// Stream d'etat de connexion (pour ecouter les changements).
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}
