import 'domain_exception.dart';

/// Exception levée lors d'erreurs d'authentification (401).
class AuthException extends DomainException {
  const AuthException([String message = "Non authentifié"])
    : super(message, code: "UNAUTHORIZED");
}

/// Exception levée lors d'erreurs d'autorisation (403).
class PermissionException extends DomainException {
  const PermissionException([String message = "Accès refusé"])
    : super(message, code: "FORBIDDEN");
}
