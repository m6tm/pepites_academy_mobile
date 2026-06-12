/// Represente un dossier medical de suivi d'une blessure d'un academicien.
class DossierMedical {
  final String id;
  final String academicienId;
  final DateTime dateBlessure;
  final String? heureBlessure;
  final String lieu;
  final String? adversaire;
  final Map<String, dynamic>? circonstances;
  final String? description;
  final String? partieCorps;
  final String? typeBlessure;
  final String? gravite;
  final List<String>? premiersSoins;
  final String? observations;
  final List<Map<String, dynamic>>? suiviReeducation;
  final List<Map<String, dynamic>>? retourProgressif;
  final Map<String, dynamic>? validationReprise;
  final DateTime? validationFinaleDate;
  final String? responsableMedical;
  final String signatureUrl;
  final String statutReprise;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DossierMedical({
    required this.id,
    required this.academicienId,
    required this.dateBlessure,
    this.heureBlessure,
    this.lieu = 'entrainement',
    this.adversaire,
    this.circonstances,
    this.description,
    this.partieCorps,
    this.typeBlessure,
    this.gravite,
    this.premiersSoins,
    this.observations,
    this.suiviReeducation,
    this.retourProgressif,
    this.validationReprise,
    this.validationFinaleDate,
    this.responsableMedical,
    this.signatureUrl = '',
    this.statutReprise = 'en_cours',
    required this.createdAt,
    this.updatedAt,
  });

  /// Retourne un libelle lisible pour la nature de la blessure.
  /// Affiche la precision correspondante si la valeur est 'autre'.
  String get natureBlessure {
    final parts = <String>[];
    if (partieCorps != null && partieCorps!.isNotEmpty) {
      final value = partieCorps!.toLowerCase() == 'autre'
          ? (circonstances?['partie_corps_precision']?.toString() ?? partieCorps!)
          : partieCorps!;
      parts.add(value);
    }
    if (typeBlessure != null && typeBlessure!.isNotEmpty) {
      final value = typeBlessure!.toLowerCase() == 'autre'
          ? (circonstances?['type_blessure_precision']?.toString() ?? typeBlessure!)
          : typeBlessure!;
      parts.add(value);
    }
    return parts.isNotEmpty ? parts.join(' - ') : 'Non specifiee';
  }

  /// Retourne un libelle lisible pour le statut de reprise.
  String get statutRepriseLabel {
    switch (statutReprise) {
      case 'en_cours':
        return 'En cours';
      case 'apte_entrainement':
        return 'Apte a l\'entrainement';
      case 'apte_competition':
        return 'Apte a la competition';
      case 'fini':
        return 'Cloture';
      default:
        return statutReprise;
    }
  }

