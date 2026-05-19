import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../domain/entities/critere_evaluation.dart';
import '../../domain/repositories/evaluation_referentiel_repository.dart';
import '../datasources/evaluation_referentiel_local_datasource.dart';

/// Implementation du repository de lecture du referentiel d'evaluation.
/// Delegue au datasource local qui contient le referentiel seede.
class EvaluationReferentielRepositoryImpl
    implements EvaluationReferentielRepository {
  final EvaluationReferentielLocalDatasource _datasource;

  final _cacheCriteres = RepositoryCache<List<CritereEvaluation>>();
  final _cacheCritere = RepositoryCache<CritereEvaluation>();
  final _cacheElements = RepositoryCache<List<ElementEvaluation>>();
  final _cacheElement = RepositoryCache<ElementEvaluation>();

  EvaluationReferentielRepositoryImpl(this._datasource);

  @override
  Future<List<CritereEvaluation>> getAllCriteres() async {
    const key = 'all';
    final cached = _cacheCriteres.get(key);
    if (cached != null) return cached;

    final result = _datasource.getAll();
    _cacheCriteres.set(key, result, ttl: CacheTtl.referentiel, tags: {'referentiel', 'criteres'});
    return result;
  }

  @override
  Future<CritereEvaluation?> getCritereById(String id) async {
    final cached = _cacheCritere.get(id);
    if (cached != null) return cached;

    final result = _datasource.getById(id);
    if (result != null) {
      _cacheCritere.set(id, result, ttl: CacheTtl.referentiel, tags: {'referentiel', 'critere_$id'});
    }
    return result;
  }

  @override
  Future<List<ElementEvaluation>> getElementsByCritereId(
    String critereId,
  ) async {
    final key = 'critere_$critereId';
    final cached = _cacheElements.get(key);
    if (cached != null) return cached;

    final result = _datasource.getElementsByCritereId(critereId);
    _cacheElements.set(key, result, ttl: CacheTtl.referentiel, tags: {'referentiel', 'elements', 'critere_$critereId'});
    return result;
  }

  @override
  Future<ElementEvaluation?> getElementById(String id) async {
    final cached = _cacheElement.get(id);
    if (cached != null) return cached;

    final result = _datasource.getElementById(id);
    if (result != null) {
      _cacheElement.set(id, result, ttl: CacheTtl.referentiel, tags: {'referentiel', 'element_$id'});
    }
    return result;
  }

  void clearCache() {
    _cacheCriteres.clear();
    _cacheCritere.clear();
    _cacheElements.clear();
    _cacheElement.clear();
  }
}
