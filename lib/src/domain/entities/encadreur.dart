/// Représente un coach ou formateur de l'académie.
class Encadreur {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String photoUrl;
  final String specialite; // Ex: Technique, Physique, Gardien, etc.
  final String role; // Ex: admin, encadreur
  final String codeQrUnique;

  Encadreur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.photoUrl,
    required this.specialite,
    required this.role,
    required this.codeQrUnique,
  });
}
