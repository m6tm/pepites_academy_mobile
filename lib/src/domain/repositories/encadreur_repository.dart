import '../entities/encadreur.dart';

/// Contrat pour la gestion des encadreurs.
abstract class EncadreurRepository {
  /// Récupère un encadreur par son identifiant.
  Future<Encadreur?> getById(String id);

  /// Récupère la liste de tous les encadreurs.
  Future<List<Encadreur>> getAll();

  /// Crée un nouvel encadreur.
  Future<Encadreur> create(Encadreur encadreur);

  /// Met à jour les informations d'un encadreur.
  Future<Encadreur> update(Encadreur encadreur);

  /// Récupère un encadreur via son code QR.
  Future<Encadreur?> getByQrCode(String qrCode);
}
