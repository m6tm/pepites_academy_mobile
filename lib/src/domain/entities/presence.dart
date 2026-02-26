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

  /// Serialise la presence en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'horodateArrivee': horodateArrivee.toIso8601String(),
      'typeProfil': typeProfil.name,
      'profilId': profilId,
      'seanceId': seanceId,
    };
  }

  factory Presence.fromJson(Map<String, dynamic> json) {
    return Presence(
      id: json['id'] as String,
      horodateArrivee: DateTime.parse(
        (json['horodateArrivee'] ?? json['horodate_arrivee']) as String,
      ),
      typeProfil: ProfilType.values.firstWhere(
        (e) => e.name == (json['typeProfil'] ?? json['type_profil']),
      ),
      profilId: (json['profilId'] ?? json['profil_id']) as String,
      seanceId: (json['seanceId'] ?? json['seance_id']) as String,
    );
  }
}
