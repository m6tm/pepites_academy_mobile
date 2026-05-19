import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_datasource.dart';

/// Implementation locale du repository d'activites.
class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDatasource _datasource;

  final _cache = RepositoryCache<List<Activity>>();

  ActivityRepositoryImpl(this._datasource);

  @override
  Future<Activity> add(Activity activity) async {
    final created = await _datasource.add(activity);
    _cache.invalidateByTag('activities');
    return created;
  }

  @override
  Future<List<Activity>> getAll() async {
    const key = 'all';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getAll();
    _cache.set(key, result, ttl: CacheTtl.activities, tags: {'activities'});
    return result;
  }

  @override
  Future<List<Activity>> getRecent(int limit) async {
    final key = 'recent_$limit';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getRecent(limit);
    _cache.set(key, result, ttl: CacheTtl.activities, tags: {'activities'});
    return result;
  }

  @override
  Future<void> purgeOlderThan(DateTime date) async {
    await _datasource.purgeOlderThan(date);
    _cache.invalidateByTag('activities');
  }

  void clearCache() {
    _cache.clear();
  }
}
