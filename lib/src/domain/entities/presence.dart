/// Représente l'enregistrement d'une présence via scan QR.
enum ProfilType { academicien, encadreur }

class Presence {
  final String id;
  final DateTime horodateArrivee;
  final ProfilType typeProfil;
  final String profilId; // ID de l'académicien ou de l'encadreur
  final String seanceId;

  Presence({
    required this.id,
    required this.horodateArrivee,
    required this.typeProfil,
    required this.profilId,
    required this.seanceId,
  });
}
