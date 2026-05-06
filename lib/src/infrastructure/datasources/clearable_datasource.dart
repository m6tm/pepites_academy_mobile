/// Interface commune pour les datasources qui peuvent etre videes lors du logout.
///
/// Toute datasource qui stocke des donnees utilisateur en cache doit implementer
/// cette interface pour garantir que les donnees sont correctement effacees lors
/// de la deconnexion.
abstract class ClearableDatasource {
  /// Vide completement le cache de cette datasource.
  ///
  /// Cette methode doit supprimer toutes les donnees stockees dans SharedPreferences,
  /// Hive ou tout autre mecanisme de persistance utilise par la datasource.
  Future<void> clearCache();
}
