import 'domain_exception.dart';

/// Exception levee lors d'erreurs d'authentification (401).
class AuthException extends DomainException {
  const AuthException([super.message = "Non authentifie", String? messageKey])
    : super(
        code: "UNAUTHORIZED",
        messageKey: messageKey ?? 'exceptionAuthDefault',
      );
}

/// Exception levee lors d'erreurs d'autorisation (403).
class PermissionException extends DomainException {
  const PermissionException([
    super.message = "Acces refuse",
    String? messageKey,
  ]) : super(
         code: "FORBIDDEN",
         messageKey: messageKey ?? 'exceptionPermissionDefault',
       );
}
