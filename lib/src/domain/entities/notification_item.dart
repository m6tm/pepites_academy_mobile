/// Types de notifications disponibles dans l'application.
enum NotificationType {
  seance,
  presence,
  inscription,
  sms,
  bulletin,
  systeme,
  rappel,
}

/// Priorite d'une notification.
enum NotificationPriority { basse, normale, haute, urgente }

/// Represente une notification destinee aux administrateurs et encadreurs.
class NotificationItem {
  /// Identifiant unique de la notification.
  final String id;

  /// Titre court de la notification.
  final String titre;

  /// Description detaillee de la notification.
  final String description;

  /// Type de la notification.
  final NotificationType type;

  /// Priorite de la notification.
  final NotificationPriority priorite;

  /// Date de creation de la notification.
  final DateTime dateCreation;

  /// Indique si la notification a ete lue.
  final bool estLue;

  /// Identifiant optionnel de la ressource associee (seance, academicien, etc.).
  final String? referenceId;

  /// Role cible de la notification ('admin', 'encadreur' ou 'tous').
  final String cibleRole;

  const NotificationItem({
    required this.id,
    required this.titre,
    required this.description,
    required this.type,
    this.priorite = NotificationPriority.normale,
    required this.dateCreation,
    this.estLue = false,
    this.referenceId,
    this.cibleRole = 'tous',
  });

  /// Copie avec modification.
  NotificationItem copyWith({
    String? id,
    String? titre,
    String? description,
    NotificationType? type,
    NotificationPriority? priorite,
    DateTime? dateCreation,
    bool? estLue,
    String? referenceId,
    String? cibleRole,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      type: type ?? this.type,
      priorite: priorite ?? this.priorite,
      dateCreation: dateCreation ?? this.dateCreation,
      estLue: estLue ?? this.estLue,
      referenceId: referenceId ?? this.referenceId,
      cibleRole: cibleRole ?? this.cibleRole,
    );
  }

  /// Serialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'description': description,
    'type': type.name,
    'priorite': priorite.name,
    'dateCreation': dateCreation.toIso8601String(),
    'estLue': estLue,
    'referenceId': referenceId,
    'cibleRole': cibleRole,
  };

  /// Deserialisation depuis Map.
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.systeme,
      ),
      priorite: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priorite'],
        orElse: () => NotificationPriority.normale,
      ),
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      estLue: json['estLue'] as bool? ?? false,
      referenceId: json['referenceId'] as String?,
      cibleRole: json['cibleRole'] as String? ?? 'tous',
    );
  }
}
