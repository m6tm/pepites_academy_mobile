import '../../application/services/sync_service.dart';
import '../../domain/entities/encadreur.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/encadreur_repository.dart';
import '../datasources/encadreur_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implémentation concrète de [EncadreurRepository] utilisant le stockage local.
class EncadreurRepositoryImpl implements EncadreurRepository {
  final EncadreurLocalDatasource _datasource;
  DioClient? _dioClient;
  SyncService? _syncService;

  EncadreurRepositoryImpl(this._datasource);

  /// Injecte le client HTTP pour les appels API.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<Encadreur?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Encadreur>> getAll() async {
    return _datasource.getAll();
  }

  /// Fusionne une liste de donnees distantes dans le cache local
  /// sans declencher d'operation de synchronisation vers le serveur.
  Future<void> upsertAllFromRemote(List<Encadreur> remoteList) async {
    final local = _datasource.getAll();
    final localMap = {for (final e in local) e.id: e};
    for (final remote in remoteList) {
      localMap[remote.id] = remote;
    }
    await _datasource.saveAll(localMap.values.toList());
  }

  @override
  Future<Encadreur> create(Encadreur encadreur) async {
    final created = await _datasource.add(encadreur);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.encadreur,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Encadreur> update(Encadreur encadreur) async {
    final updated = await _datasource.update(encadreur);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.encadreur,
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
      entityType: SyncEntityType.encadreur,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<Encadreur?> getByQrCode(String qrCode) async {
    return _datasource.getByQrCode(qrCode);
  }

  @override
  Future<List<Encadreur>> search(String query) async {
    final all = _datasource.getAll();
    final lowerQuery = query.toLowerCase();
    return all.where((e) {
      return e.nom.toLowerCase().contains(lowerQuery) ||
          e.prenom.toLowerCase().contains(lowerQuery) ||
          e.specialite.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Synchronise les encadreurs depuis le backend vers le cache local.
  /// Retourne true si la synchronisation a reussi.
  Future<bool> syncFromApi() async {
    final client = _dioClient;
    if (client == null) return false;

    int currentPage = 1;
    int totalPages = 1;
    final List<Encadreur> allRemoteEncadreurs = [];

    try {
      do {
        final result = await client.get<dynamic>(
          ApiEndpoints.encadreurs,
          queryParameters: {'page': currentPage, 'per_page': 50},
        );

        final pageSuccess = await result.fold(
          (failure) async {
            // ignore: avoid_print
            print(
              '[EncadreurRepo] Erreur sync page $currentPage: ${failure.message}',
            );
            return false;
          },
          (data) async {
            final List<dynamic> rawList;
            if (data is List) {
              rawList = data;
              totalPages = currentPage; // Pas d'infos de pagination
            } else if (data is Map<String, dynamic>) {
              // Extraction de la liste d'items
              if (data.containsKey('items') && data['items'] is List) {
                rawList = data['items'];
              } else if (data.containsKey('encadreurs') &&
                  data['encadreurs'] is List) {
                rawList = data['encadreurs'];
              } else {
                rawList =
                    data.values.whereType<List>().expand((e) => e).toList();
              }

              // Extraction des infos de pagination
              totalPages = (data['pages'] as int?) ??
                  (data['total_pages'] as int?) ??
                  currentPage;
            } else {
              return false;
            }

            final pageEncadreurs = rawList
                .whereType<Map<String, dynamic>>()
                .map((map) => _parseEncadreur(map))
                .where((e) => e.id.isNotEmpty)
                .toList();

            allRemoteEncadreurs.addAll(pageEncadreurs);
            return true;
          },
        );

        if (!pageSuccess) return false;
        currentPage++;
      } while (currentPage <= totalPages);

      await upsertAllFromRemote(allRemoteEncadreurs);
      // ignore: avoid_print
      print(
        '[EncadreurRepo] Synced ${allRemoteEncadreurs.length} encadreurs across ${currentPage - 1} pages',
      );
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('[EncadreurRepo] Exception sync: $e');
      return false;
    }
  }

  /// Parse un encadreur depuis les donnees du backend.
  Encadreur _parseEncadreur(Map<String, dynamic> map) {
    return Encadreur(
      id: (map['id']?.toString() ?? ''),
      nom: (map['nom'] as String?) ?? '',
      prenom: (map['prenom'] as String?) ?? '',
      email: (map['email'] as String?),
      telephone: (map['telephone'] as String?) ?? '',
      photoUrl:
          (map['photo_url'] as String?) ?? (map['photoUrl'] as String?) ?? '',
      specialite: (map['specialite'] as String?) ?? '',
      role: UserRole.fromId(map['role'] as String? ?? 'encadreur'),
      codeQrUnique:
          (map['code_qr_unique'] as String?) ??
          (map['codeQrUnique'] as String?) ??
          '',
      createdAt:
          DateTime.tryParse(
            (map['created_at'] as String?) ??
                (map['createdAt'] as String?) ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      nbSeancesDirigees:
          (map['nb_seances_dirigees'] as int?) ??
          (map['nbSeancesDirigees'] as int?) ??
          0,
      nbAnnotations:
          (map['nb_annotations'] as int?) ??
          (map['nbAnnotations'] as int?) ??
          0,
    );
  }
}
