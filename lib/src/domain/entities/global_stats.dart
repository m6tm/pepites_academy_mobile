/// Statistiques globales de l'academie.
class GlobalStats {
  /// Nombre total d'academiciens inscrits.
  final int nbAcademiciens;

  /// Nombre total d'encadreurs actifs.
  final int nbEncadreurs;

  /// Nombre de seances du mois courant.
  final int nbSeancesMois;

  /// Taux de presence moyen (0-100).
  final double tauxPresenceMoyen;

  /// Pourcentage d'objectifs atteints (0-100).
  final double objectifsAtteints;

  /// Satisfaction des coachs basee sur les annotations (0-100).
  final double satisfactionCoachs;

  const GlobalStats({
    required this.nbAcademiciens,
    required this.nbEncadreurs,
    required this.nbSeancesMois,
    required this.tauxPresenceMoyen,
    required this.objectifsAtteints,
    required this.satisfactionCoachs,
  });

  /// Cree une instance depuis un JSON (reponse API).
  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      nbAcademiciens: json['nb_academiciens'] as int? ?? 0,
      nbEncadreurs: json['nb_encadreurs'] as int? ?? 0,
      nbSeancesMois: json['nb_seances_mois'] as int? ?? 0,
      tauxPresenceMoyen: (json['taux_presence_moyen'] as num?)?.toDouble() ?? 0.0,
      objectifsAtteints: (json['objectifs_atteints'] as num?)?.toDouble() ?? 0.0,
      satisfactionCoachs: (json['satisfaction_coachs'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'nb_academiciens': nbAcademiciens,
      'nb_encadreurs': nbEncadreurs,
      'nb_seances_mois': nbSeancesMois,
      'taux_presence_moyen': tauxPresenceMoyen,
      'objectifs_atteints': objectifsAtteints,
      'satisfaction_coachs': satisfactionCoachs,
    };
  }

  /// Instance par defaut avec des valeurs nulles.
  static const empty = GlobalStats(
    nbAcademiciens: 0,
    nbEncadreurs: 0,
    nbSeancesMois: 0,
    tauxPresenceMoyen: 0.0,
    objectifsAtteints: 0.0,
    satisfactionCoachs: 0.0,
  );
}
