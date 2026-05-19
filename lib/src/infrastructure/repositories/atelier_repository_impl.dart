import '../../application/services/sync_service.dart';
import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/atelier_events.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../domain/entities/atelier.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/atelier_repository.dart';
import '../datasources/atelier_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository d'ateliers.
/// Delegue les operations au datasource local.
class AtelierRepositoryImpl implements AtelierRepository {
  final AtelierLocalDatasource _datasource;
  final _cache = RepositoryCache<List<Atelier>>();
  SyncService? _syncService;
  DioClient? _dioClient;
  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;

  AtelierRepositoryImpl(this._datasource);

  void _invalidateCache() {
    _cache.invalidateByTag('ateliers');
  }

  /// Vide le cache memoire pour forcer un re-fetch depuis le datasource local.
  void clearCache() => _invalidateCache();

  void setSyncService(SyncService service) {
    _syncService = service;
  }

  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

@override
  Future<List<Atelier>> getBySeanceId(String seanceId, {bool forceRefresh = false}) async {
    final key = 'seance_$seanceId';

    if (forceRefresh) {
      _invalidateCache();
    } else {
      final cached = _cache.get(key);
      if (cached != null) return cached;
    }

    return _cache.getOrFetch(key, () async {
      if (forceRefresh && _dioClient != null) {
        await _syncAteliersForSeance(seanceId);
      }
      var local = _datasource.getBySeance(seanceId);
      if (local.isEmpty && _dioClient != null) {
        await _syncAteliersForSeance(seanceId);
        local = _datasource.getBySeance(seanceId);
      }
      _cache.set(
        key,
        local,
        ttl: CacheTtl.ateliers,
        tags: {'ateliers', key},
      );
      return local;
    });
  }

