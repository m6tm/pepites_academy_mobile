import '../entities/sms_message.dart';

/// Contrat pour la gestion des SMS.
abstract class SmsRepository {
  /// Envoie un nouveau message SMS.
  Future<SmsMessage> send(SmsMessage message);

  /// Recupere l'historique des messages envoyes.
  Future<List<SmsMessage>> getHistory();

  /// Supprime un message de l'historique.
  Future<void> delete(String id);

  /// Recupere le nombre total de SMS envoyes.
  Future<int> getTotalEnvoyes();

  /// Recupere le nombre de SMS envoyes ce mois-ci.
  Future<int> getEnvoyesCeMois();

  /// Recupere le nombre de SMS en echec.
  Future<int> getEnEchec();
}
