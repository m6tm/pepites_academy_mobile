import '../entities/bulletin.dart';

/// Contrat pour la gestion des bulletins de formation.
abstract class BulletinRepository {
  /// Cree un nouveau bulletin.
  Future<Bulletin> create(Bulletin bulletin);

  /// Met a jour un bulletin existant.
  Future<Bulletin> update(Bulletin bulletin);

  /// Recupere un bulletin par son identifiant.
  Future<Bulletin?> getById(String id);

  /// Recupere les bulletins d'un academicien.
  Future<List<Bulletin>> getByAcademicien(String academicienId);

  /// Recupere tous les bulletins.
  Future<List<Bulletin>> getAll();

  /// Supprime un bulletin.
  Future<void> delete(String id);
}
