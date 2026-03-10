/// Donnees pour un point de l'evolution des presences.
class PresenceEvolutionPoint {
  /// Date au format YYYY-MM.
  final String date;

  /// Nombre de presences.
  final int count;

  const PresenceEvolutionPoint({
    required this.date,
    required this.count,
  });

  /// Cree une instance depuis un JSON (reponse API).
  factory PresenceEvolutionPoint.fromJson(Map<String, dynamic> json) {
    return PresenceEvolutionPoint(
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'count': count,
    };
  }
}

/// Donnees pour un point de la repartition par poste.
class RepartitionPostePoint {
  /// Nom du poste.
  final String poste;

  /// Nombre d'academiciens.
  final int count;

  const RepartitionPostePoint({
    required this.poste,
    required this.count,
  });

  /// Cree une instance depuis un JSON (reponse API).
  factory RepartitionPostePoint.fromJson(Map<String, dynamic> json) {
    return RepartitionPostePoint(
      poste: json['poste'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'poste': poste,
      'count': count,
    };
  }
}

/// Donnees pour un point de la performance mensuelle.
class PerformanceMensuellePoint {
  /// Nom du mois.
  final String mois;

  /// Note moyenne sur 5.
  final double moyenne;

  const PerformanceMensuellePoint({
    required this.mois,
    required this.moyenne,
  });

  /// Cree une instance depuis un JSON (reponse API).
  factory PerformanceMensuellePoint.fromJson(Map<String, dynamic> json) {
    return PerformanceMensuellePoint(
      mois: json['mois'] as String? ?? '',
      moyenne: (json['moyenne'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'mois': mois,
      'moyenne': moyenne,
    };
  }
}

/// Periode pour les statistiques des graphiques.
enum ChartPeriod {
  /// Statistiques du mois en cours.
  month,

  /// Statistiques du trimestre en cours.
  quarter,

  /// Statistiques de la saison en cours.
  season;

  /// Retourne la valeur pour l'API.
  String toApiValue() {
    switch (this) {
      case ChartPeriod.month:
        return 'month';
      case ChartPeriod.quarter:
        return 'quarter';
      case ChartPeriod.season:
        return 'season';
    }
  }

  /// Cree une instance depuis une valeur API.
  static ChartPeriod fromApiValue(String value) {
    switch (value) {
      case 'quarter':
        return ChartPeriod.quarter;
      case 'season':
        return ChartPeriod.season;
      default:
        return ChartPeriod.month;
    }
  }
}

/// Statistiques completes pour les graphiques du dashboard.
class ChartStats {
  /// Evolution des presences par mois.
  final List<PresenceEvolutionPoint> presenceEvolution;

  /// Repartition des academiciens par poste.
  final List<RepartitionPostePoint> repartitionPostes;

  /// Performance mensuelle (moyenne des notes).
  final List<PerformanceMensuellePoint> performanceMensuelle;

  /// Periode utilisee pour les statistiques.
  final ChartPeriod period;

  /// Date de generation des donnees.
  final DateTime? generatedAt;

  const ChartStats({
    this.presenceEvolution = const [],
    this.repartitionPostes = const [],
    this.performanceMensuelle = const [],
    this.period = ChartPeriod.month,
    this.generatedAt,
  });

  /// Cree une instance depuis un JSON (reponse API).
  factory ChartStats.fromJson(Map<String, dynamic> json) {
    final presenceList = json['presence_evolution'] as List<dynamic>?;
    final repartitionList = json['repartition_postes'] as List<dynamic>?;
    final performanceList = json['performance_mensuelle'] as List<dynamic>?;

    return ChartStats(
      presenceEvolution: presenceList
              ?.map((e) =>
                  PresenceEvolutionPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      repartitionPostes: repartitionList
              ?.map((e) =>
                  RepartitionPostePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      performanceMensuelle: performanceList
              ?.map((e) =>
                  PerformanceMensuellePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      period: ChartPeriod.fromApiValue(json['period'] as String? ?? 'month'),
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'] as String)
          : null,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'presence_evolution':
          presenceEvolution.map((e) => e.toJson()).toList(),
      'repartition_postes': repartitionPostes.map((e) => e.toJson()).toList(),
      'performance_mensuelle':
          performanceMensuelle.map((e) => e.toJson()).toList(),
      'period': period.toApiValue(),
      'generated_at': generatedAt?.toIso8601String(),
    };
  }

  /// Instance vide par defaut.
  static const empty = ChartStats();

  /// Indique si les donnees sont vides.
  bool get isEmpty =>
      presenceEvolution.isEmpty &&
      repartitionPostes.isEmpty &&
      performanceMensuelle.isEmpty;

  /// Cree une copie avec des champs modifies.
  ChartStats copyWith({
    List<PresenceEvolutionPoint>? presenceEvolution,
    List<RepartitionPostePoint>? repartitionPostes,
    List<PerformanceMensuellePoint>? performanceMensuelle,
    ChartPeriod? period,
    DateTime? generatedAt,
  }) {
    return ChartStats(
      presenceEvolution: presenceEvolution ?? this.presenceEvolution,
      repartitionPostes: repartitionPostes ?? this.repartitionPostes,
      performanceMensuelle: performanceMensuelle ?? this.performanceMensuelle,
      period: period ?? this.period,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
