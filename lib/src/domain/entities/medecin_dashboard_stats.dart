/// Represente une alerte medicale.
class MedicalAlert {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isUrgent;
  final String? academicienId;

  const MedicalAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isUrgent = false,
    this.academicienId,
  });

  factory MedicalAlert.fromJson(Map<String, dynamic> json) {
    return MedicalAlert(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      isUrgent: json['is_urgent'] as bool? ?? false,
      academicienId: json['academicien_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'is_urgent': isUrgent,
      'academicien_id': academicienId,
    };
  }
}

/// Statistiques du dashboard pour le Medecin Chef.
class MedecinDashboardStats {
  final int nbAcademiciens;
  final int nbConsultations;
  final int nbAlertesActives;
  final int nbJoueursInaptes;
  final double tauxAptitude;
  final List<MedicalAlert> recentAlerts;
  final DateTime? lastUpdatedAt;

  const MedecinDashboardStats({
    this.nbAcademiciens = 0,
    this.nbConsultations = 0,
    this.nbAlertesActives = 0,
    this.nbJoueursInaptes = 0,
    this.tauxAptitude = 0,
    this.recentAlerts = const [],
    this.lastUpdatedAt,
  });

  factory MedecinDashboardStats.fromJson(Map<String, dynamic> json) {
    final alertsJson = json['recent_alerts'] as List<dynamic>?;
    return MedecinDashboardStats(
      nbAcademiciens: json['nb_academicians'] as int? ?? 0,
      nbConsultations: json['nb_consultations'] as int? ?? 0,
      nbAlertesActives: json['nb_alertes_actives'] as int? ?? 0,
      nbJoueursInaptes: json['nb_joueurs_inaptes'] as int? ?? 0,
      tauxAptitude: (json['taux_aptitude'] as num?)?.toDouble() ?? 0,
      recentAlerts: alertsJson != null
          ? alertsJson
              .map((e) => MedicalAlert.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      lastUpdatedAt: json['last_updated_at'] != null
          ? DateTime.tryParse(json['last_updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nb_academicians': nbAcademiciens,
      'nb_consultations': nbConsultations,
      'nb_alertes_actives': nbAlertesActives,
      'nb_joueurs_inaptes': nbJoueursInaptes,
      'taux_aptitude': tauxAptitude,
      'recent_alerts': recentAlerts.map((e) => e.toJson()).toList(),
      'last_updated_at': lastUpdatedAt?.toIso8601String(),
    };
  }

  static const empty = MedecinDashboardStats();
}
