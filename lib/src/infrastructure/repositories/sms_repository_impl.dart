import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/events/sms_events.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/sms_message.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/sms_repository.dart';
import '../datasources/sms_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Resultat de l'envoi SMS via l'API NEXAH.
class SmsSendResult {
  final bool succes;
  final String message;
  final int? nbSucces;
  final int? nbEchecs;
  final String? erreur;
  final String? backendSmsId;

  const SmsSendResult({
    required this.succes,
    required this.message,
    this.nbSucces,
    this.nbEchecs,
    this.erreur,
    this.backendSmsId,
  });
}

/// Informations sur le credit SMS.
class SmsCreditInfo {
  final int credit;
  final String? accountExpDate;
  final String? balanceExpDate;

  const SmsCreditInfo({
    required this.credit,
    this.accountExpDate,
    this.balanceExpDate,
  });
}

/// Implementation locale du repository SMS.
class SmsRepositoryImpl implements SmsRepository {
  final SmsLocalDatasource _datasource;
  DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  final _historyCache = RepositoryCache<List<SmsMessage>>();
  final _statsCache = RepositoryCache<int>();

  SmsRepositoryImpl(this._datasource);

  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  @override
  Future<SmsMessage> send(SmsMessage message) async {
    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      final pendingMessage = message.copyWith(statut: StatutEnvoi.enAttente);
      await _datasource.add(pendingMessage);
      await _syncService?.enqueueOperation(
        entityType: SyncEntityType.smsMessage,
        entityId: pendingMessage.id,
        operationType: SyncOperationType.create,
        data: pendingMessage.toJson(),
      );
      _historyCache.invalidateByTag('sms');
      _invalidationRegistry?.markInvalidated<SmsMessageSentEvent>();
      _eventBus?.emit(SmsMessageSentEvent(pendingMessage.id));
      return pendingMessage;
    }

    final pendingMessage = message.copyWith(statut: StatutEnvoi.enAttente);
    await _datasource.add(pendingMessage);

    final result = await _sendViaApi(pendingMessage);

    final updatedMessage = pendingMessage.copyWith(
      statut: result.succes ? StatutEnvoi.envoye : StatutEnvoi.echec,
    );

    await _datasource.update(updatedMessage);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.smsMessage,
      entityId: updatedMessage.id,
      operationType: SyncOperationType.create,
      data: updatedMessage.toJson(),
    );

    _historyCache.invalidateByTag('sms');
    _statsCache.invalidateByTag('sms');
    _invalidationRegistry?.markInvalidated<SmsMessageSentEvent>();
    _eventBus?.emit(SmsMessageSentEvent(updatedMessage.id));
    return updatedMessage;
  }

  Future<SmsSendResult> _sendViaApi(SmsMessage message) async {
    final client = _dioClient;
    if (client == null) {
      return const SmsSendResult(
        succes: false,
        message: 'Client HTTP non initialise',
        erreur: 'Client HTTP non initialise',
      );
    }

    try {
      final response = await client.post<dynamic>(
        ApiEndpoints.sms,
        data: {
          'contenu': message.contenu,
          'destinataires': message.destinataires.map((d) => d.toJson()).toList(),
        },
      );

      return response.fold(
        (failure) {
          return SmsSendResult(
            succes: false,
            message: failure.message ?? 'Erreur inconnue',
            erreur: failure.message,
          );
        },
        (data) {
          final responseData = data as Map<String, dynamic>;
          final succes = responseData['message'] != null;
          final smsData = responseData['sms'] as Map<String, dynamic>?;

          return SmsSendResult(
            succes: succes,
            message: responseData['message']?.toString() ?? 'SMS envoye',
            nbSucces: responseData['nb_succes'] as int?,
            nbEchecs: responseData['nb_echecs'] as int?,
            backendSmsId: smsData?['id']?.toString(),
          );
        },
      );
    } catch (e) {
      return SmsSendResult(
        succes: false,
        message: 'Erreur lors de l\'envoi: $e',
        erreur: e.toString(),
      );
    }
  }

  Future<SmsCreditInfo?> getCredit() async {
    final client = _dioClient;
    if (client == null) return null;

    try {
      final response = await client.get<dynamic>('${ApiEndpoints.sms}/credit');

      return response.fold((failure) => null, (data) {
        final responseData = data as Map<String, dynamic>;
        return SmsCreditInfo(
          credit: responseData['credit'] as int? ?? 0,
          accountExpDate: responseData['accountexpdate']?.toString(),
          balanceExpDate: responseData['balanceexpdate']?.toString(),
        );
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<SmsMessage>> getHistory() async {
    const key = 'history';
    final cached = _historyCache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getAll();
    _historyCache.set(key, result, ttl: CacheTtl.activities, tags: {'sms'});
    return result;
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    _historyCache.invalidateByTag('sms');
    _statsCache.invalidateByTag('sms');
    _invalidationRegistry?.markInvalidated<SmsMessageDeletedEvent>();
    _eventBus?.emit(SmsMessageDeletedEvent(id));
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.smsMessage,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<int> getTotalEnvoyes() async {
    const key = 'total_envoyes';
    final cached = _statsCache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getTotalEnvoyes();
    _statsCache.set(key, result, ttl: CacheTtl.activities, tags: {'sms'});
    return result;
  }

  @override
  Future<int> getEnvoyesCeMois() async {
    const key = 'envoyes_ce_mois';
    final cached = _statsCache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getEnvoyesCeMois();
    _statsCache.set(key, result, ttl: CacheTtl.activities, tags: {'sms'});
    return result;
  }

  @override
  Future<int> getEnEchec() async {
    const key = 'en_echec';
    final cached = _statsCache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getEnEchec();
    _statsCache.set(key, result, ttl: CacheTtl.activities, tags: {'sms'});
    return result;
  }

  Future<void> upsertAllFromRemote(List<SmsMessage> remoteList) async {
    final local = _datasource.getAll();
    final localMap = {for (final m in local) m.id: m};
    for (final remote in remoteList) {
      localMap[remote.id] = remote;
    }
    await _datasource.saveAll(localMap.values.toList());
  }

  Future<bool> syncFromApi() async {
    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return false;
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.sms);

      return await result.fold(
        (failure) {
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
          _historyCache.invalidateByTag('sms');
          _statsCache.invalidateByTag('sms');
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

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

  void clearCache() {
    _historyCache.clear();
    _statsCache.clear();
  }
}
