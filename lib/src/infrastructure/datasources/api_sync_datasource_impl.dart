import '../../domain/entities/sync_operation.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'api_sync_datasource.dart';

/// Implémentation réelle de [ApiSyncDatasource] utilisant [DioClient].
class ApiSyncDatasourceImpl implements ApiSyncDatasource {
  final DioClient _dioClient;

  ApiSyncDatasourceImpl(this._dioClient);

  @override
  Future<SyncResult> pushOperation(SyncOperation operation) async {
    final result = await _dioClient.post(
      ApiEndpoints.sync,
      data: operation.toJson(),
    );

    return result.fold(
      (failure) => SyncResult(
        success: false,
        errorMessage: failure.message ?? 'Erreur lors de la synchronisation',
      ),
      (data) => SyncResult(
        success: true,
        serverResponse: data as Map<String, dynamic>?,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> fetchEntity(
    String entityType,
    String entityId,
  ) async {
    final result = await _dioClient.get(
      '/${entityType.toLowerCase()}s/$entityId',
    );

    return result.fold(
      (failure) => null,
      (data) => data as Map<String, dynamic>?,
    );
  }

  @override
  Future<bool> isServerReachable() async {
    try {
      final result = await _dioClient.get('/health');
      return result.isRight();
    } catch (_) {
      return false;
    }
  }
}
