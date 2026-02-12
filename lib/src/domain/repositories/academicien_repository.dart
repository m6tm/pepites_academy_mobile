import '../entities/academicien.dart';

/// Contrat pour la gestion des académiciens.
abstract class AcademicienRepository {
  /// Récupère un académicien par son identifiant.
  Future<Academicien?> getById(String id);

  /// Récupère la liste de tous les académiciens.
  Future<List<Academicien>> getAll();

  /// Crée un nouvel académicien.
  Future<Academicien> create(Academicien academicien);

  /// Met à jour les informations d'un académicien.
  Future<Academicien> update(Academicien academicien);

  /// Récupère un académicien via son code QR.
  Future<Academicien?> getByQrCode(String qrCode);

  /// Recherche des académiciens par nom ou prénom.
  Future<List<Academicien>> search(String query);
}
