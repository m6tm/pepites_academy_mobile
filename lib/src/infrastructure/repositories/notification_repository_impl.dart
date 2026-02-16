import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';

/// Implementation locale du repository de notifications.
/// Delegue les operations au datasource local.
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDatasource _datasource;

  NotificationRepositoryImpl(this._datasource);

  @override
  Future<List<NotificationItem>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<List<NotificationItem>> getByRole(String role) async {
    return _datasource.getByRole(role);
  }

  @override
  Future<List<NotificationItem>> getNonLues(String role) async {
    return _datasource.getNonLues(role);
  }

  @override
  Future<NotificationItem> add(NotificationItem notification) async {
    return _datasource.add(notification);
  }

  @override
  Future<void> marquerCommeLue(String id) async {
    return _datasource.marquerCommeLue(id);
  }

  @override
  Future<void> marquerToutesCommeLues(String role) async {
    return _datasource.marquerToutesCommeLues(role);
  }

  @override
  Future<void> delete(String id) async {
    return _datasource.delete(id);
  }

  @override
  Future<void> supprimerLues(String role) async {
    return _datasource.supprimerLues(role);
  }

  @override
  Future<int> compterNonLues(String role) async {
    return _datasource.compterNonLues(role);
  }
}
