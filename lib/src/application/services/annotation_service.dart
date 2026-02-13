import '../../domain/entities/annotation.dart';
import '../../infrastructure/repositories/annotation_repository_impl.dart';

/// Service applicatif gerant la logique metier des annotations.
/// Permet de creer, consulter et gerer les observations
/// faites par les encadreurs sur les academiciens.
class AnnotationService {
  final AnnotationRepositoryImpl _annotationRepository;

  AnnotationService({
    required AnnotationRepositoryImpl annotationRepository,
  }) : _annotationRepository = annotationRepository;

  /// Cree une nouvelle annotation pour un academicien dans un atelier.
  Future<Annotation> creerAnnotation({
    required String contenu,
    required List<String> tags,
    double? note,
    required String academicienId,
    required String atelierId,
    required String seanceId,
    required String encadreurId,
  }) async {
    final annotation = Annotation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contenu: contenu,
      tags: tags,
      note: note,
      academicienId: academicienId,
      atelierId: atelierId,
      seanceId: seanceId,
      encadreurId: encadreurId,
      horodate: DateTime.now(),
    );

    return _annotationRepository.create(annotation);
  }

  /// Recupere les annotations d'un academicien (historique complet).
  Future<List<Annotation>> getAnnotationsAcademicien(
    String academicienId,
  ) async {
    return _annotationRepository.getByAcademicien(academicienId);
  }

  /// Recupere les annotations d'un academicien pour un atelier specifique.
  Future<List<Annotation>> getAnnotationsAcademicienParAtelier(
    String academicienId,
    String atelierId,
  ) async {
    return _annotationRepository.getByAcademicienAndAtelier(
      academicienId,
      atelierId,
    );
  }

  /// Recupere toutes les annotations d'un atelier.
  Future<List<Annotation>> getAnnotationsAtelier(String atelierId) async {
    return _annotationRepository.getByAtelier(atelierId);
  }

  /// Recupere toutes les annotations d'une seance.
  Future<List<Annotation>> getAnnotationsSeance(String seanceId) async {
    return _annotationRepository.getBySeance(seanceId);
  }

  /// Met a jour une annotation existante.
  Future<Annotation> modifierAnnotation(Annotation annotation) async {
    return _annotationRepository.update(annotation);
  }

  /// Supprime une annotation.
  Future<void> supprimerAnnotation(String id) async {
    return _annotationRepository.delete(id);
  }
}
