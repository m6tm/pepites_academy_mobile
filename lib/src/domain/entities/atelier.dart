import 'enums/atelier_statut.dart';
import 'enums/atelier_type.dart';
export 'enums/atelier_statut.dart';
export 'enums/atelier_type.dart';

/// Configuration d'evaluation d'un atelier : N elements par critere (min 1).
class ConfigurationElementEvaluation {
  final String critereId;
  final List<String> elementIds;

  const ConfigurationElementEvaluation({
    required this.critereId,
    required this.elementIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'critere_id': critereId,
      'element_ids': elementIds,
    };
  }

  factory ConfigurationElementEvaluation.fromJson(Map<String, dynamic> json) {
    final rawIds = json['element_ids'] ?? json['elementIds'];
    List<String> ids;
    if (rawIds is List) {
      ids = rawIds.cast<String>();
    } else {
      // Fallback pour compatibilite ancien format element_1_id / element_2_id
      final e1 = json['element_1_id'] ?? json['element1Id'];
      final e2 = json['element_2_id'] ?? json['element2Id'];
      ids = <String>[if (e1 != null) e1 as String, if (e2 != null) e2 as String];
    }
    return ConfigurationElementEvaluation(
      critereId: (json['critere_id'] ?? json['critereId']) as String,
      elementIds: ids,
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

  /// Indique si la configuration d'evaluation est complete (5 criteres, chacun avec au moins 1 element).
  bool get configurationEvaluationComplete =>
      configurationEvaluation != null &&
      configurationEvaluation!.length == 5 &&
      configurationEvaluation!.every((c) => c.elementIds.isNotEmpty);

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
      'seance_id': seanceId,
      'configuration_evaluation': configurationEvaluation?.map((e) => e.toJson()).toList(),
    };
  }

  factory Atelier.fromJson(Map<String, dynamic> json) {
    return Atelier(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: (json['description'] ?? '') as String,
      type: AtelierType.values.byName(json['type'] as String),
      typeCustom: json['type_custom'] as String?,
      icone: json['icone'] as String?,
      ordre: (json['ordre'] ?? 0) as int,
      statut: AtelierStatut.values.byName(json['statut'] as String),
      seanceId: (json['seance_id'] ?? json['seanceId']) as String,
      configurationEvaluation: json['configuration_evaluation'] != null
          ? (json['configuration_evaluation'] as List)
              .map((e) => ConfigurationElementEvaluation.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
