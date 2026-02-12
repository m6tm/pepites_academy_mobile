import '../entities/annotation.dart';

/// Contrat pour la gestion des annotations.
abstract class AnnotationRepository {
  /// Crée une nouvelle annotation.
  Future<Annotation> create(Annotation annotation);

  /// Récupère les annotations d'un académicien.
  Future<List<Annotation>> getByAcademicien(String academicienId);

  /// Récupère les annotations faites lors d'un atelier spécifique.
  Future<List<Annotation>> getByAtelier(String atelierId);

  /// Récupère les annotations faites lors d'une séance spécifique.
  Future<List<Annotation>> getBySeance(String seanceId);
}
