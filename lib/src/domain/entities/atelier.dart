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
  final String theme;
  final String objectifs;
  final int? dureeMinutes;
  final AtelierType type;
  final String? typeCustom;
  final String? icone;
  final int ordre;
  final AtelierStatut statut;
  final String seanceId;
  final List<String> categorieIds;
  final List<ConfigurationElementEvaluation>? configurationEvaluation;

  const Atelier({
    required this.id,
    required this.nom,
    required this.description,
    this.theme = '',
    this.objectifs = '',
    this.dureeMinutes,
    required this.type,
    this.typeCustom,
    this.icone,
    required this.ordre,
    required this.statut,
    required this.seanceId,
    this.categorieIds = const [],
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
    String? theme,
    String? objectifs,
    int? dureeMinutes,
    bool clearDureeMinutes = false,
    AtelierType? type,
    String? typeCustom,
    String? icone,
    int? ordre,
    AtelierStatut? statut,
    String? seanceId,
    List<String>? categorieIds,
    List<ConfigurationElementEvaluation>? configurationEvaluation,
  }) {
    return Atelier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      theme: theme ?? this.theme,
      objectifs: objectifs ?? this.objectifs,
      dureeMinutes: clearDureeMinutes
          ? null
          : (dureeMinutes ?? this.dureeMinutes),
      type: type ?? this.type,
      typeCustom: typeCustom ?? this.typeCustom,
      icone: icone ?? this.icone,
      ordre: ordre ?? this.ordre,
      statut: statut ?? this.statut,
      seanceId: seanceId ?? this.seanceId,
      categorieIds: categorieIds ?? this.categorieIds,
      configurationEvaluation: configurationEvaluation ?? this.configurationEvaluation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'theme': theme,
      'objectifs': objectifs,
      'duree_minutes': dureeMinutes,
      'type': type.name,
      'type_custom': typeCustom,
      'icone': icone,
      'ordre': ordre,
      'statut': statut.name,
      'seance_id': seanceId,
      'categorie_ids': categorieIds,
      'configuration_evaluation': configurationEvaluation?.map((e) => e.toJson()).toList(),
    };
  }

  factory Atelier.fromJson(Map<String, dynamic> json) {
    return Atelier(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: (json['description'] ?? '') as String,
      theme: (json['theme'] ?? '') as String,
      objectifs: (json['objectifs'] ?? '') as String,
      dureeMinutes: json['duree_minutes'] as int? ?? json['dureeMinutes'] as int?,
      type: AtelierType.values.byName(json['type'] as String),
      typeCustom: json['type_custom'] as String?,
      icone: json['icone'] as String?,
      ordre: (json['ordre'] ?? 0) as int,
      statut: AtelierStatut.values.byName(json['statut'] as String),
      seanceId: (json['seance_id'] ?? json['seanceId']) as String,
      categorieIds: _parseCategorieIds(json),
      configurationEvaluation: json['configuration_evaluation'] != null
          ? (json['configuration_evaluation'] as List)
              .map((e) => ConfigurationElementEvaluation.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Extrait les IDs de categories depuis le JSON.
  /// Supporte la liste plate `categorie_ids` (stockage local, sync) et
  /// la liste imbriquee `categories` retournee par le backend.
  static List<String> _parseCategorieIds(Map<String, dynamic> json) {
    final raw = json['categorie_ids'] ?? json['categorieIds'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    final nested = json['categories'];
    if (nested is List) {
      return nested
          .whereType<Map<String, dynamic>>()
          .map((e) => e['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    }
    return [];
  }
}
