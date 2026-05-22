import 'domain_exception.dart';

/// Exception levee lors de problemes de connectivite reseau.
class NetworkException extends DomainException {
  const NetworkException([
    super.message = "Pas de connexion internet",
    String? messageKey,
  ]) : super(
         code: "NETWORK_ERROR",
         messageKey: messageKey ?? 'exceptionNetworkDefault',
       );
}

/// Exception levee lorsque l'appareil est hors ligne
/// et qu'aucune donnee stale n'est disponible en cache.
class OfflineException extends NetworkException {
  const OfflineException([
    String message = "Appareil hors ligne et aucune donnee en cache",
    String? messageKey,
  ]) : super(message, messageKey ?? 'exceptionOfflineDefault');
}

/// Exception levee lors d'un timeout.
class TimeoutException extends NetworkException {
  const TimeoutException([
    String message = "Le delai d'attente a expire",
    String? messageKey,
  ]) : super(message, messageKey ?? 'exceptionTimeoutDefault');
}
