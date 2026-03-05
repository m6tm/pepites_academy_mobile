import '../../application/services/sync_service.dart';
import '../../domain/entities/niveau_scolaire.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/niveau_scolaire_repository.dart';
import '../datasources/niveau_scolaire_local_datasource.dart';
import '../datasources/academicien_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation concrete de [NiveauScolaireRepository] utilisant le stockage local.
class NiveauScolaireRepositoryImpl implements NiveauScolaireRepository {
  final NiveauScolaireLocalDatasource _datasource;
  final AcademicienLocalDatasource _academicienDatasource;
  DioClient? _dioClient;
  SyncService? _syncService;

  NiveauScolaireRepositoryImpl(this._datasource, this._academicienDatasource);

  /// Injecte le client HTTP pour les appels API.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<List<NiveauScolaire>> getAll() async {
    final niveaux = _datasource.getAll();
    niveaux.sort((a, b) => a.ordre.compareTo(b.ordre));
    return niveaux;
  }

  @override
  Future<NiveauScolaire?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<NiveauScolaire> create(NiveauScolaire niveau) async {
    final created = await _datasource.add(niveau);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.niveauScolaire,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<NiveauScolaire> update(NiveauScolaire niveau) async {
    final updated = await _datasource.update(niveau);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.niveauScolaire,
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
      entityType: SyncEntityType.niveauScolaire,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<int> countAcademiciens(String niveauId) async {
    final academiciens = await _academicienDatasource.getAll();
    return academiciens.where((a) => a.niveauScolaireId == niveauId).length;
  }

  /// Synchronise les niveaux scolaires depuis le backend vers le cache local.
  /// Retourne true si la synchronisation a reussi.
  Future<bool> syncFromApi() async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.niveauxScolaires);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[NiveauScolaireRepo] Erreur sync: ${failure.message}');
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

          final niveaux = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => _parseNiveauScolaire(map))
              .where((n) => n.id.isNotEmpty)
              .toList();

          await _datasource.saveAll(niveaux);
          // ignore: avoid_print
          print(
            '[NiveauScolaireRepo] Synced ${niveaux.length} niveaux from backend',
          );
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[NiveauScolaireRepo] Exception sync: $e');
      return false;
    }
  }

  /// Parse un niveau scolaire depuis les donnees du backend.
  NiveauScolaire _parseNiveauScolaire(Map<String, dynamic> map) {
    return NiveauScolaire(
      id: (map['id']?.toString() ?? ''),
      nom: (map['nom'] as String?) ?? '',
      ordre: (map['ordre'] as int?) ?? 0,
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
