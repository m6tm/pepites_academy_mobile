import '../../application/services/sync_service.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../datasources/evaluation_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository d'evaluations multicriteres.
/// Delegue les operations au datasource local avec synchronisation differee.
class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;

  EvaluationRepositoryImpl(this._datasource);

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  @override
  Future<Evaluation> create(Evaluation evaluation) async {
    final created = await _datasource.add(evaluation);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.evaluation,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Evaluation?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Evaluation>> getByAcademicien(String academicienId) async {
    return _datasource.getByAcademicien(academicienId);
  }

  @override
  Future<List<Evaluation>> getByAtelier(String atelierId) async {
    return _datasource.getByAtelier(atelierId);
  }

  @override
  Future<List<Evaluation>> getBySeance(String seanceId) async {
    return _datasource.getBySeance(seanceId);
  }

  @override
  Future<List<Evaluation>> getByAcademicienAndAtelier(
    String academicienId,
    String atelierId,
  ) async {
    return _datasource.getByAcademicienAndAtelier(academicienId, atelierId);
  }

  @override
  Future<Evaluation> update(Evaluation evaluation) async {
    final updated = await _datasource.update(evaluation);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.evaluation,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.evaluation,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Synchronise les evaluations depuis le backend.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.evaluations);

      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[Evaluation] Sync failed: ${failure.message}');
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
              .map((map) => Evaluation.fromJson(map))
              .where((e) => e.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          // ignore: avoid_print
          print('[Evaluation] Synced ${remote.length} items from backend');
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Evaluation] Sync exception: $e');
      return false;
    }
  }
}
