import '../entities/categorie_joueur.dart';

/// Contrat pour la gestion des categories de joueurs.
abstract class CategorieJoueurRepository {
  /// Recupere la liste de toutes les categories.
  Future<List<CategorieJoueur>> getAll();

  /// Recupere une categorie par son identifiant.
  Future<CategorieJoueur?> getById(String id);

  /// Cree une nouvelle categorie.
  Future<CategorieJoueur> create(CategorieJoueur categorie);

  /// Met a jour une categorie existante.
  Future<CategorieJoueur> update(CategorieJoueur categorie);

  /// Supprime une categorie par son identifiant.
  Future<void> delete(String id);
}
