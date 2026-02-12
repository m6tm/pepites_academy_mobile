import 'domain_exception.dart';

/// Exception générique pour les erreurs non anticipées.
class UnknownException extends DomainException {
  const UnknownException([
    String message = "Une erreur inattendue est survenue",
    dynamic details,
  ]) : super(message, code: "UNKNOWN_ERROR", details: details);
}
