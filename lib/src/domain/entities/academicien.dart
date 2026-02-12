/// Représente un élève inscrit à l'académie (Pépites Academy).
class Academicien {
  final String id;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String photoUrl;
  final String telephoneParent;
  final String posteFootballId; // Référence à l'id du poste
  final String niveauScolaireId; // Référence à l'id du niveau scolaire
  final String codeQrUnique;
  final String? piedFort; // Optionnel (Gaucher, Droitier, Ambidextre)

  Academicien({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.photoUrl,
    required this.telephoneParent,
    required this.posteFootballId,
    required this.niveauScolaireId,
    required this.codeQrUnique,
    this.piedFort,
  });
}
