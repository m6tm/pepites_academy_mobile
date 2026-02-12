/// Représente une séance d'entraînement.
enum SeanceStatus { ouverte, fernee, aVenir }

class Seance {
  final String id;
  final DateTime date;
  final DateTime heureDebut;
  final DateTime heureFin;
  final SeanceStatus statut;
  final String
  encadreurResponsableId; // ID de l'encadreur qui a ouvert la séance

  Seance({
    required this.id,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.statut,
    required this.encadreurResponsableId,
  });
}
