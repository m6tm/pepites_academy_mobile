import '../../application/services/sync_service.dart';
import '../../domain/entities/poste_football.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/poste_football_repository.dart';
import '../datasources/poste_football_local_datasource.dart';
import '../datasources/academicien_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation concrete de [PosteFootballRepository] utilisant le stockage local.
class PosteFootballRepositoryImpl implements PosteFootballRepository {
  final PosteFootballLocalDatasource _datasource;
  final AcademicienLocalDatasource _academicienDatasource;
  DioClient? _dioClient;
  SyncService? _syncService;

  PosteFootballRepositoryImpl(this._datasource, this._academicienDatasource);

  /// Injecte le client HTTP pour les appels API.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<List<PosteFootball>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<PosteFootball?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<PosteFootball> create(PosteFootball poste) async {
    final created = await _datasource.add(poste);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.posteFootball,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<PosteFootball> update(PosteFootball poste) async {
    final updated = await _datasource.update(poste);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.posteFootball,
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
      entityType: SyncEntityType.posteFootball,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<int> countAcademiciens(String posteId) async {
    final academiciens = await _academicienDatasource.getAll();
    return academiciens.where((a) => a.posteFootballId == posteId).length;
  }

  /// Synchronise les postes de football depuis le backend vers le cache local.
  /// Retourne true si la synchronisation a reussi.
  Future<bool> syncFromApi() async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.postesFootball);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[PosteFootballRepo] Erreur sync: ${failure.message}');
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

          final postes = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => _parsePosteFootball(map))
              .where((p) => p.id.isNotEmpty)
              .toList();

          await _datasource.saveAll(postes);
          // ignore: avoid_print
          print(
            '[PosteFootballRepo] Synced ${postes.length} postes from backend',
          );
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[PosteFootballRepo] Exception sync: $e');
      return false;
    }
  }

  /// Parse un poste de football depuis les donnees du backend.
  PosteFootball _parsePosteFootball(Map<String, dynamic> map) {
    return PosteFootball(
      id: (map['id']?.toString() ?? ''),
      nom: (map['nom'] as String?) ?? '',
      description: map['description'] as String?,
      iconeCodePoint: map['icone_code_point'] as String?,
      createdAt:
          DateTime.tryParse(
            (map['created_at'] as String?) ??
                (map['createdAt'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(
            (map['updated_at'] as String?) ??
                (map['updatedAt'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
    );
  }
}
