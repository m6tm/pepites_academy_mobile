import 'enums/atelier_statut.dart';
import 'enums/atelier_type.dart';
export 'enums/atelier_statut.dart';
export 'enums/atelier_type.dart';

/// Configuration d'evaluation d'un atelier : 2 elements par critere.
class ConfigurationElementEvaluation {
  final String critereId;
  final String element1Id;
  final String element2Id;

  const ConfigurationElementEvaluation({
    required this.critereId,
    required this.element1Id,
    required this.element2Id,
  });

  Map<String, dynamic> toJson() {
    return {
      'critere_id': critereId,
      'element_1_id': element1Id,
      'element_2_id': element2Id,
    };
  }

  factory ConfigurationElementEvaluation.fromJson(Map<String, dynamic> json) {
    return ConfigurationElementEvaluation(
      critereId: (json['critere_id'] ?? json['critereId']) as String,
      element1Id: (json['element_1_id'] ?? json['element1Id']) as String,
      element2Id: (json['element_2_id'] ?? json['element2Id']) as String,
    );
  }
}

class Atelier {
  final String id;
  final String nom;
  final String description;
  final AtelierType type;
  final String? typeCustom;
  final String? icone;
  final int ordre;
  final AtelierStatut statut;
  final String seanceId;
  final List<ConfigurationElementEvaluation>? configurationEvaluation;

  const Atelier({
    required this.id,
    required this.nom,
    required this.description,
    required this.type,
    this.typeCustom,
    this.icone,
    required this.ordre,
    required this.statut,
    required this.seanceId,
    this.configurationEvaluation,
  });

  String get typeLabel => (type == AtelierType.personnalise && typeCustom != null && typeCustom!.isNotEmpty)
      ? typeCustom!
      : type.label;

  /// Indique si la configuration d'evaluation est complete (5 criteres x 2 elements).
  bool get configurationEvaluationComplete =>
      configurationEvaluation != null && configurationEvaluation!.length == 5;

  /// Cree une copie de l'atelier avec des champs modifies.
  Atelier copyWith({
    String? id,
    String? nom,
    String? description,
    AtelierType? type,
    String? typeCustom,
    String? icone,
    int? ordre,
    AtelierStatut? statut,
    String? seanceId,
    List<ConfigurationElementEvaluation>? configurationEvaluation,
  }) {
    return Atelier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      type: type ?? this.type,
      typeCustom: typeCustom ?? this.typeCustom,
      icone: icone ?? this.icone,
      ordre: ordre ?? this.ordre,
      statut: statut ?? this.statut,
      seanceId: seanceId ?? this.seanceId,
      configurationEvaluation: configurationEvaluation ?? this.configurationEvaluation,
    );
  }

  /// Serialise l'atelier en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'type': type.name,
      'type_custom': typeCustom,
      'icone': icone,
      'ordre': ordre,
      'statut': statut.name,
      'seanceId': seanceId,
      'configuration_evaluation': configurationEvaluation
          ?.map((c) => c.toJson())
          .toList(),
    };
  }

  /// Deserialise un atelier depuis un Map JSON.
  factory Atelier.fromJson(Map<String, dynamic> json) {
    final configRaw = json['configuration_evaluation'] as List<dynamic>?;
    return Atelier(
      id: json['id'] as String,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: AtelierType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AtelierType.personnalise,
      ),
      typeCustom: json['type_custom'] as String?,
      icone: json['icone'] as String?,
      ordre: json['ordre'] as int? ?? 0,
      statut: AtelierStatut.values.firstWhere(
        (e) => e.name == json['statut'],
        orElse: () => AtelierStatut.cree,
      ),
      seanceId: (json['seance_id'] ?? json['seanceId']) as String,
      configurationEvaluation: configRaw
          ?.map((e) => ConfigurationElementEvaluation.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }
}
