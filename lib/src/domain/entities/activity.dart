/// Types d'activites enregistrables dans le systeme.
enum ActivityType {
  seanceOuverte,
  seanceCloturee,
  seanceProgrammee,
  academicienInscrit,
  academicienSupprime,
  encadreurInscrit,
  presenceEnregistree,
  smsEnvoye,
  smsEchec,
  bulletinGenere,
  referentielPosteAjoute,
  referentielPosteModifie,
  referentielPosteSupprime,
  referentielNiveauAjoute,
  referentielNiveauModifie,
  referentielNiveauSupprime,
}

/// Represente une activite enregistree dans le systeme.
/// Sert de journal d'evenements pour le fil d'activites du dashboard.
class Activity {
  final String id;
  final ActivityType type;
  final String titre;
  final String description;
  final DateTime date;
  final String? referenceId;
  final String? utilisateurId;
  final String? utilisateurNom;

  const Activity({
    required this.id,
    required this.type,
    required this.titre,
    required this.description,
    required this.date,
    this.referenceId,
    this.utilisateurId,
    this.utilisateurNom,
  });

  /// Serialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'titre': titre,
      'description': description,
      'date': date.toIso8601String(),
      'referenceId': referenceId,
      'utilisateurId': utilisateurId,
      'utilisateurNom': utilisateurNom,
    };
  }

  /// Deserialisation depuis Map.
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.seanceOuverte,
      ),
      titre: json['titre'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      referenceId: json['referenceId'] as String?,
      utilisateurId: json['utilisateurId'] as String?,
      utilisateurNom: json['utilisateurNom'] as String?,
    );
  }
}
