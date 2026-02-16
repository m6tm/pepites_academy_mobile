import 'dart:async';
import '../../domain/entities/connectivity_status.dart';
import '../../domain/repositories/connectivity_repository.dart';

/// Service applicatif pour la gestion de la connectivite reseau.
/// Fournit un acces simplifie a l'etat de la connexion et permet
/// aux autres services de reagir aux changements de connectivite.
class ConnectivityService {
  final ConnectivityRepository _repository;

  ConnectivityService({required ConnectivityRepository repository})
      : _repository = repository;

  /// Retourne l'etat actuel de la connexion.
  Future<ConnectivityStatus> getCurrentStatus() {
    return _repository.getCurrentStatus();
  }

  /// Flux continu de l'etat de la connexion.
  Stream<ConnectivityStatus> get statusStream => _repository.statusStream;

  /// Verifie si le peripherique est actuellement connecte.
  Future<bool> isConnected() async {
    final status = await getCurrentStatus();
    return status == ConnectivityStatus.connected;
  }

  /// Libere les ressources.
  void dispose() {
    _repository.dispose();
  }
}
