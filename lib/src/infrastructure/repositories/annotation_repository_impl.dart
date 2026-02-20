import '../../application/services/sync_service.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../datasources/annotation_local_datasource.dart';

/// Implementation locale du repository d'annotations.
/// Delegue les operations au datasource local.
class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationLocalDatasource _datasource;
  SyncService? _syncService;

  AnnotationRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<Annotation> create(Annotation annotation) async {
    final created = await _datasource.add(annotation);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.annotation,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
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
    final updated = await _datasource.update(annotation);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.annotation,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  /// Supprime une annotation.
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.annotation,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }
}
