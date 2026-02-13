import '../entities/seance.dart';

/// Contrat pour la gestion des seances d'entrainement.
abstract class SeanceRepository {
  /// Recupere une seance par son identifiant.
  Future<Seance?> getById(String id);

  /// Recupere la liste de toutes les seances.
  Future<List<Seance>> getAll();

  /// Recupere la seance actuellement ouverte (s'il y en a une).
  Future<Seance?> getSeanceOuverte();

  /// Cree une nouvelle seance.
  Future<Seance> create(Seance seance);

  /// Met a jour une seance existante.
  Future<Seance> update(Seance seance);

  /// Ouvre une seance (passe son statut a ouverte).
  Future<Seance> ouvrir(String id);

  /// Cloture une seance (passe son statut a fermee).
  Future<Seance> fermer(String id);

  /// Supprime une seance.
  Future<void> delete(String id);
}
