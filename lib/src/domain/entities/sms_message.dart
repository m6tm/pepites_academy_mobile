/// Statut d'envoi d'un SMS.
enum StatutEnvoi { enAttente, envoye, echec }

/// Représente un SMS envoyé depuis l'application.
class SmsMessage {
  /// Identifiant unique du message.
  final String id;

  /// Contenu du message.
  final String contenu;

  /// Liste des identifiants des destinataires (Académiciens ou Encadreurs).
  final List<String> destinataireIds;

  /// Date et heure de l'envoi.
  final DateTime dateEnvoi;

  /// Statut de l'envoi.
  final StatutEnvoi statut;

  const SmsMessage({
    required this.id,
    required this.contenu,
    required this.destinataireIds,
    required this.dateEnvoi,
    this.statut = StatutEnvoi.enAttente,
  });
}
