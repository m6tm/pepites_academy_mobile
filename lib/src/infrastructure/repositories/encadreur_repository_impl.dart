import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/encadreur_events.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/entities/encadreur.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/encadreur_repository.dart';
import '../../injection_container.dart';
import '../datasources/encadreur_local_datasource.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';

/// Implementation concrete de [EncadreurRepository] utilisant le stockage local.
class EncadreurRepositoryImpl implements EncadreurRepository {
  final EncadreurLocalDatasource _datasource;
  DioClient? _dioClient;
  SyncService? _syncService;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  final _cache = RepositoryCache<List<Encadreur>>();
  final _detailCache = RepositoryCache<Encadreur>();

  EncadreurRepositoryImpl(this._datasource);

  /// Injecte le client HTTP pour les appels API.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  @override
  Future<Encadreur?> getById(String id) async {
    final cached = _detailCache.get(id);
    if (cached != null) return cached;
    final result = _datasource.getById(id);
    if (result != null) {
      _detailCache.set(id, result, ttl: CacheTtl.encadreurs, tags: {'encadreurs', 'encadreur_$id'});
    }
    return result;
  }

  @override
  Future<List<Encadreur>> getAll() async {
    const key = 'all';
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final result = _datasource.getAll();
    _cache.set(key, result, ttl: CacheTtl.encadreurs, tags: {'encadreurs'});
    return result;
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

  /// Remplace le cache local par la liste distante (le serveur fait autorite).
  /// Conserve uniquement les entrees locales avec un ID temporaire (timestamp)
  /// qui ont une operation de sync en attente, pour ne pas perdre les creations
  /// offline non encore envoyees au serveur.
  ///
  /// Un encadreur local avec ID temporaire qui a le meme email ou le meme
  /// code QR qu'un encadreur distant est considere comme deja synchronise
  /// (le serveur lui a attribue un UUID) et n'est pas conserve pour eviter
  /// les doublons pendant la fenetre de migration d'ID.
  Future<void> replaceAllFromRemote(List<Encadreur> remoteList) async {
    final local = _datasource.getAll();
    final remoteIds = {for (final e in remoteList) e.id};
    final remoteEmails = {
      for (final e in remoteList)
        if (e.email != null && e.email!.isNotEmpty) e.email!,
    };
    final remoteQrCodes = {
      for (final e in remoteList)
        if (e.codeQrUnique.isNotEmpty) e.codeQrUnique,
    };

    final pendingLocal = local.where((e) {
      if (remoteIds.contains(e.id)) return false;
      if (!RegExp(r'^\d+$').hasMatch(e.id)) return false;
      // Si le meme email ou le meme QR existe deja cote serveur, ce n'est
      // pas une vraie creation offline en attente — c'est la version locale
      // d'un encadreur qui vient d'etre synchronise mais dont l'ID n'a pas
      // encore ete migre. On la supprime pour eviter le doublon.
      if (e.email != null &&
          e.email!.isNotEmpty &&
          remoteEmails.contains(e.email!)) {
        return false;
      }
      if (e.codeQrUnique.isNotEmpty && remoteQrCodes.contains(e.codeQrUnique)) {
        return false;
      }
      return true;
    }).toList();

    await _datasource.saveAll([...remoteList, ...pendingLocal]);
  }

  @override
  Future<Encadreur> create(Encadreur encadreur) async {
    final created = await _datasource.add(encadreur);
    _cache.invalidateByTag('encadreurs');
    _invalidationRegistry?.markInvalidated<EncadreurListChangedEvent>();
    _eventBus?.emit(const EncadreurListChangedEvent());

    final payload = created.toJson();
    final allowDuplicate = await DependencyInjection.appSettingsService.getAllowDuplicateEmails();
    if (allowDuplicate) {
      payload['forceCreate'] = true;
    }

    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.encadreur,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: payload,
    );
    return created;
  }

  @override
  Future<Encadreur> update(Encadreur encadreur) async {
    final updated = await _datasource.update(encadreur);
    _cache.invalidateByTag('encadreurs');
    _detailCache.invalidateKey(encadreur.id);
    _invalidationRegistry?.markInvalidated<EncadreurListChangedEvent>();
    _eventBus?.emit(const EncadreurListChangedEvent());
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
    _cache.invalidateByTag('encadreurs');
    _detailCache.invalidateKey(id);
    _invalidationRegistry?.markInvalidated<EncadreurListChangedEvent>();
    _eventBus?.emit(const EncadreurListChangedEvent());
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.encadreur,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Supprime un encadreur localement SANS declencher de synchronisation.
  /// Utilise pour nettoyer les entites en conflit (409) sans creer
  /// d'operation DELETE supplementaire dans la file d'attente.
  Future<void> deleteLocalOnly(String id) async {
    await _datasource.delete(id);
    _cache.invalidateByTag('encadreurs');
    _detailCache.invalidateKey(id);
    _invalidationRegistry?.markInvalidated<EncadreurListChangedEvent>();
    _eventBus?.emit(const EncadreurListChangedEvent());
  }

  /// Migre l'ID temporaire local (timestamp) vers l'UUID attribue par le serveur.
  Future<void> migrateLocalId(String localId, String serverId) async {
    await _datasource.migrateLocalId(localId, serverId);
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
    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) return false;
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
            return false;
          },
          (data) async {
            final List<dynamic> rawList;
            if (data is List) {
              rawList = data;
              totalPages = currentPage;
            } else if (data is Map<String, dynamic>) {
              if (data.containsKey('items') && data['items'] is List) {
                rawList = data['items'];
              } else if (data.containsKey('encadreurs') &&
                  data['encadreurs'] is List) {
                rawList = data['encadreurs'];
              } else {
                rawList =
                    data.values.whereType<List>().expand((e) => e).toList();
              }

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

      await replaceAllFromRemote(allRemoteEncadreurs);
      _cache.invalidateByTag('encadreurs');
      _detailCache.clear();
      return true;
    } catch (e) {
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

  void clearCache() {
    _cache.clear();
    _detailCache.clear();
  }
}
