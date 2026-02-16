import '../entities/niveau_scolaire.dart';

/// Contrat pour la gestion des niveaux scolaires.
abstract class NiveauScolaireRepository {
  /// Recupere la liste de tous les niveaux tries par ordre.
  Future<List<NiveauScolaire>> getAll();

  /// Recupere un niveau par son identifiant.
  Future<NiveauScolaire?> getById(String id);

  /// Cree un nouveau niveau.
  Future<NiveauScolaire> create(NiveauScolaire niveau);

  /// Met a jour un niveau existant.
  Future<NiveauScolaire> update(NiveauScolaire niveau);

  /// Supprime un niveau par son identifiant.
  Future<void> delete(String id);

  /// Compte le nombre d'academiciens rattaches a un niveau.
  Future<int> countAcademiciens(String niveauId);
}
