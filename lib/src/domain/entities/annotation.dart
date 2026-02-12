/// Représente une observation faite sur un académicien durant un atelier.
class Annotation {
  final String id;
  final String contenu;
  final List<String> tags; // Ex: ["positif", "technique", "excellent"]
  final double? note; // Note optionnelle
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
}
