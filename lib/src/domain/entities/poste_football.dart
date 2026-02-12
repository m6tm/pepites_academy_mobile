/// Représente un poste de jeu au football (Gardien, Défenseur, etc.).
class PosteFootball {
  final String id;
  final String nom;
  final String? description;
  final String? icone;

  PosteFootball({
    required this.id,
    required this.nom,
    this.description,
    this.icone,
  });
}
