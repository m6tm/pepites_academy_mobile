import 'package:shared_preferences/shared_preferences.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/events/notification_events.dart';
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
  final SharedPreferences _prefs;
  final DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;

  final _cache = RepositoryCache<List<NotificationItem>>();

  NotificationRepositoryImpl(
    this._datasource,
    this._prefs, {
    DioClient? dioClient,
  }) : _dioClient = dioClient;

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

  void _invalidateCache() {
    _cache.invalidateByTag('notifications');
  }

  @override
  Future<List<NotificationItem>> getAll() async {
    const key = 'all';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getAll();
    _cache.set(key, result, ttl: CacheTtl.notifications, tags: {'notifications'});
    return result;
  }

  @override
  Future<List<NotificationItem>> getByRole(String role) async {
    final key = 'role_$role';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getByRole(role);
    _cache.set(key, result, ttl: CacheTtl.notifications, tags: {'notifications', 'role_$role'});
    return result;
  }

  @override
  Future<List<NotificationItem>> getNonLues(String role) async {
    return _datasource.getNonLues(role);
  }

  @override
  Future<NotificationItem> add(NotificationItem notification) async {
    final created = await _datasource.add(notification);
    _invalidateCache();
    return created;
  }

  @override
  Future<void> marquerCommeLue(String id) async {
    await _datasource.marquerCommeLue(id);
    _invalidateCache();

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
    _invalidateCache();
    _invalidationRegistry?.markInvalidated<NotificationsReadEvent>();
    _eventBus?.emit(const NotificationsReadEvent());

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
    _invalidateCache();
    _invalidationRegistry?.markInvalidated<NotificationDeletedEvent>();
    _eventBus?.emit(NotificationDeletedEvent(id));

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
    _invalidateCache();
    _invalidationRegistry?.markInvalidated<NotificationsReadEvent>();
    _eventBus?.emit(const NotificationsReadEvent());

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
        _invalidateCache();
        return _datasource.getAll();
      },
    );
  }

  /// Envoie les preferences de notifications au backend.
  Future<bool> syncPreferencesToApi() async {
    final client = _dioClient;
    if (client == null) return false;

    final preferences = <String, dynamic>{
      'globales': _prefs.getBool('notif_globales') ?? true,
      'seances': _prefs.getBool('notif_seances') ?? true,
      'presences': _prefs.getBool('notif_presences') ?? true,
      'annotations': _prefs.getBool('notif_annotations') ?? true,
      'messages': _prefs.getBool('notif_messages') ?? true,
      'rappels': _prefs.getBool('notif_rappels') ?? true,
    };

    try {
      final result = await client.put<dynamic>(
        ApiEndpoints.notificationPreferences,
        data: preferences,
      );

      return result.fold((failure) {
        return false;
      }, (_) => true);
    } catch (e) {
      return false;
    }
  }

  /// Recupere les preferences de notifications depuis le backend.
  Future<bool> syncPreferencesFromApi() async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(
        ApiEndpoints.notificationPreferences,
      );

      return await result.fold(
        (failure) {
          return false;
        },
        (data) async {
          if (data is! Map<String, dynamic>) return false;

          final globales = data['globales'] as bool?;
          final seances = data['seances'] as bool?;
          final presences = data['presences'] as bool?;
          final annotations = data['annotations'] as bool?;
          final messages = data['messages'] as bool?;
          final rappels = data['rappels'] as bool?;

          if (globales != null) {
            await _prefs.setBool('notif_globales', globales);
          }
          if (seances != null) {
            await _prefs.setBool('notif_seances', seances);
          }
          if (presences != null) {
            await _prefs.setBool('notif_presences', presences);
          }
          if (annotations != null) {
            await _prefs.setBool('notif_annotations', annotations);
          }
          if (messages != null) {
            await _prefs.setBool('notif_messages', messages);
          }
          if (rappels != null) {
            await _prefs.setBool('notif_rappels', rappels);
          }

          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
