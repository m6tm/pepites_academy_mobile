import 'cache_entry.dart';

/// Cache memoire LRU avec TTL, invalidation par tags et deduplication
/// des appels concurrents (stale-while-revalidate).
///
/// Ne jamais instancier en global statique : injecter via DependencyInjection.
class RepositoryCache<T> {
  final int maxSize;
  final _store = <String, CacheEntry<T>>{};
  final _inFlight = <String, Future<T>>{};

  RepositoryCache({this.maxSize = 100});

  /// Retourne la valeur si presente et non expiree, sinon null.
  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }
    // LRU touch : deplace l'entree en fin de map
    _store.remove(key);
    _store[key] = entry;
    return entry.data;
  }

  /// Retourne la valeur meme si expiree (stale-while-revalidate).
  T? getStale(String key) => _store[key]?.data;

  void set(
    String key,
    T data, {
    Duration? ttl,
    Set<String> tags = const {},
  }) {
    if (_store.length >= maxSize) _store.remove(_store.keys.first);
    _store[key] = CacheEntry(
      data,
      ttl: ttl ?? const Duration(minutes: 5),
      tags: tags,
    );
  }

  /// Supprime toutes les entrees portant le tag donne.
  void invalidateByTag(String tag) {
    _store.removeWhere((_, entry) => entry.tags.contains(tag));
  }

  void invalidateKey(String key) => _store.remove(key);

  /// Deduplique les appels concurrents pour la meme cle.
  /// Si un fetch est deja en cours, retourne le meme Future.
  Future<T> getOrFetch(String key, Future<T> Function() fetcher) {
    return _inFlight.putIfAbsent(key, () async {
      try {
        return await fetcher();
      } finally {
        _inFlight.remove(key);
      }
    });
  }

  void clear() => _store.clear();
}
