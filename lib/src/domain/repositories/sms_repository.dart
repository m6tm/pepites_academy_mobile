import '../entities/sms_message.dart';

/// Contrat pour la gestion des SMS.
abstract class SmsRepository {
  /// Envoie un nouveau message SMS.
  Future<SmsMessage> send(SmsMessage message);

  /// Récupère l'historique des messages envoyés.
  Future<List<SmsMessage>> getHistory();
}
