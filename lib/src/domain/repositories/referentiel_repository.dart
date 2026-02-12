import '../entities/niveau_scolaire.dart';
import '../entities/poste_football.dart';

/// Contrat pour la gestion des référentiels (Postes et Niveaux).
abstract class ReferentielRepository {
  // --- Postes de Football ---

  /// Récupère la liste des postes de football.
  Future<List<PosteFootball>> getPostes();

  /// Ajoute un nouveau poste de football.
  Future<PosteFootball> addPoste(PosteFootball poste);

  /// Supprime un poste de football par son ID.
  Future<void> removePoste(String id);

  // --- Niveaux Scolaires ---

  /// Récupère la liste des niveaux scolaires.
  Future<List<NiveauScolaire>> getNiveaux();

  /// Ajoute un nouveau niveau scolaire.
  Future<NiveauScolaire> addNiveau(NiveauScolaire niveau);

  /// Supprime un niveau scolaire par son ID.
  Future<void> removeNiveau(String id);
}
