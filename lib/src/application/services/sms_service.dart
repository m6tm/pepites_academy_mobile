import '../../domain/entities/sms_message.dart';
import '../../infrastructure/repositories/sms_repository_impl.dart';
import 'activity_service.dart';

/// Service applicatif gerant la logique metier des SMS.
/// Permet de composer, envoyer et consulter l'historique des messages.
class SmsService {
  final SmsRepositoryImpl _smsRepository;
  ActivityService? _activityService;

  SmsService({required SmsRepositoryImpl smsRepository})
    : _smsRepository = smsRepository;

  /// Injecte le service d'activites.
  void setActivityService(ActivityService service) {
    _activityService = service;
  }

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

    final sent = await _smsRepository.send(message);
    final apercu = contenu.length > 40
        ? '${contenu.substring(0, 40)}...'
        : contenu;
    await _activityService?.enregistrerSmsEnvoye(
      destinataires.length,
      apercu,
      sent.id,
    );
    return sent;
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
