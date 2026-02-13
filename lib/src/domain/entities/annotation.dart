/// Represente une observation faite sur un academicien durant un atelier.
class Annotation {
  final String id;
  final String contenu;
  final List<String> tags;
  final double? note;
  final String academicienId;
  final String atelierId;
  final String seanceId;
  final String encadreurId;
  final DateTime horodate;

  Annotation({
    required this.id,
    required this.contenu,
    required this.tags,
    this.note,
    required this.academicienId,
    required this.atelierId,
    required this.seanceId,
    required this.encadreurId,
    required this.horodate,
  });

  /// Cree une copie de l'annotation avec des champs modifies.
  Annotation copyWith({
    String? id,
    String? contenu,
    List<String>? tags,
    double? note,
    String? academicienId,
    String? atelierId,
    String? seanceId,
    String? encadreurId,
    DateTime? horodate,
  }) {
    return Annotation(
      id: id ?? this.id,
      contenu: contenu ?? this.contenu,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      academicienId: academicienId ?? this.academicienId,
      atelierId: atelierId ?? this.atelierId,
      seanceId: seanceId ?? this.seanceId,
      encadreurId: encadreurId ?? this.encadreurId,
      horodate: horodate ?? this.horodate,
    );
  }

  /// Serialise l'annotation en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenu': contenu,
      'tags': tags,
      'note': note,
      'academicienId': academicienId,
      'atelierId': atelierId,
      'seanceId': seanceId,
      'encadreurId': encadreurId,
      'horodate': horodate.toIso8601String(),
    };
  }

  /// Deserialise une annotation depuis un Map JSON.
  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] as String,
      contenu: json['contenu'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      note: (json['note'] as num?)?.toDouble(),
      academicienId: json['academicienId'] as String,
      atelierId: json['atelierId'] as String,
      seanceId: json['seanceId'] as String,
      encadreurId: json['encadreurId'] as String,
      horodate: DateTime.parse(json['horodate'] as String),
    );
  }
}
