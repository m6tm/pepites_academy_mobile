import '../../domain/entities/annotation.dart';
import '../../infrastructure/repositories/annotation_repository_impl.dart';

class AnnotationService {
  final AnnotationRepositoryImpl _annotationRepository;

  AnnotationService({required AnnotationRepositoryImpl annotationRepository})
    : _annotationRepository = annotationRepository;

  Future<Annotation> creerAnnotation({
    required List<ScoreAnnotation> scores,
    String? commentaire,
    required String academicienId,
    required String atelierId,
    String? exerciceId,
    required String seanceId,
    required String encadreurId,
  }) async {
    final annotation = Annotation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scores: scores,
      commentaire: commentaire,
      academicienId: academicienId,
      atelierId: atelierId,
      exerciceId: exerciceId,
      seanceId: seanceId,
      encadreurId: encadreurId,
      horodate: DateTime.now(),
    );

    return _annotationRepository.create(annotation);
  }

  Future<List<Annotation>> getAnnotationsAcademicien(
    String academicienId,
  ) async {
    return _annotationRepository.getByAcademicien(academicienId);
  }

  Future<List<Annotation>> getAnnotationsAcademicienParAtelier(
    String academicienId,
    String atelierId,
  ) async {
    return _annotationRepository.getByAcademicienAndAtelier(
      academicienId,
      atelierId,
    );
  }

  Future<List<Annotation>> getAnnotationsAcademicienParExercice(
    String academicienId,
    String exerciceId,
  ) async {
    return _annotationRepository.getByAcademicienAndExercice(
      academicienId,
      exerciceId,
    );
  }

  Future<List<Annotation>> getAnnotationsAtelier(String atelierId) async {
    return _annotationRepository.getByAtelier(atelierId);
  }

  Future<List<Annotation>> getAnnotationsExercice(String exerciceId) async {
    return _annotationRepository.getByExercice(exerciceId);
  }

  Future<List<Annotation>> getAnnotationsSeance(String seanceId) async {
    return _annotationRepository.getBySeance(seanceId);
  }

  Future<Annotation> modifierAnnotation(Annotation annotation) async {
    return _annotationRepository.update(annotation);
  }

  Future<void> supprimerAnnotation(String id) async {
    return _annotationRepository.delete(id);
  }
}