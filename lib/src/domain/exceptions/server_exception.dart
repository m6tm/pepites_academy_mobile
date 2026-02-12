import 'domain_exception.dart';

/// Exception levée lors d'erreurs côté serveur (5xx).
class ServerException extends DomainException {
  const ServerException([
    super.message = "Erreur interne du serveur",
    String? code,
  ]) : super(code: code ?? "SERVER_ERROR");
}

/// Exception levée lors d'erreurs de requête (400, validation).
class RequestException extends DomainException {
  const RequestException(super.message, {super.details})
    : super(code: "BAD_REQUEST");
}

/// Exception levée lorsqu'une ressource est introuvable (404).
class NotFoundException extends DomainException {
  const NotFoundException([super.message = "Ressource introuvable"])
    : super(code: "NOT_FOUND");
}
