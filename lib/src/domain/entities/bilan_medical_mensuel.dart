/// Represente un bilan medical mensuel d'un academicien.
class BilanMedicalMensuel {
  final String id;
  final String academicienId;
  final String medecinId;
  final int mois;
  final int annee;
  final int blessuresMusculaire;
  final int blessuresArticulaire;
  final int blessuresTraumatique;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BilanMedicalMensuel({
    required this.id,
    required this.academicienId,
    required this.medecinId,
    required this.mois,
    required this.annee,
    this.blessuresMusculaire = 0,
    this.blessuresArticulaire = 0,
    this.blessuresTraumatique = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Retourne le libelle du mois formate (ex: "Juin 2026").
  String get periodeLabel {
    const moisLabels = [
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
    final label = moisLabels[mois.clamp(1, 12) - 1];
    return '$label $annee';
  }

  /// Retourne le nombre total de blessures.
  int get totalBlessures {
    return blessuresMusculaire + blessuresArticulaire + blessuresTraumatique;
  }

  BilanMedicalMensuel copyWith({
    String? id,
    String? academicienId,
    String? medecinId,
    int? mois,
    int? annee,
    int? blessuresMusculaire,
    int? blessuresArticulaire,
    int? blessuresTraumatique,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BilanMedicalMensuel(
      id: id ?? this.id,
      academicienId: academicienId ?? this.academicienId,
      medecinId: medecinId ?? this.medecinId,
      mois: mois ?? this.mois,
      annee: annee ?? this.annee,
      blessuresMusculaire: blessuresMusculaire ?? this.blessuresMusculaire,
      blessuresArticulaire: blessuresArticulaire ?? this.blessuresArticulaire,
      blessuresTraumatique: blessuresTraumatique ?? this.blessuresTraumatique,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academicien_id': academicienId,
      'medecin_id': medecinId,
      'mois': mois,
      'annee': annee,
      'blessures_musculaire': blessuresMusculaire,
      'blessures_articulaire': blessuresArticulaire,
      'blessures_traumatique': blessuresTraumatique,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory BilanMedicalMensuel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    return BilanMedicalMensuel(
      id: json['id']?.toString() ?? '',
      academicienId: json['academicien_id']?.toString() ??
          json['academicienId']?.toString() ??
          '',
      medecinId: json['medecin_id']?.toString() ??
          json['medecinId']?.toString() ??
          '',
      mois: parseInt(json['mois']),
      annee: parseInt(json['annee']),
      blessuresMusculaire: parseInt(json['blessures_musculaire'] ??
          json['blessuresMusculaire']),
      blessuresArticulaire: parseInt(json['blessures_articulaire'] ??
          json['blessuresArticulaire']),
      blessuresTraumatique: parseInt(json['blessures_traumatique'] ??
          json['blessuresTraumatique']),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']) ??
          DateTime.now(),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'BilanMedicalMensuel(id: $id, academicienId: $academicienId, '
        'mois: $mois, annee: $annee)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BilanMedicalMensuel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
