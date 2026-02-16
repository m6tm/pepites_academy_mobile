import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_datasource.dart';

/// Implementation locale du repository d'activites.
/// Delegue les operations au datasource local.
class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDatasource _datasource;

  ActivityRepositoryImpl(this._datasource);

  @override
  Future<Activity> add(Activity activity) async {
    return _datasource.add(activity);
  }

  @override
  Future<List<Activity>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<List<Activity>> getRecent(int limit) async {
    return _datasource.getRecent(limit);
  }

  @override
  Future<void> purgeOlderThan(DateTime date) async {
    return _datasource.purgeOlderThan(date);
  }
}
