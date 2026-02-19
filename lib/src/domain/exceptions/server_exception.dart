import 'domain_exception.dart';

/// Exception levee lors d'erreurs cote serveur (5xx).
class ServerException extends DomainException {
  const ServerException([
    super.message = "Erreur interne du serveur",
    String? code,
    String? messageKey,
  ]) : super(
         code: code ?? "SERVER_ERROR",
         messageKey: messageKey ?? 'exceptionServerDefault',
       );
}

/// Exception levee lors d'erreurs de requete (400, validation).
class RequestException extends DomainException {
  const RequestException(super.message, {super.details, String? messageKey})
    : super(
        code: "BAD_REQUEST",
        messageKey: messageKey ?? 'exceptionRequestBad',
      );
}

/// Exception levee lorsqu'une ressource est introuvable (404).
class NotFoundException extends DomainException {
  const NotFoundException([
    super.message = "Ressource introuvable",
    String? messageKey,
  ]) : super(
         code: "NOT_FOUND",
         messageKey: messageKey ?? 'exceptionNotFoundDefault',
       );
}
