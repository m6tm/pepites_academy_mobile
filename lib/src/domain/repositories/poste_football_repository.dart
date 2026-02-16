import '../entities/poste_football.dart';

/// Contrat pour la gestion des postes de football.
abstract class PosteFootballRepository {
  /// Recupere la liste de tous les postes.
  Future<List<PosteFootball>> getAll();

  /// Recupere un poste par son identifiant.
  Future<PosteFootball?> getById(String id);

  /// Cree un nouveau poste.
  Future<PosteFootball> create(PosteFootball poste);

  /// Met a jour un poste existant.
  Future<PosteFootball> update(PosteFootball poste);

  /// Supprime un poste par son identifiant.
  Future<void> delete(String id);

  /// Compte le nombre d'academiciens rattaches a un poste.
  Future<int> countAcademiciens(String posteId);
}
