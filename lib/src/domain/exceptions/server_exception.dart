import 'domain_exception.dart';

/// Exception levée lors d'erreurs côté serveur (5xx).
class ServerException extends DomainException {
  const ServerException([
    String message = "Erreur interne du serveur",
    String? code,
  ]) : super(message, code: code ?? "SERVER_ERROR");
}

/// Exception levée lors d'erreurs de requête (400, validation).
class RequestException extends DomainException {
  const RequestException(String message, {dynamic details})
    : super(message, code: "BAD_REQUEST", details: details);
}

/// Exception levée lorsqu'une ressource est introuvable (404).
class NotFoundException extends DomainException {
  const NotFoundException([String message = "Ressource introuvable"])
    : super(message, code: "NOT_FOUND");
}
