/// Entité representant une session utilisateur active.
class UserSession {
  /// Identifiant unique de la session.
  final String id;

  /// Description de l'appareil.
  final String? appareil;

  /// Adresse IP de la session.
  final String? adresseIp;

  /// Date de creation de la session.
  final DateTime dateCreation;

  /// Date de derniere activite.
  final DateTime derniereActivite;

  /// Indique si c'est la session courante.
  final bool estCourante;

  const UserSession({
    required this.id,
    this.appareil,
    this.adresseIp,
    required this.dateCreation,
    required this.derniereActivite,
    this.estCourante = false,
  });

  /// Cree une instance depuis un JSON.
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as String? ?? '',
      appareil: json['appareil'] as String?,
      adresseIp: json['adresse_ip'] as String?,
      dateCreation: DateTime.parse(
        json['date_creation'] as String? ?? DateTime.now().toIso8601String(),
      ),
      derniereActivite: DateTime.parse(
        json['derniere_activite'] as String? ?? DateTime.now().toIso8601String(),
      ),
      estCourante: json['est_courante'] as bool? ?? false,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appareil': appareil,
      'adresse_ip': adresseIp,
      'date_creation': dateCreation.toIso8601String(),
      'derniere_activite': derniereActivite.toIso8601String(),
      'est_courante': estCourante,
    };
  }
}
