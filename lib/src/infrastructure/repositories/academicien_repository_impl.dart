import '../../application/services/sync_service.dart';
import '../../domain/entities/academicien.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/academicien_repository.dart';
import '../datasources/academicien_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation locale du repository academicien.
/// Delegue les operations au datasource local.
class AcademicienRepositoryImpl implements AcademicienRepository {
  final AcademicienLocalDatasource _datasource;
  DioClient? _dioClient;
  SyncService? _syncService;

  AcademicienRepositoryImpl(this._datasource);

  /// Injecte le client HTTP pour les appels API.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<Academicien?> getById(String id) => _datasource.getById(id);

  @override
  Future<List<Academicien>> getAll() => _datasource.getAll();

  /// Fusionne une liste de donnees distantes dans le cache local
  /// sans declencher d'operation de synchronisation vers le serveur.
  Future<void> upsertAllFromRemote(List<Academicien> remoteList) async {
    final local = await _datasource.getAll();
    final localMap = {for (final a in local) a.id: a};
    for (final remote in remoteList) {
      localMap[remote.id] = remote;
    }
    await _datasource.saveAll(localMap.values.toList());
  }

  @override
  Future<Academicien> create(Academicien academicien) async {
    final created = await _datasource.create(academicien);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Academicien> update(Academicien academicien) async {
    final updated = await _datasource.update(academicien);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<Academicien?> getByQrCode(String qrCode) =>
      _datasource.getByQrCode(qrCode);

  @override
  Future<List<Academicien>> search(String query) => _datasource.search(query);

  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.academicien,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Synchronise les academiciens depuis le backend vers le cache local.
  /// Retourne true si la synchronisation a reussi.
  Future<bool> syncFromApi() async {
    final client = _dioClient;
    if (client == null) return false;

    try {
      final result = await client.get<dynamic>(ApiEndpoints.academiciens);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[AcademicienRepo] Erreur sync: ${failure.message}');
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

          final academiciens = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => _parseAcademicien(map))
              .where((a) => a.id.isNotEmpty)
              .toList();

          await upsertAllFromRemote(academiciens);
          // ignore: avoid_print
          print(
            '[AcademicienRepo] Synced ${academiciens.length} academiciens from backend',
          );
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AcademicienRepo] Exception sync: $e');
      return false;
    }
  }

  /// Parse un academicien depuis les donnees du backend.
  Academicien _parseAcademicien(Map<String, dynamic> map) {
    return Academicien(
      id: (map['id']?.toString() ?? ''),
      nom: (map['nom'] as String?) ?? '',
      prenom: (map['prenom'] as String?) ?? '',
      dateNaissance:
          DateTime.tryParse(
            (map['date_naissance'] as String?) ??
                (map['dateNaissance'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      photoUrl:
          (map['photo_url'] as String?) ?? (map['photoUrl'] as String?) ?? '',
      telephoneParent:
          (map['telephone_parent'] as String?) ??
          (map['telephoneParent'] as String?) ??
          '',
      posteFootballId:
          (map['poste_football_id'] as String?) ??
          (map['posteFootballId'] as String?) ??
          '',
      niveauScolaireId:
          (map['niveau_scolaire_id'] as String?) ??
          (map['niveauScolaireId'] as String?) ??
          '',
      codeQrUnique:
          (map['code_qr_unique'] as String?) ??
          (map['codeQrUnique'] as String?) ??
          '',
      piedFort: (map['pied_fort'] as String?) ?? (map['piedFort'] as String?),
    );
  }
}
