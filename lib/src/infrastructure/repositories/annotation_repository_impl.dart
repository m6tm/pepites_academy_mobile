import '../../application/services/sync_service.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../datasources/annotation_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;

  AnnotationRepositoryImpl(this._datasource);

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setDioClient(DioClient client) {
    _dioClient = client;
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
  Future<List<Annotation>> getAll() async {
    final list = _datasource.getAll();
    list.sort((a, b) => b.horodate.compareTo(a.horodate));
    return list;
  }

  @override
  Future<List<Annotation>> getByAcademicien(String academicienId) async {
    return _datasource.getByAcademicien(academicienId);
  }

  @override
  Future<List<Annotation>> getByEncadreur(String encadreurId) async {
    final list =
        _datasource.getAll().where((a) => a.encadreurId == encadreurId).toList()
          ..sort((a, b) => b.horodate.compareTo(a.horodate));
    return list;
  }

  @override
  Future<List<Annotation>> getByAtelier(String atelierId) async {
    return _datasource.getByAtelier(atelierId);
  }

  @override
  Future<List<Annotation>> getBySeance(String seanceId) async {
    return _datasource.getBySeance(seanceId);
  }

  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.annotations);

      return result.fold(
        (failure) {
          return false;
        },
        (data) async {
          final List<dynamic> rawList;
          if (data is List) {
            rawList = data;
          } else if (data is Map<String, dynamic>) {
            rawList = data.values.whereType<List>().expand((e) => e).toList();
          } else {
            return false;
          }

          final remote = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => Annotation.fromJson(map))
              .where((a) => a.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          return true;
        },
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Annotation>> getByAcademicienAndAtelier(
    String academicienId,
    String atelierId,
  ) async {
    return _datasource.getByAcademicienAndAtelier(academicienId, atelierId);
  }

  @override
  Future<List<Annotation>> getByExercice(String exerciceId) async {
    return _datasource.getByExercice(exerciceId);
  }

  @override
  Future<List<Annotation>> getByAcademicienAndExercice(
    String academicienId,
    String exerciceId,
  ) async {
    return _datasource.getByAcademicienAndExercice(academicienId, exerciceId);
  }

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