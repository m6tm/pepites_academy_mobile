import '../../application/services/sync_service.dart';
import '../../domain/entities/sms_message.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/sms_repository.dart';
import '../datasources/sms_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation locale du repository SMS.
/// Delegue les operations au datasource local.
class SmsRepositoryImpl implements SmsRepository {
  final SmsLocalDatasource _datasource;
  DioClient? _dioClient;
  SyncService? _syncService;

  SmsRepositoryImpl(this._datasource);

  /// Injecte le client HTTP pour les appels API.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

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

  /// Fusionne une liste de donnees distantes dans le cache local
  /// sans declencher d'operation de synchronisation vers le serveur.
  Future<void> upsertAllFromRemote(List<SmsMessage> remoteList) async {
    final local = _datasource.getAll();
    final localMap = {for (final m in local) m.id: m};
    for (final remote in remoteList) {
      localMap[remote.id] = remote;
    }
    await _datasource.saveAll(localMap.values.toList());
  }

  /// Synchronise les SMS depuis le backend vers le cache local.
  /// Retourne true si la synchronisation a reussi.
  Future<bool> syncFromApi() async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.sms);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[SmsRepo] Erreur sync: ${failure.message}');
          return false;
        },
        (data) async {
          final List<dynamic> rawList;
          if (data is List) {
            rawList = data;
          } else if (data is Map<String, dynamic>) {
            rawList = data.values.whereType<List>().expand((e) => e).toList();
          } else {
            return false;
          }

          final messages = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => _parseSmsMessage(map))
              .where((m) => m.id.isNotEmpty)
              .toList();

          await upsertAllFromRemote(messages);
          // ignore: avoid_print
          print('[SmsRepo] Synced ${messages.length} messages from backend');
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[SmsRepo] Exception sync: $e');
      return false;
    }
  }

  /// Parse un SMS depuis les donnees du backend.
  SmsMessage _parseSmsMessage(Map<String, dynamic> map) {
    final destinatairesData = map['destinataires'] as List<dynamic>? ?? [];
    final destinataires = destinatairesData
        .whereType<Map<String, dynamic>>()
        .map((d) => Destinataire.fromJson(d))
        .toList();

    return SmsMessage(
      id: (map['id']?.toString() ?? ''),
      contenu: (map['contenu'] as String?) ?? '',
      destinataires: destinataires,
      dateEnvoi:
          DateTime.tryParse(
            (map['date_envoi'] as String?) ??
                (map['dateEnvoi'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      statut: StatutEnvoi.values.firstWhere(
        (e) => e.name == (map['statut'] as String? ?? 'enAttente'),
        orElse: () => StatutEnvoi.enAttente,
      ),
    );
  }
}
