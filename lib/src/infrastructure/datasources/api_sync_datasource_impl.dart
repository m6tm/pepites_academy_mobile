import 'dart:convert';
import 'dart:io';

import '../../domain/entities/sync_operation.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'api_sync_datasource.dart';

/// Implémentation réelle de [ApiSyncDatasource] utilisant [DioClient].
/// Route les opérations de synchronisation vers les endpoints REST appropriés.
class ApiSyncDatasourceImpl implements ApiSyncDatasource {
  final DioClient _dioClient;

  ApiSyncDatasourceImpl(this._dioClient);

  @override
  Future<SyncResult> pushOperation(SyncOperation operation) async {
    final endpoint = _getEndpointForEntity(operation.entityType);
    final payload = json.decode(operation.payload) as Map<String, dynamic>;

    if (operation.entityType == SyncEntityType.notification) {
      return _handleNotificationOperation(operation, endpoint, payload);
    }

    if (operation.entityType == SyncEntityType.fcmToken) {
      return _handleFcmTokenOperation(operation, endpoint, payload);
    }

    switch (operation.operationType) {
      case SyncOperationType.create:
        return _handleCreate(endpoint, payload);
      case SyncOperationType.update:
        return _handleUpdate(endpoint, operation.entityId, payload);
      case SyncOperationType.delete:
        return _handleDelete(endpoint, operation.entityId);
    }
  }

  Future<SyncResult> _handleNotificationOperation(
    SyncOperation operation,
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final action = payload['action']?.toString();

    try {
      if (operation.operationType == SyncOperationType.update) {
        if (action == 'mark_read') {
          final result = await _dioClient.patch<dynamic>(
            '$endpoint/${operation.entityId}/lire',
          );
          return result.fold(
            (failure) => SyncResult(
              success: false,
              errorMessage:
                  failure.message ?? 'Erreur lors du marquage comme lu',
              statusCode: failure.statusCode,
            ),
            (response) => SyncResult(
              success: true,
              serverResponse: response as Map<String, dynamic>?,
            ),
          );
        }

        if (action == 'mark_all_read') {
          final result = await _dioClient.patch<dynamic>('$endpoint/lire-tout');
          return result.fold(
            (failure) => SyncResult(
              success: false,
              errorMessage: failure.message ?? 'Erreur lors du marquage global',
              statusCode: failure.statusCode,
            ),
            (response) => SyncResult(
              success: true,
              serverResponse: response as Map<String, dynamic>?,
            ),
          );
        }
      }

      if (operation.operationType == SyncOperationType.delete) {
        if (action == 'delete_read') {
          final result = await _dioClient.delete<dynamic>('$endpoint/lues');
          return result.fold(
            (failure) => SyncResult(
              success: false,
              errorMessage:
                  failure.message ?? 'Erreur lors de la suppression des lues',
              statusCode: failure.statusCode,
            ),
            (response) => SyncResult(
              success: true,
              serverResponse: response as Map<String, dynamic>?,
            ),
          );
        }

        // Suppression d'une notification par id
        final result = await _dioClient.delete<dynamic>(
          '$endpoint/${operation.entityId}',
        );
        return result.fold(
          (failure) => SyncResult(
            success: false,
            errorMessage: failure.message ?? 'Erreur lors de la suppression',
            statusCode: failure.statusCode,
          ),
          (response) => SyncResult(
            success: true,
            serverResponse: response as Map<String, dynamic>?,
          ),
        );
      }

      return SyncResult(
        success: false,
        errorMessage: 'Operation notification non supportee',
      );
    } on SocketException {
      return SyncResult(success: false, errorMessage: 'Pas de connexion');
    } catch (e) {
      return SyncResult(success: false, errorMessage: 'Exception: $e');
    }
  }

