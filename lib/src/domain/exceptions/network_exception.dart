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

/// Exception levee lors d'un timeout.
class TimeoutException extends NetworkException {
  const TimeoutException([
    String message = "Le delai d'attente a expire",
    String? messageKey,
  ]) : super(message, messageKey ?? 'exceptionTimeoutDefault');
}
