import 'niveau_scolaire.dart';
import 'poste_football.dart';

/// Représente un élève inscrit à l'académie.
class Academicien {
  /// Identifiant unique de l'académicien.
  final String id;

  /// Nom de famille.
  final String nom;

  /// Prénom.
  final String prenom;

  /// Date de naissance.
  final DateTime dateNaissance;

  /// Chemin ou URL de la photo de profil.
  final String? photo;

  /// Numéro de téléphone du parent.
  final String telephoneParent;

  /// Poste de football favori.
  final PosteFootball? posteFootball;

  /// Niveau scolaire actuel.
  final NiveauScolaire? niveauScolaire;

  /// Code contenu dans le QR Code unique.
  final String codeQr;

  const Academicien({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.telephoneParent,
    required this.codeQr,
    this.photo,
    this.posteFootball,
    this.niveauScolaire,
  });
}
