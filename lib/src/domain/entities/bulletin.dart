/// Types de periodes disponibles pour le bulletin.
enum PeriodeType { mois, trimestre, saison }

/// Competences evaluees dans le bulletin.
class Competences {
  final double technique;
  final double physique;
  final double tactique;
  final double mental;
  final double espritEquipe;

  const Competences({
    this.technique = 0,
    this.physique = 0,
    this.tactique = 0,
    this.mental = 0,
    this.espritEquipe = 0,
  });

  /// Retourne la liste des valeurs pour le diagramme radar.
  List<double> toList() => [
    technique,
    physique,
    tactique,
    mental,
    espritEquipe,
  ];

  /// Labels associes aux axes du radar.
  static List<String> get labels => [
    'Technique',
    'Physique',
    'Tactique',
    'Mental',
    'Esprit d\'equipe',
  ];

  /// Moyenne globale des competences.
  double get moyenne =>
      (technique + physique + tactique + mental + espritEquipe) / 5;

  /// Serialise les competences en Map JSON.
  Map<String, dynamic> toJson() => {
    'technique': technique,
    'physique': physique,
    'tactique': tactique,
    'mental': mental,
    'espritEquipe': espritEquipe,
  };

  /// Deserialise les competences depuis un Map JSON.
  factory Competences.fromJson(Map<String, dynamic> json) {
    return Competences(
      technique: (json['technique'] as num?)?.toDouble() ?? 0,
      physique: (json['physique'] as num?)?.toDouble() ?? 0,
      tactique: (json['tactique'] as num?)?.toDouble() ?? 0,
      mental: (json['mental'] as num?)?.toDouble() ?? 0,
      espritEquipe: (json['espritEquipe'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Cree une copie avec des champs modifies.
  Competences copyWith({
    double? technique,
    double? physique,
    double? tactique,
    double? mental,
    double? espritEquipe,
  }) {
    return Competences(
      technique: technique ?? this.technique,
      physique: physique ?? this.physique,
      tactique: tactique ?? this.tactique,
      mental: mental ?? this.mental,
      espritEquipe: espritEquipe ?? this.espritEquipe,
    );
  }
}

/// Appreciation par domaine dans le bulletin.
class AppreciationDomaine {
  final String domaine;
  final double note;
  final String commentaire;

  const AppreciationDomaine({
    required this.domaine,
    required this.note,
    this.commentaire = '',
  });

  /// Serialise en Map JSON.
  Map<String, dynamic> toJson() => {
    'domaine': domaine,
    'note': note,
    'commentaire': commentaire,
  };

  /// Deserialise depuis un Map JSON.
  factory AppreciationDomaine.fromJson(Map<String, dynamic> json) {
    return AppreciationDomaine(
      domaine: json['domaine'] as String? ?? '',
      note: (json['note'] as num?)?.toDouble() ?? 0,
      commentaire: json['commentaire'] as String? ?? '',
    );
  }
}

/// Represente un bulletin de formation periodique.
class Bulletin {
  final String id;
  final DateTime dateDebutPeriode;
  final DateTime dateFinPeriode;
  final PeriodeType typePeriode;
  final String academicienId;
  final String encadreurId;
  final String observationsGenerales;
  final Competences competences;
  final List<AppreciationDomaine> appreciations;
  final int nbSeancesTotal;
  final int nbSeancesPresent;
  final int nbAnnotationsTotal;
  final DateTime dateGeneration;

  const Bulletin({
    required this.id,
    required this.dateDebutPeriode,
    required this.dateFinPeriode,
    required this.typePeriode,
    required this.academicienId,
    required this.encadreurId,
    this.observationsGenerales = '',
    required this.competences,
    this.appreciations = const [],
    this.nbSeancesTotal = 0,
    this.nbSeancesPresent = 0,
    this.nbAnnotationsTotal = 0,
    required this.dateGeneration,
  });

  /// Taux de presence en pourcentage.
  double get tauxPresence =>
      nbSeancesTotal > 0 ? (nbSeancesPresent / nbSeancesTotal) * 100 : 0;

  /// Label de la periode (ex: "Janvier 2026", "T1 2026", "Saison 2025-2026").
  String get periodeLabel {
    const mois = [
      'Janvier',
      'Fevrier',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Aout',
      'Septembre',
      'Octobre',
      'Novembre',
      'Decembre',
    ];
    switch (typePeriode) {
      case PeriodeType.mois:
        return '${mois[dateDebutPeriode.month - 1]} ${dateDebutPeriode.year}';
      case PeriodeType.trimestre:
        final trimestre = ((dateDebutPeriode.month - 1) ~/ 3) + 1;
        return 'T$trimestre ${dateDebutPeriode.year}';
      case PeriodeType.saison:
        return 'Saison ${dateDebutPeriode.year}-${dateFinPeriode.year}';
    }
  }

  /// Serialise le bulletin en Map JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'dateDebutPeriode': dateDebutPeriode.toIso8601String(),
    'dateFinPeriode': dateFinPeriode.toIso8601String(),
    'typePeriode': typePeriode.name,
    'academicienId': academicienId,
    'encadreurId': encadreurId,
    'observationsGenerales': observationsGenerales,
    'competences': competences.toJson(),
    'appreciations': appreciations.map((a) => a.toJson()).toList(),
    'nbSeancesTotal': nbSeancesTotal,
    'nbSeancesPresent': nbSeancesPresent,
    'nbAnnotationsTotal': nbAnnotationsTotal,
    'dateGeneration': dateGeneration.toIso8601String(),
  };

  /// Deserialise un bulletin depuis un Map JSON.
  factory Bulletin.fromJson(Map<String, dynamic> json) {
    return Bulletin(
      id: json['id'] as String,
      dateDebutPeriode: DateTime.parse(json['dateDebutPeriode'] as String),
      dateFinPeriode: DateTime.parse(json['dateFinPeriode'] as String),
      typePeriode: PeriodeType.values.firstWhere(
        (e) => e.name == json['typePeriode'],
        orElse: () => PeriodeType.mois,
      ),
      academicienId: json['academicienId'] as String,
      encadreurId: json['encadreurId'] as String? ?? '',
      observationsGenerales: json['observationsGenerales'] as String? ?? '',
      competences: Competences.fromJson(
        json['competences'] as Map<String, dynamic>? ?? {},
      ),
      appreciations:
          (json['appreciations'] as List<dynamic>?)
              ?.map(
                (e) => AppreciationDomaine.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      nbSeancesTotal: json['nbSeancesTotal'] as int? ?? 0,
      nbSeancesPresent: json['nbSeancesPresent'] as int? ?? 0,
      nbAnnotationsTotal: json['nbAnnotationsTotal'] as int? ?? 0,
      dateGeneration: DateTime.parse(json['dateGeneration'] as String),
    );
  }

  /// Cree une copie avec des champs modifies.
  Bulletin copyWith({
    String? id,
    DateTime? dateDebutPeriode,
    DateTime? dateFinPeriode,
    PeriodeType? typePeriode,
    String? academicienId,
    String? encadreurId,
    String? observationsGenerales,
    Competences? competences,
    List<AppreciationDomaine>? appreciations,
    int? nbSeancesTotal,
    int? nbSeancesPresent,
    int? nbAnnotationsTotal,
    DateTime? dateGeneration,
  }) {
    return Bulletin(
      id: id ?? this.id,
      dateDebutPeriode: dateDebutPeriode ?? this.dateDebutPeriode,
      dateFinPeriode: dateFinPeriode ?? this.dateFinPeriode,
      typePeriode: typePeriode ?? this.typePeriode,
      academicienId: academicienId ?? this.academicienId,
      encadreurId: encadreurId ?? this.encadreurId,
      observationsGenerales:
          observationsGenerales ?? this.observationsGenerales,
      competences: competences ?? this.competences,
      appreciations: appreciations ?? this.appreciations,
      nbSeancesTotal: nbSeancesTotal ?? this.nbSeancesTotal,
      nbSeancesPresent: nbSeancesPresent ?? this.nbSeancesPresent,
      nbAnnotationsTotal: nbAnnotationsTotal ?? this.nbAnnotationsTotal,
      dateGeneration: dateGeneration ?? this.dateGeneration,
    );
  }
}
