/// Entité representant une entree de l'historique des mots de passe.
class PasswordHistory {
  /// Identifiant unique de l'entree.
  final String id;

  /// Type de modification (changement, creation, reinitialisation).
  final String typeModification;

  /// Date de la modification.
  final DateTime dateModification;

  /// Adresse IP lors de la modification.
  final String? adresseIp;

  /// Appareil utilise pour la modification.
  final String? appareil;

  const PasswordHistory({
    required this.id,
    required this.typeModification,
    required this.dateModification,
    this.adresseIp,
    this.appareil,
  });

  /// Cree une instance depuis un JSON.
  factory PasswordHistory.fromJson(Map<String, dynamic> json) {
    return PasswordHistory(
      id: json['id'] as String? ?? '',
      typeModification: json['type_modification'] as String? ?? 'changement',
      dateModification: DateTime.parse(
        json['date_modification'] as String? ?? DateTime.now().toIso8601String(),
      ),
      adresseIp: json['adresse_ip'] as String?,
      appareil: json['appareil'] as String?,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_modification': typeModification,
      'date_modification': dateModification.toIso8601String(),
      'adresse_ip': adresseIp,
      'appareil': appareil,
    };
  }
}
