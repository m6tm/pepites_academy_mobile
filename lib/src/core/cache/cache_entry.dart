/// Entree du cache avec TTL et tags d'invalidation.
class CacheEntry<T> {
  final T data;
  final DateTime _createdAt;
  final Duration ttl;
  final Set<String> tags;

  CacheEntry(
    this.data, {
    this.ttl = const Duration(minutes: 5),
    this.tags = const {},
  }) : _createdAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(_createdAt) > ttl;
}