  /// Copie le dossier avec les champs fournis.
  DossierMedical copyWith({
    String? id,
    String? academicienId,
    DateTime? dateBlessure,
    String? heureBlessure,
    String? lieu,
    String? adversaire,
    Map<String, dynamic>? circonstances,
    String? description,
    String? partieCorps,
    String? typeBlessure,
    String? gravite,
    List<String>? premiersSoins,
    String? observations,
    List<Map<String, dynamic>>? suiviReeducation,
    List<Map<String, dynamic>>? retourProgressif,
    Map<String, dynamic>? validationReprise,
    DateTime? validationFinaleDate,
    String? responsableMedical,
    String? signatureUrl,
    String? statutReprise,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DossierMedical(
      id: id ?? this.id,
      academicienId: academicienId ?? this.academicienId,
      dateBlessure: dateBlessure ?? this.dateBlessure,
      heureBlessure: heureBlessure ?? this.heureBlessure,
      lieu: lieu ?? this.lieu,
      adversaire: adversaire ?? this.adversaire,
      circonstances: circonstances ?? this.circonstances,
      description: description ?? this.description,
      partieCorps: partieCorps ?? this.partieCorps,
      typeBlessure: typeBlessure ?? this.typeBlessure,
      gravite: gravite ?? this.gravite,
      premiersSoins: premiersSoins ?? this.premiersSoins,
      observations: observations ?? this.observations,
      suiviReeducation: suiviReeducation ?? this.suiviReeducation,
      retourProgressif: retourProgressif ?? this.retourProgressif,
      validationReprise: validationReprise ?? this.validationReprise,
      validationFinaleDate: validationFinaleDate ?? this.validationFinaleDate,
      responsableMedical: responsableMedical ?? this.responsableMedical,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      statutReprise: statutReprise ?? this.statutReprise,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academicien_id': academicienId,
      'date_blessure': dateBlessure.toIso8601String(),
      'heure_blessure': heureBlessure,
      'lieu': lieu,
      'adversaire': adversaire,
      'circonstances': circonstances,
      'description': description,
      'partie_corps': partieCorps,
      'type_blessure': typeBlessure,
      'gravite': gravite,
      'premiers_soins': premiersSoins,
      'observations': observations,
      'suivi_reeducation': suiviReeducation,
      'retour_progressif': retourProgressif,
      'validation_reprise': validationReprise,
      'validation_finale_date': validationFinaleDate?.toIso8601String(),
      'responsable_medical': responsableMedical,
      'signature_url': signatureUrl,
      'statut_reprise': statutReprise,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory DossierMedical.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    List<Map<String, dynamic>>? parseListMap(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      return null;
    }

    return DossierMedical(
      id: json['id']?.toString() ?? '',
      academicienId: json['academicien_id']?.toString() ??
          json['academicienId']?.toString() ??
          '',
      dateBlessure: parseDate(json['date_blessure'] ?? json['dateBlessure']) ??
          DateTime.now(),
      heureBlessure: json['heure_blessure']?.toString() ??
          json['heureBlessure']?.toString(),
      lieu: json['lieu']?.toString() ?? 'entrainement',
      adversaire: json['adversaire']?.toString(),
      circonstances: json['circonstances'] is Map<String, dynamic>
          ? json['circonstances'] as Map<String, dynamic>
          : null,
      description: json['description']?.toString(),
      partieCorps: json['partie_corps']?.toString() ??
          json['partieCorps']?.toString(),
      typeBlessure: json['type_blessure']?.toString() ??
          json['typeBlessure']?.toString(),
      gravite: json['gravite']?.toString(),
      premiersSoins: (json['premiers_soins'] ?? json['premiersSoins'])
          is List
          ? (json['premiers_soins'] ?? json['premiersSoins'])
              .whereType<String>()
              .toList()
          : null,
      observations: json['observations']?.toString(),
      suiviReeducation: parseListMap(
        json['suivi_reeducation'] ?? json['suiviReeducation'],
      ),
      retourProgressif: parseListMap(
        json['retour_progressif'] ?? json['retourProgressif'],
      ),
      validationReprise: json['validation_reprise'] is Map<String, dynamic>
          ? json['validation_reprise'] as Map<String, dynamic>
          : json['validationReprise'] is Map<String, dynamic>
              ? json['validationReprise'] as Map<String, dynamic>
              : null,
      validationFinaleDate: parseDate(
        json['validation_finale_date'] ?? json['validationFinaleDate'],
      ),
      responsableMedical: json['responsable_medical']?.toString() ??
          json['responsableMedical']?.toString(),
      signatureUrl: json['signature_url']?.toString() ??
          json['signatureUrl']?.toString() ??
          '',
      statutReprise: json['statut_reprise']?.toString() ??
          json['statutReprise']?.toString() ??
          'en_cours',
      createdAt: parseDate(json['created_at'] ?? json['createdAt']) ??
          DateTime.now(),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'DossierMedical(id: $id, academicienId: $academicienId, '
        'dateBlessure: $dateBlessure, statutReprise: $statutReprise)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DossierMedical && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
