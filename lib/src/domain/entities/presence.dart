/// Type de profil scanné.
enum TypeProfil { academicien, encadreur }

/// Représente l'enregistrement d'accès au stade via scan QR.
class Presence {
  /// Identifiant unique de la présence.
  final String id;

  /// Date et heure du scan.
  final DateTime dateHeure;

  /// Type de profil scanné (Académicien ou Encadreur).
  final TypeProfil typeProfil;

  /// Identifiant du profil concerné (ID Académicien ou ID Encadreur).
  final String profilId;

  /// Identifiant de la séance rattachée (optionnel si hors séance).
  final String? seanceId;

  const Presence({
    required this.id,
    required this.dateHeure,
    required this.typeProfil,
    required this.profilId,
    this.seanceId,
  });
}
