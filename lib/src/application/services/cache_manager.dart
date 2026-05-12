import '../../infrastructure/datasources/clearable_datasource.dart';
import '../../infrastructure/repositories/seance_repository_impl.dart';
import 'atelier_service.dart';
import 'exercice_service.dart';

class CacheManager {
  final List<ClearableDatasource> _datasources;
  final AtelierService _atelierService;
  final ExerciceService _exerciceService;
  final SeanceRepositoryImpl? _seanceRepository;

  CacheManager(
    this._datasources,
    this._atelierService,
    this._exerciceService, [
    this._seanceRepository,
  ]);

  Future<void> clearAll() async {
    for (final datasource in _datasources) {
      try {
        await datasource.clearCache();
      } catch (e) {
        // ignore: avoid_print
        print('[CacheManager] Erreur lors du vidage du cache datasource: $e');
      }
    }

    try {
      _atelierService.reset();
    } catch (e) {
      // ignore: avoid_print
      print('[CacheManager] Erreur lors de la reinitialisation du service atelier: $e');
    }

    try {
      _exerciceService.reset();
    } catch (e) {
      // ignore: avoid_print
      print('[CacheManager] Erreur lors de la reinitialisation du service exercice: $e');
    }

    try {
      _seanceRepository?.clearCache();
    } catch (e) {
      // ignore: avoid_print
      print('[CacheManager] Erreur lors du vidage du cache seance: $e');
    }
  }
}
