import '../../domain/entities/evaluation.dart';
import '../../domain/entities/atelier.dart';
import '../../infrastructure/repositories/evaluation_repository_impl.dart';
import '../../infrastructure/repositories/atelier_repository_impl.dart';

/// Service applicatif gerant la logique metier des evaluations multicriteres.
/// Orchestre la creation, la validation et la consultation des evaluations.
class EvaluationService {
  final EvaluationRepositoryImpl _evaluationRepository;
  final AtelierRepositoryImpl _atelierRepository;

  EvaluationService({
    required EvaluationRepositoryImpl evaluationRepository,
    required AtelierRepositoryImpl atelierRepository,
  })  : _evaluationRepository = evaluationRepository,
        _atelierRepository = atelierRepository;

  /// Cree une evaluation multicritere pour un academicien sur un atelier.
  /// Valide que l'atelier possede une configuration complete et que les
  /// elements notes correspondent a ceux configures.
  Future<Evaluation> creerEvaluation({
    required String academicienId,
    required String atelierId,
    required String seanceId,
    required String encadreurId,
    required List<ScoreCritere> scores,
    String? commentaire,
  }) async {
    final atelier = await _atelierRepository.getById(atelierId);
    if (atelier == null) {
      throw Exception('Atelier introuvable : $atelierId');
    }

    if (!atelier.configurationEvaluationComplete) {
      throw Exception(
        'L\'atelier n\'a pas de configuration d\'evaluation complete.',
      );
    }

    _validerScores(scores, atelier.configurationEvaluation!);

    final evaluation = Evaluation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      academicienId: academicienId,
      atelierId: atelierId,
      seanceId: seanceId,
      encadreurId: encadreurId,
      horodate: DateTime.now(),
      scores: scores,
      commentaire: commentaire,
    );

    return _evaluationRepository.create(evaluation);
  }

  /// Recupere les evaluations d'un academicien (historique complet).
  Future<List<Evaluation>> getEvaluationsAcademicien(
    String academicienId,
  ) async {
    return _evaluationRepository.getByAcademicien(academicienId);
  }

  /// Recupere les evaluations d'un atelier.
  Future<List<Evaluation>> getEvaluationsAtelier(String atelierId) async {
    return _evaluationRepository.getByAtelier(atelierId);
  }

  /// Recupere les evaluations d'une seance.
  Future<List<Evaluation>> getEvaluationsSeance(String seanceId) async {
    return _evaluationRepository.getBySeance(seanceId);
  }

  /// Recupere les evaluations d'un academicien pour un atelier donne.
  Future<List<Evaluation>> getEvaluationsAcademicienParAtelier(
    String academicienId,
    String atelierId,
  ) async {
    return _evaluationRepository.getByAcademicienAndAtelier(
      academicienId,
      atelierId,
    );
  }

  /// Recupere une evaluation par son identifiant.
  Future<Evaluation?> getEvaluationById(String id) async {
    return _evaluationRepository.getById(id);
  }

  /// Met a jour une evaluation existante.
  Future<Evaluation> modifierEvaluation(Evaluation evaluation) async {
    return _evaluationRepository.update(evaluation);
  }

  /// Supprime une evaluation.
  Future<void> supprimerEvaluation(String id) async {
    return _evaluationRepository.delete(id);
  }

  /// Valide que les scores correspondent a la configuration de l'atelier.
  void _validerScores(
    List<ScoreCritere> scores,
    List<ConfigurationElementEvaluation> configuration,
  ) {
    final configMap = <String, ConfigurationElementEvaluation>{
      for (final c in configuration) c.critereId: c
    };

    if (scores.length != configMap.length) {
      throw Exception('${configMap.length} scores requis (un par critere).');
    }

    for (final score in scores) {
      final config = configMap[score.critereId];
      if (config == null) {
        throw Exception('Critere non configure : ${score.critereId}');
      }

      final elementsConfigures = config.elementIds.toSet();
      final elementsNotes = score.elements.map((e) => e.elementId).toSet();
      if (!elementsConfigures.containsAll(elementsNotes)) {
        throw Exception(
          'Les elements notes ne correspondent pas a la configuration '
          'du critere ${score.critereId}.',
        );
      }

      for (final element in score.elements) {
        if (element.note < 0 || element.note > 5) {
          throw Exception('La note doit etre entre 0 et 5.');
        }
      }
    }
  }
}
