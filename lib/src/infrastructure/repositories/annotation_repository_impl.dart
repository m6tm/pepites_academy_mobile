import '../../domain/entities/annotation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../datasources/annotation_local_datasource.dart';

/// Implementation locale du repository d'annotations.
/// Delegue les operations au datasource local.
class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationLocalDatasource _datasource;

  AnnotationRepositoryImpl(this._datasource);

  @override
  Future<Annotation> create(Annotation annotation) async {
    return _datasource.add(annotation);
  }

  @override
  Future<List<Annotation>> getByAcademicien(String academicienId) async {
    return _datasource.getByAcademicien(academicienId);
  }

  @override
  Future<List<Annotation>> getByAtelier(String atelierId) async {
    return _datasource.getByAtelier(atelierId);
  }

  @override
  Future<List<Annotation>> getBySeance(String seanceId) async {
    return _datasource.getBySeance(seanceId);
  }

  /// Recupere les annotations d'un academicien pour un atelier specifique.
  Future<List<Annotation>> getByAcademicienAndAtelier(
    String academicienId,
    String atelierId,
  ) async {
    return _datasource.getByAcademicienAndAtelier(academicienId, atelierId);
  }

  /// Met a jour une annotation existante.
  Future<Annotation> update(Annotation annotation) async {
    return _datasource.update(annotation);
  }

  /// Supprime une annotation.
  Future<void> delete(String id) async {
    return _datasource.delete(id);
  }
}
