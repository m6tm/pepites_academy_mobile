import 'domain_exception.dart';

/// Exception generique pour les erreurs non anticipees.
class UnknownException extends DomainException {
  const UnknownException([
    super.message = "Une erreur inattendue est survenue",
    dynamic details,
    String? messageKey,
  ]) : super(
         code: "UNKNOWN_ERROR",
         details: details,
         messageKey: messageKey ?? 'exceptionUnknownDefault',
       );
}