  /// Gère l'envoi du token FCM au serveur.
  Future<SyncResult> _handleFcmTokenOperation(
    SyncOperation operation,
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      // Pour le token FCM, on utilise toujours POST (create/update)
      final result = await _dioClient.post(endpoint, data: payload);

      return result.fold(
        (failure) => SyncResult(
          success: false,
          errorMessage:
              failure.message ?? 'Erreur lors de l\'envoi du token FCM',
          statusCode: failure.statusCode,
        ),
        (response) => SyncResult(
          success: true,
          serverResponse: response as Map<String, dynamic>?,
        ),
      );
    } catch (e) {
      return SyncResult(success: false, errorMessage: 'Exception: $e');
    }
  }

  /// Gère la création d'une entité via POST.
  Future<SyncResult> _handleCreate(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      final data = _transformPayloadForApi(payload, isCreate: true);
      // ignore: avoid_print
      print('[ApiSync] POST $endpoint avec ${data.keys.toList()}');
      final result = await _dioClient.post(endpoint, data: data);

      return result.fold(
        (failure) => SyncResult(
          success: false,
          errorMessage: failure.message ?? 'Erreur lors de la création',
          statusCode: failure.statusCode,
        ),
        (response) => SyncResult(
          success: true,
          serverResponse: response as Map<String, dynamic>?,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ApiSync] Exception lors de la création: $e');
      return SyncResult(success: false, errorMessage: 'Exception: $e');
    }
  }

  /// Gère la mise à jour d'une entité via PUT.
  Future<SyncResult> _handleUpdate(
    String endpoint,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    final data = _transformPayloadForApi(payload);
    final result = await _dioClient.put('$endpoint/$entityId', data: data);

    return result.fold(
      (failure) => SyncResult(
        success: false,
        errorMessage: failure.message ?? 'Erreur lors de la mise à jour',
        statusCode: failure.statusCode,
      ),
      (response) => SyncResult(
        success: true,
        serverResponse: response as Map<String, dynamic>?,
      ),
    );
  }

  /// Gère la suppression d'une entité via DELETE.
  Future<SyncResult> _handleDelete(String endpoint, String entityId) async {
    final result = await _dioClient.delete('$endpoint/$entityId');

    return result.fold(
      (failure) => SyncResult(
        success: false,
        errorMessage: failure.message ?? 'Erreur lors de la suppression',
        statusCode: failure.statusCode,
      ),
      (response) => SyncResult(
        success: true,
        serverResponse: response as Map<String, dynamic>?,
      ),
    );
  }

  /// Retourne l'endpoint REST correspondant au type d'entité.
  String _getEndpointForEntity(SyncEntityType entityType) {
    switch (entityType) {
      case SyncEntityType.encadreur:
        return ApiEndpoints.encadreurs;
      case SyncEntityType.academicien:
        return ApiEndpoints.academiciens;
      case SyncEntityType.seance:
        return ApiEndpoints.seances;
      case SyncEntityType.atelier:
        return ApiEndpoints.ateliers;
      case SyncEntityType.annotation:
        return ApiEndpoints.annotations;
      case SyncEntityType.presence:
        return ApiEndpoints.presences;
      case SyncEntityType.bulletin:
        return ApiEndpoints.bulletins;
      case SyncEntityType.posteFootball:
        return ApiEndpoints.postesFootball;
      case SyncEntityType.niveauScolaire:
        return ApiEndpoints.niveauxScolaires;
      case SyncEntityType.smsMessage:
        return '/sms';
      case SyncEntityType.notification:
        return ApiEndpoints.notifications;
      case SyncEntityType.fcmToken:
        return ApiEndpoints.fcmToken;
      case SyncEntityType.dashboard:
        return ApiEndpoints.dashboardStats;
      case SyncEntityType.season:
        return ApiEndpoints.seasons;
    }
  }

  /// Transforme le payload mobile vers le format attendu par l'API backend.
  /// Convertit les noms de champs camelCase vers snake_case.
  /// Les URLs sont envoyees directement (upload via /v1/upload/photo).
  Map<String, dynamic> _transformPayloadForApi(
    Map<String, dynamic> payload, {
    bool isCreate = false,
  }) {
    final transformed = <String, dynamic>{};

    for (final entry in payload.entries) {
      final key = _camelToSnake(entry.key);
      var value = entry.value;

      // Conversion des dates ISO en format date uniquement (YYYY-MM-DD)
      if ((key == 'date_naissance' || key == 'date') &&
          value is String &&
          value.contains('T')) {
        value = value.split('T').first;
      }

      // Ne pas envoyer les champs calculés ou gérés par le backend
      // Pour les créations, exclure aussi 'id' et 'statut' (gérés par le backend)
      // Ne pas envoyer les champs calculés uniquement
      if (key == 'nb_seances_dirigees' ||
          key == 'nb_annotations' ||
          key == 'nb_presents' ||
          key == 'nb_ateliers' ||
          key == 'academicien_ids' ||
          key == 'atelier_ids') {
        continue;
      }

      transformed[key] = value;
    }

    return transformed;
  }

  /// Convertit une chaîne camelCase en snake_case.
  String _camelToSnake(String input) {
    return input.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  @override
  Future<Map<String, dynamic>?> fetchEntity(
    String entityType,
    String entityId,
  ) async {
    final endpoint = _getEndpointForEntityName(entityType);
    final result = await _dioClient.get('$endpoint/$entityId');

    return result.fold(
      (failure) => null,
      (data) => data as Map<String, dynamic>?,
    );
  }

  @override
  Future<List<Map<String, dynamic>>?> fetchAll(String endpoint) async {
    try {
      final result = await _dioClient.get<dynamic>(endpoint);

      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[ApiSync] fetchAll $endpoint échec: ${failure.message}');
          return null;
        },
        (data) {
          // L'API peut retourner une List directe ou un Map avec les données
          if (data is List) {
            return data.whereType<Map<String, dynamic>>().toList();
          }
          if (data is Map<String, dynamic>) {
            // Cherche la première valeur qui est une liste
            for (final value in data.values) {
              if (value is List) {
                return value.whereType<Map<String, dynamic>>().toList();
              }
            }
          }
          return null;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ApiSync] fetchAll $endpoint exception: $e');
      return null;
    }
  }

  /// Retourne l'endpoint REST correspondant au nom d'entité (string).
  String _getEndpointForEntityName(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'encadreur':
        return ApiEndpoints.encadreurs;
      case 'academicien':
        return ApiEndpoints.academiciens;
      case 'seance':
        return ApiEndpoints.seances;
      case 'atelier':
        return ApiEndpoints.ateliers;
      case 'annotation':
        return ApiEndpoints.annotations;
      case 'presence':
        return ApiEndpoints.presences;
      case 'bulletin':
        return ApiEndpoints.bulletins;
      default:
        return '/${entityType.toLowerCase()}s';
    }
  }

  @override
  Future<bool> isServerReachable() async {
    try {
      final result = await _dioClient.get(ApiEndpoints.health);
      return result.isRight();
    } catch (_) {
      return false;
    }
  }
}
