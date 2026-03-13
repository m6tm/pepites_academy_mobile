import 'enums/atelier_statut.dart';
import 'enums/atelier_type.dart';
export 'enums/atelier_statut.dart';
export 'enums/atelier_type.dart';

class Atelier {
  final String id;
  final String nom;
  final String description;
  final AtelierType type;
  final String? icone;
  final int ordre;
  final AtelierStatut statut;
  final String seanceId;

  const Atelier({
    required this.id,
    required this.nom,
    required this.description,
    required this.type,
    this.icone,
    required this.ordre,
    required this.statut,
    required this.seanceId,
  });

  String get typeLabel => type.label;

  /// Cree une copie de l'atelier avec des champs modifies.
  Atelier copyWith({
    String? id,
    String? nom,
    String? description,
    AtelierType? type,
    String? icone,
    int? ordre,
    AtelierStatut? statut,
    String? seanceId,
  }) {
    return Atelier(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      type: type ?? this.type,
      icone: icone ?? this.icone,
      ordre: ordre ?? this.ordre,
      statut: statut ?? this.statut,
      seanceId: seanceId ?? this.seanceId,
    );
  }

  /// Serialise l'atelier en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'type': type.name,
      'icone': icone,
      'ordre': ordre,
      'statut': statut.name,
      'seanceId': seanceId,
    };
  }

  /// Deserialise un atelier depuis un Map JSON.
  factory Atelier.fromJson(Map<String, dynamic> json) {
    return Atelier(
      id: json['id'] as String,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: AtelierType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AtelierType.personnalise,
      ),
      icone: json['icone'] as String?,
      ordre: json['ordre'] as int? ?? 0,
      statut: AtelierStatut.values.firstWhere(
        (e) => e.name == json['statut'],
        orElse: () => AtelierStatut.cree,
      ),
      seanceId: (json['seance_id'] ?? json['seanceId']) as String,
    );
  }
}
