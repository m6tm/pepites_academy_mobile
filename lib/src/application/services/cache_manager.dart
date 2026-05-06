import '../../infrastructure/datasources/clearable_datasource.dart';
import 'atelier_service.dart';
import 'exercice_service.dart';

/// Service de gestion centralisee des caches applicatifs.
///
/// Ce service coordonne le vidage de tous les caches locaux lors de la
/// deconnexion ou d'autres operations necessitant un nettoyage complet.
///
/// **Contexte du bug :** Avant l'introduction de ce service, lors de la
/// deconnexion, seules les preferences utilisateur (token, role, etc.) etaient
/// effacees via `SharedPreferences.clear()`, mais les datasources locales
/// conservaient leurs caches car elles utilisent des cles specifiques
/// (`academiciens_data`, `ateliers_data`, etc.). Cela causait un bug critique
/// de securite : un nouvel utilisateur heritait des donnees de l'ancien.
class CacheManager {
  final List<ClearableDatasource> _datasources;
  final AtelierService _atelierService;
  final ExerciceService _exerciceService;

  CacheManager(
    this._datasources,
    this._atelierService,
    this._exerciceService,
  );

  /// Vide tous les caches geres par les datasources enregistrees.
  ///
  /// Cette methode doit etre appelee lors de la deconnexion pour garantir
  /// qu'aucune donnee de l'utilisateur precedent ne persiste en memoire.
  Future<void> clearAll() async {
    // 1. Vider les caches de donnees (datasources)
    for (final datasource in _datasources) {
      try {
        await datasource.clearCache();
      } catch (e) {
        // Log mais ne bloque pas le processus de deconnexion
        // ignore: avoid_print
        print('[CacheManager] Erreur lors du vidage du cache datasource: $e');
      }
    }

    // 2. Vider les StreamControllers des services
    try {
      _atelierService.dispose();
    } catch (e) {
      // ignore: avoid_print
      print('[CacheManager] Erreur lors du vidage du stream atelier: $e');
    }

    try {
      _exerciceService.dispose();
    } catch (e) {
      // ignore: avoid_print
      print('[CacheManager] Erreur lors du vidage du stream exercice: $e');
    }
  }
}
