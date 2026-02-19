import 'domain_exception.dart';

/// Exception levee lors d'erreurs de cache ou de base de donnees locale.
class CacheException extends DomainException {
  const CacheException([
    super.message = "Erreur de chargement des donnees locales",
    String? messageKey,
  ]) : super(
         code: "CACHE_ERROR",
         messageKey: messageKey ?? 'exceptionCacheDefault',
       );
}
