import '../entities/dossier_medical.dart';

/// Contrat du repository pour la gestion des dossiers medicaux.
abstract class DossierMedicalRepository {
  /// Retourne la liste des dossiers medicaux d'un academicien.
  Future<List<DossierMedical>> getByAcademicienId(String academicienId);

  /// Retourne un dossier medical par son ID.
  Future<DossierMedical?> getById(String id);

  /// Cree un nouveau dossier medical.
  Future<DossierMedical> create(DossierMedical dossier);

  /// Met a jour un dossier medical existant.
  Future<DossierMedical> update(DossierMedical dossier);

  /// Supprime un dossier medical.
  Future<void> delete(String id);
}
