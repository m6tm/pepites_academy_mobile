import '../entities/exercice.dart';

/// Contrat pour la gestion des exercices au sein d'un atelier.
abstract class ExerciceRepository {
  /// Recupere tous les exercices d'un atelier.
  Future<List<Exercice>> getByAtelierId(String atelierId);

  /// Recupere un exercice par son identifiant.
  Future<Exercice?> getById(String id);

  /// Cree un nouvel exercice.
  Future<Exercice> create(Exercice exercice);

  /// Met a jour un exercice existant.
  Future<Exercice> update(Exercice exercice);

  /// Supprime un exercice par son identifiant.
  Future<void> delete(String id);

  /// Reordonne les exercices d'un atelier.
  Future<void> reorder(String atelierId, List<String> exerciceIds);

  /// Ferme un exercice (statut 'ferme').
  /// Retourne un flag indiquant si l'atelier a été fermé automatiquement.
  Future<bool> close(String id);
}
