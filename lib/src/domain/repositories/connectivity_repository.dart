import '../entities/connectivity_status.dart';

/// Contrat pour la surveillance de l'etat de la connexion reseau.
abstract class ConnectivityRepository {
  /// Retourne l'etat actuel de la connexion.
  Future<ConnectivityStatus> getCurrentStatus();

  /// Flux continu de l'etat de la connexion.
  Stream<ConnectivityStatus> get statusStream;

  /// Libere les ressources.
  void dispose();
}
