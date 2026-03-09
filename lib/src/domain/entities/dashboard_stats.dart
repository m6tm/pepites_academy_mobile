import 'global_stats.dart';

/// Statut d'une saison.
enum SeasonStatus {
  /// Saison ouverte (activite en cours).
  open,

  /// Saison fermee (archivee).
  closed,

  /// Saison en attente (planifiee mais pas encore active).
  pending,

  /// Aucune saison active.
  none,
}

/// Represente une saison de l'academie.
class Season {
  /// Identifiant unique de la saison.
  final String id;

  /// Nom de la saison (ex: "Saison 2024-2025").
  final String name;

  /// Date de debut de la saison.
  final DateTime startDate;

  /// Date de fin de la saison (null si en cours).
  final DateTime? endDate;

  /// Statut actuel de la saison.
  final SeasonStatus status;

  const Season({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.status,
  });

  /// Cree une instance depuis un JSON (reponse API).
  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startDate:
          DateTime.tryParse(json['start_date'] as String? ?? '') ??
          DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      status: _parseStatus(json['status'] as String?),
    );
  }

  static SeasonStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
      case 'ouverte':
        return SeasonStatus.open;
      case 'closed':
      case 'fermee':
        return SeasonStatus.closed;
      case 'pending':
      case 'en_attente':
        return SeasonStatus.pending;
      default:
        return SeasonStatus.none;
    }
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status.name,
    };
  }

  /// Instance par defaut (aucune saison).
  static Season empty() => Season(
    id: '',
    name: '',
    startDate: DateTime(1970),
    status: SeasonStatus.none,
  );
}

/// Statistiques completes du dashboard pour le SupAdmin.
///
/// Cette entite regroupe toutes les metriques necessaires au dashboard
/// super administrateur, incluant les statistiques globales et les
/// informations sur la saison en cours.
class DashboardStats {
  /// Statistiques globales de l'academie.
  final GlobalStats globalStats;

  /// Nombre total de seances (toutes periodes confondues).
  final int nbSeancesTotal;

  /// Nombre total d'annotations enregistrees.
  final int nbAnnotationsTotal;

  /// Nombre total de presences enregistrees.
  final int nbPresencesTotal;

  /// Nombre de seances du jour.
  final int nbSeancesJour;

  /// Nombre de presences du jour.
  final int nbPresencesJour;

  /// Saison en cours (ou null si aucune).
  final Season? currentSeason;

  /// Nombre d'utilisateurs par role.
  final Map<String, int> usersByRole;

  /// Date de derniere mise a jour des statistiques.
  final DateTime? lastUpdatedAt;

  const DashboardStats({
    required this.globalStats,
    this.nbSeancesTotal = 0,
    this.nbAnnotationsTotal = 0,
    this.nbPresencesTotal = 0,
    this.nbSeancesJour = 0,
    this.nbPresencesJour = 0,
    this.currentSeason,
    this.usersByRole = const {},
    this.lastUpdatedAt,
  });

  /// Nombre total d'academiciens (raccourci vers globalStats).
  int get nbAcademiciens => globalStats.nbAcademiciens;

  /// Nombre total d'encadreurs (raccourci vers globalStats).
  int get nbEncadreurs => globalStats.nbEncadreurs;

  /// Taux de presence moyen (raccourci vers globalStats).
  double get tauxPresenceMoyen => globalStats.tauxPresenceMoyen;

  /// Indique si une saison est actuellement ouverte.
  bool get hasActiveSeason => currentSeason?.status == SeasonStatus.open;

  /// Cree une instance depuis un JSON (reponse API).
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final globalStatsJson = json['global_stats'] as Map<String, dynamic>?;
    final seasonJson = json['current_season'] as Map<String, dynamic>?;
    final usersByRoleJson = json['users_by_role'] as Map<String, dynamic>?;

    return DashboardStats(
      globalStats: globalStatsJson != null
          ? GlobalStats.fromJson(globalStatsJson)
          : GlobalStats.empty,
      nbSeancesTotal: json['nb_seances_total'] as int? ?? 0,
      nbAnnotationsTotal: json['nb_annotations_total'] as int? ?? 0,
      nbPresencesTotal: json['nb_presences_total'] as int? ?? 0,
      nbSeancesJour: json['nb_seances_jour'] as int? ?? 0,
      nbPresencesJour: json['nb_presences_jour'] as int? ?? 0,
      currentSeason: seasonJson != null ? Season.fromJson(seasonJson) : null,
      usersByRole: usersByRoleJson != null
          ? Map<String, int>.from(usersByRoleJson)
          : const {},
      lastUpdatedAt: json['last_updated_at'] != null
          ? DateTime.tryParse(json['last_updated_at'] as String)
          : null,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'global_stats': globalStats.toJson(),
      'nb_seances_total': nbSeancesTotal,
      'nb_annotations_total': nbAnnotationsTotal,
      'nb_presences_total': nbPresencesTotal,
      'nb_seances_jour': nbSeancesJour,
      'nb_presences_jour': nbPresencesJour,
      'current_season': currentSeason?.toJson(),
      'users_by_role': usersByRole,
      'last_updated_at': lastUpdatedAt?.toIso8601String(),
    };
  }

  /// Instance par defaut avec des valeurs nulles.
  static const empty = DashboardStats(
    globalStats: GlobalStats.empty,
    nbSeancesTotal: 0,
    nbAnnotationsTotal: 0,
    nbPresencesTotal: 0,
    nbSeancesJour: 0,
    nbPresencesJour: 0,
    currentSeason: null,
    usersByRole: {},
    lastUpdatedAt: null,
  );

  /// Cree une copie avec des champs modifies.
  DashboardStats copyWith({
    GlobalStats? globalStats,
    int? nbSeancesTotal,
    int? nbAnnotationsTotal,
    int? nbPresencesTotal,
    int? nbSeancesJour,
    int? nbPresencesJour,
    Season? currentSeason,
    Map<String, int>? usersByRole,
    DateTime? lastUpdatedAt,
    bool clearSeason = false,
  }) {
    return DashboardStats(
      globalStats: globalStats ?? this.globalStats,
      nbSeancesTotal: nbSeancesTotal ?? this.nbSeancesTotal,
      nbAnnotationsTotal: nbAnnotationsTotal ?? this.nbAnnotationsTotal,
      nbPresencesTotal: nbPresencesTotal ?? this.nbPresencesTotal,
      nbSeancesJour: nbSeancesJour ?? this.nbSeancesJour,
      nbPresencesJour: nbPresencesJour ?? this.nbPresencesJour,
      currentSeason: clearSeason ? null : (currentSeason ?? this.currentSeason),
      usersByRole: usersByRole ?? this.usersByRole,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
