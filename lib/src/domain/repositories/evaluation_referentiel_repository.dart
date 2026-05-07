import '../entities/critere_evaluation.dart';

/// Contrat pour l'acces en lecture seule au referentiel d'evaluation.
abstract class EvaluationReferentielRepository {
  /// Recupere tous les criteres d'evaluation avec leurs elements.
  Future<List<CritereEvaluation>> getAllCriteres();

  /// Recupere un critere par son identifiant.
  Future<CritereEvaluation?> getCritereById(String id);

  /// Recupere tous les elements d'un critere donne.
  Future<List<ElementEvaluation>> getElementsByCritereId(String critereId);

  /// Recupere un element par son identifiant.
  Future<ElementEvaluation?> getElementById(String id);
}
