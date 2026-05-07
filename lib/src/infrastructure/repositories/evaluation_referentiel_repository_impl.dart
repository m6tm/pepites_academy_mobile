import '../../domain/entities/critere_evaluation.dart';
import '../../domain/repositories/evaluation_referentiel_repository.dart';
import '../datasources/evaluation_referentiel_local_datasource.dart';

/// Implementation du repository de lecture du referentiel d'evaluation.
/// Delegue au datasource local qui contient le referentiel seede.
class EvaluationReferentielRepositoryImpl
    implements EvaluationReferentielRepository {
  final EvaluationReferentielLocalDatasource _datasource;

  EvaluationReferentielRepositoryImpl(this._datasource);

  @override
  Future<List<CritereEvaluation>> getAllCriteres() async {
    return _datasource.getAll();
  }

  @override
  Future<CritereEvaluation?> getCritereById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<ElementEvaluation>> getElementsByCritereId(
    String critereId,
  ) async {
    return _datasource.getElementsByCritereId(critereId);
  }

  @override
  Future<ElementEvaluation?> getElementById(String id) async {
    return _datasource.getElementById(id);
  }
}
