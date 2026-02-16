import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/connectivity_status.dart';
import '../../application/services/connectivity_service.dart';

/// State reactif pour l'etat de la connexion reseau.
/// Notifie les widgets de tout changement de connectivite.
class ConnectivityState extends ChangeNotifier {
  final ConnectivityService _connectivityService;
  StreamSubscription<ConnectivityStatus>? _subscription;

  ConnectivityStatus _status = ConnectivityStatus.connected;

  ConnectivityState({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService {
    _init();
  }

  /// Etat actuel de la connexion.
  ConnectivityStatus get status => _status;

  /// Indique si le peripherique est connecte.
  bool get isConnected => _status == ConnectivityStatus.connected;

  /// Indique si le peripherique est deconnecte.
  bool get isDisconnected => _status == ConnectivityStatus.disconnected;

  /// Indique si une synchronisation est en cours.
  bool get isSyncing => _status == ConnectivityStatus.syncing;

  void _init() async {
    _status = await _connectivityService.getCurrentStatus();
    notifyListeners();

    _subscription = _connectivityService.statusStream.listen((status) {
      if (_status != status) {
        _status = status;
        notifyListeners();
      }
    });
  }

  /// Force la mise a jour du statut (utilise par SyncState).
  void updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
