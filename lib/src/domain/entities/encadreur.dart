import 'seance.dart';

/// Rôles possibles pour un encadreur.
enum RoleEncadreur { admin, encadreur }

/// Représente un coach ou un formateur.
class Encadreur {
  /// Identifiant unique de l'encadreur.
  final String id;

  /// Nom de famille.
  final String nom;

  /// Prénom.
  final String prenom;

  /// Numéro de téléphone.
  final String telephone;

  /// Chemin ou URL de la photo de profil.
  final String? photo;

  /// Spécialité sportive (ex: technique, physique, gardien).
  final String? specialite;

  /// Rôle déterminant les droits d'accès.
  final RoleEncadreur role;

  /// Code contenu dans le QR Code unique.
  final String codeQr;

  /// Historique des séances dirigées (chargé optionnellement).
  final List<Seance>? seancesDirigees;

  const Encadreur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    required this.codeQr,
    this.photo,
    this.specialite,
    this.seancesDirigees,
  });
}
