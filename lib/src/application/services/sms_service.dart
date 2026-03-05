import '../../domain/entities/sms_message.dart';
import '../../infrastructure/repositories/sms_repository_impl.dart';
import 'activity_service.dart';

/// Resultat de l'envoi SMS via l'API NEXAH.
class SmsEnvoiResult {
  final bool succes;
  final String message;
  final int? nbSucces;
  final int? nbEchecs;
  final String? erreur;

  const SmsEnvoiResult({
    required this.succes,
    required this.message,
    this.nbSucces,
    this.nbEchecs,
    this.erreur,
  });
}

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

  /// Envoie un SMS a une liste de destinataires via l'API NEXAH.
  Future<SmsEnvoiResult> envoyerSms({
    required String contenu,
    required List<Destinataire> destinataires,
  }) async {
    final message = SmsMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contenu: contenu,
      destinataires: destinataires,
      dateEnvoi: DateTime.now(),
      statut: StatutEnvoi.enAttente,
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

    return SmsEnvoiResult(
      succes: sent.statut == StatutEnvoi.envoye,
      message: sent.statut == StatutEnvoi.envoye
          ? 'SMS envoye a ${destinataires.length} destinataire(s)'
          : 'Echec de l\'envoi du SMS',
    );
  }

  /// Recupere le credit SMS restant depuis l'API NEXAH.
  Future<SmsCreditInfo?> getCredit() async {
    return _smsRepository.getCredit();
  }

  /// Recupere l'historique complet des SMS.
  /// Tente d'abord de synchroniser depuis le backend, puis retourne le cache local.
  Future<List<SmsMessage>> getHistorique() async {
    await _smsRepository.syncFromApi();
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
