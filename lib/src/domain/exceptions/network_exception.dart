import 'domain_exception.dart';

/// Exception levée lors de problèmes de connectivité réseau.
class NetworkException extends DomainException {
  const NetworkException([super.message = "Pas de connexion internet"])
    : super(code: "NETWORK_ERROR");
}

/// Exception levée lors d'un timeout.
class TimeoutException extends NetworkException {
  const TimeoutException([super.message = "Le délai d'attente a expiré"]);
}
