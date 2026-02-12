/// Représente un niveau scolaire ou académique (ex: CM1, 6ème, etc.).
class NiveauScolaire {
  /// Identifiant unique du niveau.
  final String id;

  /// Nom du niveau (ex: "6ème").
  final String nom;

  /// Ordre d'affichage dans les listes (ex: 1 pour CP, 2 pour CE1...).
  final int ordreAffichage;

  const NiveauScolaire({
    required this.id,
    required this.nom,
    required this.ordreAffichage,
  });
}
