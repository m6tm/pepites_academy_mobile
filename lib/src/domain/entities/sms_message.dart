/// Statut d'envoi d'un SMS.
enum StatutEnvoi { enAttente, envoye, echec }

/// Type de destinataire pour un SMS.
enum TypeDestinataire { academicien, encadreur, mixte }

/// Represente un destinataire resolu avec son nom et numero.
class Destinataire {
  final String id;
  final String nom;
  final String telephone;
  final TypeDestinataire type;

  const Destinataire({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'telephone': telephone,
    'type': type.name,
  };

  factory Destinataire.fromJson(Map<String, dynamic> json) => Destinataire(
    id: json['id'] as String,
    nom: json['nom'] as String,
    telephone: json['telephone'] as String,
    type: TypeDestinataire.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => TypeDestinataire.academicien,
    ),
  );
}

/// Represente un SMS envoye depuis l'application.
class SmsMessage {
  /// Identifiant unique du message.
  final String id;

  /// Contenu du message.
  final String contenu;

  /// Liste des destinataires resolus.
  final List<Destinataire> destinataires;

  /// Date et heure de l'envoi.
  final DateTime dateEnvoi;

  /// Statut de l'envoi.
  final StatutEnvoi statut;

  /// Nombre de SMS (1 SMS = 160 caracteres, au-dela on decoupe).
  int get nbSms => (contenu.length / 160).ceil().clamp(1, 99);

  const SmsMessage({
    required this.id,
    required this.contenu,
    required this.destinataires,
    required this.dateEnvoi,
    this.statut = StatutEnvoi.enAttente,
  });

  /// Copie avec modification.
  SmsMessage copyWith({
    String? id,
    String? contenu,
    List<Destinataire>? destinataires,
    DateTime? dateEnvoi,
    StatutEnvoi? statut,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      contenu: contenu ?? this.contenu,
      destinataires: destinataires ?? this.destinataires,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      statut: statut ?? this.statut,
    );
  }

  /// Serialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() => {
    'id': id,
    'contenu': contenu,
    'destinataires': destinataires.map((d) => d.toJson()).toList(),
    'dateEnvoi': dateEnvoi.toIso8601String(),
    'statut': statut.name,
  };

  /// Deserialisation depuis Map.
  factory SmsMessage.fromJson(Map<String, dynamic> json) => SmsMessage(
    id: json['id'] as String,
    contenu: json['contenu'] as String,
    destinataires: (json['destinataires'] as List<dynamic>)
        .map((d) => Destinataire.fromJson(d as Map<String, dynamic>))
        .toList(),
    dateEnvoi: DateTime.parse(json['dateEnvoi'] as String),
    statut: StatutEnvoi.values.firstWhere(
      (e) => e.name == json['statut'],
      orElse: () => StatutEnvoi.enAttente,
    ),
  );
}
