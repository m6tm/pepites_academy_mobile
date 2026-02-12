import 'domain_exception.dart';

/// Exception levée lors d'erreurs d'authentification (401).
class AuthException extends DomainException {
  const AuthException([super.message = "Non authentifié"])
    : super(code: "UNAUTHORIZED");
}

/// Exception levée lors d'erreurs d'autorisation (403).
class PermissionException extends DomainException {
  const PermissionException([super.message = "Accès refusé"])
    : super(code: "FORBIDDEN");
}
