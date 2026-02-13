import '../entities/atelier.dart';

/// Contrat pour la gestion des ateliers d'entrainement.
abstract class AtelierRepository {
  /// Recupere tous les ateliers d'une seance.
  Future<List<Atelier>> getBySeance(String seanceId);

  /// Recupere un atelier par son identifiant.
  Future<Atelier?> getById(String id);

  /// Cree un nouvel atelier.
  Future<Atelier> create(Atelier atelier);

  /// Met a jour un atelier existant.
  Future<Atelier> update(Atelier atelier);

  /// Supprime un atelier par son identifiant.
  Future<void> delete(String id);

  /// Reordonne les ateliers d'une seance.
  Future<void> reorder(String seanceId, List<String> atelierIds);
}
