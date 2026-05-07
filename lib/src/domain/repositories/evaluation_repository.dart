import '../entities/evaluation.dart';

/// Contrat pour la gestion des evaluations multicriteres.
abstract class EvaluationRepository {
  /// Cree une nouvelle evaluation.
  Future<Evaluation> create(Evaluation evaluation);

  /// Recupere une evaluation par son identifiant.
  Future<Evaluation?> getById(String id);

  /// Recupere toutes les evaluations d'un academicien.
  Future<List<Evaluation>> getByAcademicien(String academicienId);

  /// Recupere toutes les evaluations d'un atelier.
  Future<List<Evaluation>> getByAtelier(String atelierId);

  /// Recupere toutes les evaluations d'une seance.
  Future<List<Evaluation>> getBySeance(String seanceId);

  /// Recupere les evaluations filtrees par academicien et atelier.
  Future<List<Evaluation>> getByAcademicienAndAtelier(
    String academicienId,
    String atelierId,
  );

  /// Met a jour une evaluation existante.
  Future<Evaluation> update(Evaluation evaluation);

  /// Supprime une evaluation.
  Future<void> delete(String id);
}