  /// Synchronise les ateliers d'une seance specifique depuis le backend.
  /// Utilise l'endpoint /seances/{seanceId}/ateliers pour avoir le seance_id.
  Future<bool> _syncAteliersForSeance(String seanceId) async {
    if (_dioClient == null) return false;

    try {
      final endpoint = '${ApiEndpoints.seances}/$seanceId/ateliers';
      final result = await _dioClient!.get<dynamic>(endpoint);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[AtelierRepo] Erreur sync séance $seanceId: ${failure.message}');
          return false;
        },
        (data) async {
          final List<dynamic> rawList;
          if (data is List) {
            rawList = data;
          } else if (data is Map<String, dynamic>) {
            rawList = (data['ateliers'] as List<dynamic>?) ??
                data.values.whereType<List>().expand((e) => e).toList();
          } else {
            return false;
          }

          final ateliers = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => Atelier.fromJson({...map, 'seance_id': seanceId}))
              .where((a) => a.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(ateliers);
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AtelierRepo] Exception sync séance $seanceId: $e');
      return false;
    }
  }

  @override
  Future<Atelier?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<Atelier> create(Atelier atelier) async {
    if (_dioClient != null) {
      return _createOnline(atelier);
    }
    return _createOffline(atelier);
  }

  /// Appel direct API : le backend assigne l'UUID, la reponse est persistee
  /// localement avec cet UUID. Pas d'entree dans la file de sync.
  /// Si le serveur est inaccessible (5xx, timeout), bascule sur le mode offline.
  /// Si la seance est inconnue du backend (404), propage l'erreur —
  /// une seance fantome ne pourra jamais syncer et ne doit pas entrer dans la file.
  Future<Atelier> _createOnline(Atelier atelier) async {
    try {
      final payload = _buildCreatePayload(atelier);
      final endpoint = '${ApiEndpoints.seances}/${atelier.seanceId}/ateliers';
      final result = await _dioClient!.post<dynamic>(endpoint, data: payload);

      return await result.fold(
        (failure) async {
          if (failure.statusCode == 404) {
            // La seance n'existe pas sur le backend — echec permanent.
            // Ne pas enregistrer en offline pour eviter des retentatives infinies.
            throw Exception(
              'Séance introuvable sur le serveur (id: ${atelier.seanceId}). '
              'Veuillez fermer cette séance et en créer une nouvelle.',
            );
          }
          // ignore: avoid_print
          print('[AtelierRepo] Creation online echouee (${failure.statusCode}): ${failure.message}. Bascule offline.');
          return _createOffline(atelier);
        },
        (data) async {
          final map = data is Map<String, dynamic> ? data : null;
          final atelierMap = (map?['atelier'] as Map<String, dynamic>?) ?? map;
          final serverId = atelierMap?['id'] as String?;
          if (atelierMap == null || serverId == null || serverId.isEmpty) {
            return _createOffline(atelier);
          }
          final serverAtelier = Atelier.fromJson({
            ...atelierMap,
            'seance_id': atelier.seanceId,
          });
          await _datasource.add(serverAtelier);
          _invalidateCache();
          _eventBus?.emit(AtelierCreeEvent(
            atelierId: serverAtelier.id,
            seanceId: serverAtelier.seanceId,
          ));
          _invalidationRegistry?.markInvalidated<AtelierCreeEvent>();
          return serverAtelier;
        },
      );
    } catch (e) {
      // Laisser remonter les echecs permanents (seance inexistante, etc.)
      if (e is Exception && e.toString().contains('Séance introuvable')) rethrow;
      // ignore: avoid_print
      print('[AtelierRepo] Exception creation online: $e. Bascule offline.');
      return _createOffline(atelier);
    }
  }

  /// Creation offline-first : persiste localement et met en file de sync.
  Future<Atelier> _createOffline(Atelier atelier) async {
    final created = await _datasource.add(atelier);
    _invalidateCache();
    _eventBus?.emit(AtelierCreeEvent(
      atelierId: created.id,
      seanceId: created.seanceId,
    ));
    _invalidationRegistry?.markInvalidated<AtelierCreeEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.atelier,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  Map<String, dynamic> _buildCreatePayload(Atelier atelier) {
    return {
      'nom': atelier.nom,
      'description': atelier.description,
      'type': atelier.type.name,
      if (atelier.typeCustom != null) 'type_custom': atelier.typeCustom,
      if (atelier.icone != null) 'icone': atelier.icone,
      'ordre': atelier.ordre,
      if (atelier.configurationEvaluation != null)
        'configuration_evaluation': atelier.configurationEvaluation!
            .map((c) => c.toJson())
            .toList(),
    };
  }

  @override
  Future<Atelier> update(Atelier atelier) async {
    if (_dioClient != null) {
      return _updateOnline(atelier);
    }
    return _updateOffline(atelier);
  }

  Future<Atelier> _updateOnline(Atelier atelier) async {
    try {
      final payload = _buildUpdatePayload(atelier);
      final endpoint = '${ApiEndpoints.ateliers}/${atelier.id}';
      final result = await _dioClient!.put<dynamic>(endpoint, data: payload);
      return await result.fold(
        (failure) async {
          // ignore: avoid_print
          print('[AtelierRepo] Update online échoué (${failure.statusCode}): ${failure.message}. Bascule offline.');
          return _updateOffline(atelier);
        },
        (data) async {
          final map = data is Map<String, dynamic> ? data : null;
          final atelierMap = (map?['atelier'] as Map<String, dynamic>?) ?? map;
          if (atelierMap != null && (atelierMap['id'] as String?)?.isNotEmpty == true) {
            final serverAtelier = Atelier.fromJson({...atelierMap, 'seance_id': atelier.seanceId});
            await _datasource.update(serverAtelier);
            _invalidateCache();
            _eventBus?.emit(AtelierCreeEvent(
              atelierId: serverAtelier.id,
              seanceId: serverAtelier.seanceId,
            ));
            _invalidationRegistry?.markInvalidated<AtelierCreeEvent>();
            return serverAtelier;
          }
          return _updateOffline(atelier);
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AtelierRepo] Exception update online: $e. Bascule offline.');
      return _updateOffline(atelier);
    }
  }

  Future<Atelier> _updateOffline(Atelier atelier) async {
    final updated = await _datasource.update(atelier);
    _invalidateCache();
    _eventBus?.emit(AtelierCreeEvent(
      atelierId: updated.id,
      seanceId: updated.seanceId,
    ));
    _invalidationRegistry?.markInvalidated<AtelierCreeEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.atelier,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  Map<String, dynamic> _buildUpdatePayload(Atelier atelier) {
    return {
      'nom': atelier.nom,
      'description': atelier.description,
      'type': atelier.type.name,
      if (atelier.typeCustom != null) 'type_custom': atelier.typeCustom,
      if (atelier.icone != null) 'icone': atelier.icone,
      'ordre': atelier.ordre,
      if (atelier.configurationEvaluation != null)
        'configuration_evaluation': atelier.configurationEvaluation!
            .map((c) => c.toJson())
            .toList(),
    };
  }

  @override
  Future<Atelier> apply(String id) async {
    if (_dioClient != null) {
      final result = await _dioClient!.put<dynamic>(
        '${ApiEndpoints.ateliers}/$id/apply',
        data: {},
      );
      return await result.fold(
        (failure) async => _applyLocally(id),
        (data) async {
          final map = data is Map<String, dynamic> ? (data['atelier'] as Map<String, dynamic>? ?? data) : null;
          if (map != null) {
            final atelier = Atelier.fromJson(map);
            await _datasource.update(atelier);
            _invalidateCache();
            _eventBus?.emit(AtelierCreeEvent(
              atelierId: atelier.id,
              seanceId: atelier.seanceId,
            ));
            _invalidationRegistry?.markInvalidated<AtelierCreeEvent>();
            return atelier;
          }
          return _applyLocally(id);
        },
      );
    }
    return _applyLocally(id);
  }

  Future<Atelier> _applyLocally(String id) async {
    final existing = _datasource.getById(id);
    if (existing == null) throw Exception('Atelier $id introuvable localement');
    final updated = existing.copyWith(statut: AtelierStatut.applique);
    await _datasource.update(updated);
    _invalidateCache();
    return updated;
  }

  @override
  Future<Atelier> close(String id) async {
    if (_dioClient != null) {
      final result = await _dioClient!.put<dynamic>(
        '${ApiEndpoints.ateliers}/$id/close',
        data: {},
      );
      return await result.fold(
        (failure) async => _closeLocally(id),
        (data) async {
          final map = data is Map<String, dynamic> ? (data['atelier'] as Map<String, dynamic>? ?? data) : null;
          if (map != null) {
            final atelier = Atelier.fromJson(map);
            await _datasource.update(atelier);
            _invalidateCache();
            return atelier;
          }
          return _closeLocally(id);
        },
      );
    }
    return _closeLocally(id);
  }

  Future<Atelier> _closeLocally(String id) async {
    final existing = _datasource.getById(id);
    if (existing == null) throw Exception('Atelier $id introuvable localement');
    final updated = existing.copyWith(statut: AtelierStatut.ferme);
    await _datasource.update(updated);
    _invalidateCache();
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    _invalidateCache();
    _eventBus?.emit(AtelierDeletedEvent(id));
    _invalidationRegistry?.markInvalidated<AtelierDeletedEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.atelier,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  @override
  Future<void> reorder(String seanceId, List<String> atelierIds) async {
    await _datasource.reorder(seanceId, atelierIds);
    _invalidateCache();
    _eventBus?.emit(AtelierCreeEvent(
      atelierId: seanceId,
      seanceId: seanceId,
    ));
    _invalidationRegistry?.markInvalidated<AtelierCreeEvent>();
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.atelier,
      entityId: seanceId,
      operationType: SyncOperationType.reorder,
      data: {'order': atelierIds},
    );
  }

  /// Synchronise les ateliers depuis le backend.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.ateliers);

      return await result.fold(
        (failure) {
          // ignore: avoid_print
          print('[AtelierRepo] Erreur sync: ${failure.message}');
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

          final ateliers = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => Atelier.fromJson(map))
              .where((a) => a.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(ateliers);
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[AtelierRepo] Exception sync: $e');
      return false;
    }
  }

  /// Met à jour le cache local avec les ateliers provenant de l'API.
  Future<void> upsertAllFromRemote(List<Atelier> ateliers) async {
    await _datasource.upsertAll(ateliers);
  }
}
