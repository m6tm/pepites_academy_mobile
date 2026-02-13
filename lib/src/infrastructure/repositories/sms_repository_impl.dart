import '../../domain/entities/sms_message.dart';
import '../../domain/repositories/sms_repository.dart';
import '../datasources/sms_local_datasource.dart';

/// Implementation locale du repository SMS.
/// Delegue les operations au datasource local.
class SmsRepositoryImpl implements SmsRepository {
  final SmsLocalDatasource _datasource;

  SmsRepositoryImpl(this._datasource);

  @override
  Future<SmsMessage> send(SmsMessage message) async {
    return _datasource.add(message);
  }

  @override
  Future<List<SmsMessage>> getHistory() async {
    return _datasource.getAll();
  }

  @override
  Future<void> delete(String id) async {
    return _datasource.delete(id);
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
