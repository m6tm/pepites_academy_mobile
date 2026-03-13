import '../../application/services/sync_service.dart';
import '../../domain/entities/exercice.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/exercice_repository.dart';
import '../datasources/exercice_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implémentation locale du repository d'exercices.
/// Délégué les opérations au datasource local et gère la synchronisation.
class ExerciceRepositoryImpl implements ExerciceRepository {
  final ExerciceLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;

  ExerciceRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Injecte le client HTTP.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  @override
  Future<List<Exercice>> getByAtelierId(String atelierId) async {
    final local = await _datasource.getByAtelier(atelierId);
    if (local.isEmpty && _dioClient != null) {
      // Stratégie cache-first : si vide, on tente de synchroniser
      await syncFromApi();
      return _datasource.getByAtelier(atelierId);
    }
    return local;
  }

  @override
  Future<Exercice?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<Exercice> create(Exercice exercice) async {
    final created = await _datasource.add(exercice);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.exercice,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Exercice> update(Exercice exercice) async {
    final updated = await _datasource.update(exercice);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.exercice,
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
      entityType: SyncEntityType.exercice,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<void> reorder(String atelierId, List<String> exerciceIds) async {
    await _datasource.reorder(atelierId, exerciceIds);

    // Enregistre l'opération de réordonnancement pour synchronisation
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.exercice,
      entityId: atelierId, // On utilise l'ID de l'atelier comme référence
      operationType: SyncOperationType.reorder,
      data: {'atelier_id': atelierId, 'exercice_ids': exerciceIds},
    );
  }

  /// Synchronise les exercices depuis le backend vers le cache local.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.exercices);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[ExerciceRepo] Erreur sync: ${failure.message}');
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

          final exercices = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => Exercice.fromJson(map))
              .where((e) => e.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(exercices);
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ExerciceRepo] Exception sync: $e');
      return false;
    }
  }

  /// Met à jour le cache local avec les exercices provenant de l'API.
  Future<void> upsertAllFromRemote(List<Exercice> exercices) async {
    await _datasource.upsertAll(exercices);
  }
}
