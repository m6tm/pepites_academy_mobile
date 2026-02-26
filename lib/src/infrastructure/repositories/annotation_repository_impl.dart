import '../../application/services/sync_service.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../datasources/annotation_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository d'annotations.
/// Delegue les operations au datasource local.
class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;

  AnnotationRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Injecte le client HTTP.
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

  /// Synchronise les annotations depuis le backend.
  /// Merge les donnees distantes dans le cache local.
  /// Retourne false si le serveur est inaccessible ou en cas d'erreur.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.annotations);

      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[Annotation] Sync failed: ${failure.message}');
          return false;
        },
        (data) async {
          final List<dynamic> rawList;
          if (data is List) {
            rawList = data;
          } else if (data is Map<String, dynamic>) {
            // Cherche une liste dans les valeurs (pattern deja utilise dans ApiSyncDatasourceImpl)
            rawList = data.values.whereType<List>().expand((e) => e).toList();
          } else {
            return false;
          }

          final remote = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) {
                return Annotation(
                  id: map['id'] as String,
                  contenu: (map['contenu'] as String?) ?? '',
                  tags:
                      (map['tags'] as List<dynamic>?)
                          ?.map((e) => e as String)
                          .toList() ??
                      [],
                  note: (map['note'] as num?)?.toDouble(),
                  academicienId:
                      (map['academicien_id'] as String?) ??
                      (map['academicienId'] as String?) ??
                      '',
                  atelierId:
                      (map['atelier_id'] as String?) ??
                      (map['atelierId'] as String?) ??
                      '',
                  seanceId:
                      (map['seance_id'] as String?) ??
                      (map['seanceId'] as String?) ??
                      '',
                  encadreurId:
                      (map['encadreur_id'] as String?) ??
                      (map['encadreurId'] as String?) ??
                      '',
                  horodate:
                      DateTime.tryParse(
                        (map['horodate'] as String?) ??
                            (map['created_at'] as String?) ??
                            '',
                      ) ??
                      DateTime.now(),
                );
              })
              .where((a) => a.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          // ignore: avoid_print
          print('[Annotation] Synced ${remote.length} items from backend');
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Annotation] Sync exception: $e');
      return false;
    }
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
