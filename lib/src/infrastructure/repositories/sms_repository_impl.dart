import '../../application/services/sync_service.dart';
import '../../domain/entities/sms_message.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/sms_repository.dart';
import '../datasources/sms_local_datasource.dart';

/// Implementation locale du repository SMS.
/// Delegue les operations au datasource local.
class SmsRepositoryImpl implements SmsRepository {
  final SmsLocalDatasource _datasource;
  SyncService? _syncService;

  SmsRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<SmsMessage> send(SmsMessage message) async {
    final sent = await _datasource.add(message);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.smsMessage,
      entityId: sent.id,
      operationType: SyncOperationType.create,
      data: sent.toJson(),
    );
    return sent;
  }

  @override
  Future<List<SmsMessage>> getHistory() async {
    return _datasource.getAll();
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.smsMessage,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<int> getTotalEnvoyes() async {
    return _datasource.getTotalEnvoyes();
  }

  @override
  Future<int> getEnvoyesCeMois() async {
    return _datasource.getEnvoyesCeMois();
  }

  @override
  Future<int> getEnEchec() async {
    return _datasource.getEnEchec();
  }
}
