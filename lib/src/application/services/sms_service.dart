import '../../domain/entities/sms_message.dart';
import '../../infrastructure/repositories/sms_repository_impl.dart';

/// Service applicatif gerant la logique metier des SMS.
/// Permet de composer, envoyer et consulter l'historique des messages.
class SmsService {
  final SmsRepositoryImpl _smsRepository;

  SmsService({required SmsRepositoryImpl smsRepository})
      : _smsRepository = smsRepository;

  /// Envoie un SMS a une liste de destinataires.
  /// Simule l'appel API backend et persiste dans l'historique.
  Future<SmsMessage> envoyerSms({
    required String contenu,
    required List<Destinataire> destinataires,
  }) async {
    final message = SmsMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contenu: contenu,
      destinataires: destinataires,
      dateEnvoi: DateTime.now(),
      statut: StatutEnvoi.envoye,
    );

    return _smsRepository.send(message);
  }

  /// Recupere l'historique complet des SMS.
  Future<List<SmsMessage>> getHistorique() async {
    return _smsRepository.getHistory();
  }

  /// Supprime un SMS de l'historique.
  Future<void> supprimerSms(String id) async {
    return _smsRepository.delete(id);
  }

  /// Recupere les statistiques SMS.
  Future<Map<String, int>> getStatistiques() async {
    final totalEnvoyes = await _smsRepository.getTotalEnvoyes();
    final envoyesCeMois = await _smsRepository.getEnvoyesCeMois();
    final enEchec = await _smsRepository.getEnEchec();

    return {
      'totalEnvoyes': totalEnvoyes,
      'envoyesCeMois': envoyesCeMois,
      'enEchec': enEchec,
    };
  }
}
