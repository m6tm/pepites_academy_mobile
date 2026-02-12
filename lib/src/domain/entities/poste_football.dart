/// Représente un poste de jeu au football (ex: Gardien, Défenseur central, etc.).
class PosteFootball {
  /// Identifiant unique du poste.
  final String id;

  /// Nom du poste (ex: "Gardien de but").
  final String nom;

  /// Description optionnelle du rôle sur le terrain.
  final String? description;

  /// Chemin ou URL de l'icône représentant le poste.
  final String? icone;

  const PosteFootball({
    required this.id,
    required this.nom,
    this.description,
    this.icone,
  });
}
