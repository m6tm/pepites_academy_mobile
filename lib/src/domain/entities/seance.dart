/// Statuts possibles d'une seance d'entrainement.
enum SeanceStatus { ouverte, fermee, aVenir }

/// Represente une seance d'entrainement.
class Seance {
  final String id;
  final String titre;
  final DateTime date;
  final DateTime heureDebut;
  final DateTime heureFin;
  final SeanceStatus statut;
  final String encadreurResponsableId;
  final List<String> encadreurIds;
  final List<String> academicienIds;
  final List<String> atelierIds;
  final int nbPresents;
  final int nbAteliers;

  Seance({
    required this.id,
    required this.titre,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.statut,
    required this.encadreurResponsableId,
    this.encadreurIds = const [],
    this.academicienIds = const [],
    this.atelierIds = const [],
    this.nbPresents = 0,
    this.nbAteliers = 0,
  });

  /// Cree une copie de la seance avec des champs modifies.
  Seance copyWith({
    String? id,
    String? titre,
    DateTime? date,
    DateTime? heureDebut,
    DateTime? heureFin,
    SeanceStatus? statut,
    String? encadreurResponsableId,
    List<String>? encadreurIds,
    List<String>? academicienIds,
    List<String>? atelierIds,
    int? nbPresents,
    int? nbAteliers,
  }) {
    return Seance(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      date: date ?? this.date,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      statut: statut ?? this.statut,
      encadreurResponsableId:
          encadreurResponsableId ?? this.encadreurResponsableId,
      encadreurIds: encadreurIds ?? this.encadreurIds,
      academicienIds: academicienIds ?? this.academicienIds,
      atelierIds: atelierIds ?? this.atelierIds,
      nbPresents: nbPresents ?? this.nbPresents,
      nbAteliers: nbAteliers ?? this.nbAteliers,
    );
  }

  /// Serialise la seance en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'date': date.toIso8601String(),
      'heureDebut': heureDebut.toIso8601String(),
      'heureFin': heureFin.toIso8601String(),
      'statut': statut.name,
      'encadreurResponsableId': encadreurResponsableId,
      'encadreurIds': encadreurIds,
      'academicienIds': academicienIds,
      'atelierIds': atelierIds,
      'nbPresents': nbPresents,
      'nbAteliers': nbAteliers,
    };
  }

  /// Deserialise une seance depuis un Map JSON.
  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: json['id'] as String,
      titre: json['titre'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      heureDebut: DateTime.parse(json['heureDebut'] as String),
      heureFin: DateTime.parse(json['heureFin'] as String),
      statut: SeanceStatus.values.firstWhere(
        (e) => e.name == json['statut'],
        orElse: () => SeanceStatus.aVenir,
      ),
      encadreurResponsableId: json['encadreurResponsableId'] as String,
      encadreurIds:
          (json['encadreurIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      academicienIds:
          (json['academicienIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      atelierIds:
          (json['atelierIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      nbPresents: json['nbPresents'] as int? ?? 0,
      nbAteliers: json['nbAteliers'] as int? ?? 0,
    );
  }

  /// Verifie si la seance est actuellement ouverte.
  bool get estOuverte => statut == SeanceStatus.ouverte;

  /// Verifie si la seance est terminee.
  bool get estFermee => statut == SeanceStatus.fermee;

  /// Verifie si la seance est a venir.
  bool get estAVenir => statut == SeanceStatus.aVenir;

  /// Retourne la duree formatee de la seance.
  String get dureeFormatee {
    final debut =
        '${heureDebut.hour.toString().padLeft(2, '0')}:'
        '${heureDebut.minute.toString().padLeft(2, '0')}';
    final fin =
        '${heureFin.hour.toString().padLeft(2, '0')}:'
        '${heureFin.minute.toString().padLeft(2, '0')}';
    return '$debut - $fin';
  }

  /// Retourne la date formatee de la seance.
  String get dateFormatee {
    const mois = [
      'Jan',
      'Fev',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Aout',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${mois[date.month - 1]} ${date.year}';
  }
}
