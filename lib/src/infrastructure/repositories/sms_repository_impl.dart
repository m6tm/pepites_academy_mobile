import '../../application/services/sync_service.dart';
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
/// Delegue les operations au datasource local et appelle l'API backend NEXAH.
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
    // Enregistrer d'abord localement avec statut en attente
    final pendingMessage = message.copyWith(statut: StatutEnvoi.enAttente);
    await _datasource.add(pendingMessage);

    // Tenter l'envoi via l'API backend
    final result = await _sendViaApi(pendingMessage);

    // Mettre a jour le message avec le resultat
    final updatedMessage = pendingMessage.copyWith(
      statut: result.succes ? StatutEnvoi.envoye : StatutEnvoi.echec,
    );

    // Mettre a jour le datasource local
    await _datasource.update(updatedMessage);

    // Enregistrer l'operation de synchronisation
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.smsMessage,
      entityId: updatedMessage.id,
      operationType: SyncOperationType.create,
      data: updatedMessage.toJson(),
    );

    return updatedMessage;
  }

  /// Envoie le SMS via l'API backend NEXAH.
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
          'destinataires': message.destinataires
              .map((d) => d.toJson())
              .toList(),
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

  /// Obtient le credit SMS restant depuis l'API backend.
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
