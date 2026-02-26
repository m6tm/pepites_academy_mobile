import '../../domain/entities/notification_item.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../application/services/sync_service.dart';
import '../datasources/notification_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation locale du repository de notifications.
/// Delegue les operations au datasource local.
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDatasource _datasource;
  final DioClient? _dioClient;
  SyncService? _syncService;

  NotificationRepositoryImpl(this._datasource, {DioClient? dioClient})
    : _dioClient = dioClient;

  void setSyncService(SyncService service) {
    _syncService = service;
  }

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
    await _datasource.marquerCommeLue(id);

    final client = _dioClient;
    if (client == null) {
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.notification,
        entityId: id,
        operationType: SyncOperationType.update,
        data: {'action': 'mark_read'},
      );
      return;
    }

    final result = await client.patch<dynamic>(
      '${ApiEndpoints.notifications}/$id/lire',
    );

    await result.fold((failure) async {
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.notification,
        entityId: id,
        operationType: SyncOperationType.update,
        data: {'action': 'mark_read'},
      );
    }, (_) async {});
  }

  @override
  Future<void> marquerToutesCommeLues(String role) async {
    await _datasource.marquerToutesCommeLues(role);

    final client = _dioClient;
    if (client == null) {
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.notification,
        entityId: 'all',
        operationType: SyncOperationType.update,
        data: {'action': 'mark_all_read'},
      );
      return;
    }

    final result = await client.patch<dynamic>(
      '${ApiEndpoints.notifications}/lire-tout',
    );

    await result.fold((failure) async {
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.notification,
        entityId: 'all',
        operationType: SyncOperationType.update,
        data: {'action': 'mark_all_read'},
      );
    }, (_) async {});
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);

    final client = _dioClient;
    if (client == null) {
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.notification,
        entityId: id,
        operationType: SyncOperationType.delete,
        data: {'action': 'delete'},
      );
      return;
    }

    final result = await client.delete<dynamic>(
      '${ApiEndpoints.notifications}/$id',
    );

    await result.fold((failure) async {
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.notification,
        entityId: id,
        operationType: SyncOperationType.delete,
        data: {'action': 'delete'},
      );
    }, (_) async {});
  }

  @override
  Future<void> supprimerLues(String role) async {
    await _datasource.supprimerLues(role);

    final client = _dioClient;
    if (client == null) {
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.notification,
        entityId: 'lues',
        operationType: SyncOperationType.delete,
        data: {'action': 'delete_read'},
      );
      return;
    }

    final result = await client.delete<dynamic>(
      '${ApiEndpoints.notifications}/lues',
    );

    await result.fold((failure) async {
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.notification,
        entityId: 'lues',
        operationType: SyncOperationType.delete,
        data: {'action': 'delete_read'},
      );
    }, (_) async {});
  }

  @override
  Future<int> compterNonLues(String role) async {
    return _datasource.compterNonLues(role);
  }

  /// Synchronise les notifications depuis le backend vers le cache local.
  /// Retourne la liste locale mise a jour.
  Future<List<NotificationItem>> syncFromApi({bool nonLuesOnly = false}) async {
    final client = _dioClient;
    if (client == null) return _datasource.getAll();

    final result = await client.get<dynamic>(
      ApiEndpoints.notifications,
      queryParameters: nonLuesOnly ? {'non_lues': true} : null,
    );

    return await result.fold(
      (failure) async {
        return _datasource.getAll();
      },
      (data) async {
        if (data is! List) return _datasource.getAll();

        final localById = {for (final n in _datasource.getAll()) n.id: n};

        NotificationItem? mapItem(dynamic raw) {
          if (raw is! Map) return null;
          final json = raw.cast<String, dynamic>();
          try {
            final id = (json['id'] ?? '').toString();
            final titre = (json['titre'] ?? '').toString();
            final description = (json['description'] ?? '').toString();
            final typeStr = (json['type'] ?? 'systeme').toString();
            final prioriteStr = (json['priorite'] ?? 'normale').toString();
            final dateStr =
                (json['date_creation'] ?? json['dateCreation'] ?? '')
                    .toString();
            final estLue = json['est_lue'] as bool?;
            final referenceId = json['reference_id']?.toString();
            final cibleRole = (json['cible_role'] ?? 'tous').toString();

            if (id.isEmpty || titre.isEmpty || dateStr.isEmpty) return null;

            final type = NotificationType.values.firstWhere(
              (e) => e.name == typeStr,
              orElse: () => NotificationType.systeme,
            );
            final priorite = NotificationPriority.values.firstWhere(
              (e) => e.name == prioriteStr,
              orElse: () => NotificationPriority.normale,
            );

            return NotificationItem(
              id: id,
              titre: titre,
              description: description,
              type: type,
              priorite: priorite,
              dateCreation: DateTime.parse(dateStr),
              estLue: estLue ?? false,
              referenceId: referenceId,
              cibleRole: cibleRole,
            );
          } catch (_) {
            return null;
          }
        }

        final items = <NotificationItem>[];
        for (final raw in data) {
          final item = mapItem(raw);
          if (item != null) {
            final local = localById[item.id];
            items.add(
              item.copyWith(estLue: item.estLue || (local?.estLue ?? false)),
            );
          }
        }

        await _datasource.replaceAll(items);
        return _datasource.getAll();
      },
    );
  }
}
