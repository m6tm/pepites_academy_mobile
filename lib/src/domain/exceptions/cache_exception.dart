import 'domain_exception.dart';

/// Exception levée lors d'erreurs de cache ou de base de données locale.
class CacheException extends DomainException {
  const CacheException([
    String message = "Erreur de chargement des données locales",
  ]) : super(message, code: "CACHE_ERROR");
}
