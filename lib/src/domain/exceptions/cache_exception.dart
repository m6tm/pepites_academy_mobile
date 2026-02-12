import 'domain_exception.dart';

/// Exception levée lors d'erreurs de cache ou de base de données locale.
class CacheException extends DomainException {
  const CacheException([
    super.message = "Erreur de chargement des données locales",
  ]) : super(code: "CACHE_ERROR");
}
