import '../entities/atelier.dart';
import '../entities/seance.dart';

/// Contrat pour la gestion des séances et des ateliers.
abstract class SeanceRepository {
  /// Récupère une séance par son identifiant.
  Future<Seance?> getById(String id);

  /// Récupère la liste de toutes les séances.
  Future<List<Seance>> getAll();

  /// Crée une nouvelle séance.
  Future<Seance> create(Seance seance);

  /// Met à jour une séance existante.
  Future<Seance> update(Seance seance);

  /// Clôture une séance.
  Future<void> close(String id);

  /// Ajoute un atelier à une séance.
  Future<Atelier> addAtelier(String seanceId, Atelier atelier);

  /// Supprime un atelier.
  Future<void> removeAtelier(String atelierId);

  /// Réorganise les ateliers d'une séance.
  Future<void> reorderAteliers(String seanceId, List<String> atelierIdsOrdered);
}
