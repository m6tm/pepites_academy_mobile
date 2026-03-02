import 'dart:convert';

import '../../../l10n/app_localizations.dart';
import '../../application/services/sync_service.dart';
import '../../domain/entities/seance.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/seance_repository.dart';
import '../datasources/seance_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository de seances.
/// Delegue les operations au datasource local.
class SeanceRepositoryImpl implements SeanceRepository {
  final SeanceLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;
  AppLocalizations? _l10n;

  SeanceRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Injecte le client HTTP.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  @override
  Future<Seance?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Seance>> getAll() async {
    return _datasource.getAll();
  }

  /// Fusionne une liste de donnees distantes dans le cache local
  /// sans declencher d'operation de synchronisation vers le serveur.
  Future<void> upsertAllFromRemote(List<Seance> remoteList) async {
    final local = _datasource.getAll();
    final localMap = {for (final s in local) s.id: s};
    for (final remote in remoteList) {
      final existing = localMap[remote.id];
      if (existing != null &&
          existing.statut == SeanceStatus.fermee &&
          remote.statut == SeanceStatus.ouverte) {
        final preserveLocal = await _hasPendingLocalClose(remote.id);
        if (preserveLocal) continue;
      }
      localMap[remote.id] = remote;
    }
    await _datasource.saveAll(localMap.values.toList());
  }

  Future<bool> _hasPendingLocalClose(String seanceId) async {
    final sync = _syncService;
    if (sync == null) return false;

    try {
      final pending = await sync.getPendingOperations();
      for (final op in pending) {
        if (op.entityType != SyncEntityType.seance) continue;
        if (op.entityId != seanceId) continue;
        if (op.operationType != SyncOperationType.update) continue;

        final decoded = json.decode(op.payload);
        if (decoded is Map<String, dynamic>) {
          final statut = decoded['statut']?.toString();
          if (statut == 'fermee') return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Seance?> getSeanceOuverte() async {
    return _datasource.getSeanceOuverte();
  }

  @override
  Future<Seance> create(Seance seance) async {
    final created = await _datasource.add(seance);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Seance> update(Seance seance) async {
    final updated = await _datasource.update(seance);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<Seance> ouvrir(String id) async {
    final seance = _datasource.getById(id);
    if (seance == null) {
      throw Exception(
        _l10n?.infraSeanceNotFound(id) ?? 'Seance non trouvee : $id',
      );
    }
    final updated = seance.copyWith(statut: SeanceStatus.ouverte);
    final result = await _datasource.update(updated);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: result.id,
      operationType: SyncOperationType.update,
      data: result.toJson(),
    );
    return result;
  }

  @override
  Future<Seance> fermer(String id) async {
    final seance = _datasource.getById(id);
    if (seance == null) {
      throw Exception(
        _l10n?.infraSeanceNotFound(id) ?? 'Seance non trouvee : $id',
      );
    }
    final updated = seance.copyWith(statut: SeanceStatus.fermee);
    final result = await _datasource.update(updated);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: result.id,
      operationType: SyncOperationType.update,
      data: result.toJson(),
    );
    return result;
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.seance,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Synchronise les seances depuis le backend.
  /// Fusionne les donnees distantes dans le cache local.
  /// Retourne false si le serveur est inaccessible ou en cas d'erreur.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.seances);

      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[Seance] Sync failed: ${failure.message}');
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
              .map((map) {
                return Seance(
                  id: map['id'] as String,
                  titre: (map['titre'] as String?) ?? '',
                  date: DateTime.parse(
                    (map['date'] as String?) ??
                        (map['date_debut'] as String?) ??
                        DateTime.now().toIso8601String(),
                  ),
                  heureDebut: DateTime.parse(
                    (map['heure_debut'] as String?) ??
                        (map['heureDebut'] as String?) ??
                        '1970-01-01T09:00:00',
                  ),
                  heureFin: DateTime.parse(
                    (map['heure_fin'] as String?) ??
                        (map['heureFin'] as String?) ??
                        '1970-01-01T11:00:00',
                  ),
                  statut: _parseStatut(map['statut'] as String?),
                  encadreurResponsableId:
                      (map['encadreur_responsable_id'] as String?) ??
                      (map['encadreurResponsableId'] as String?) ??
                      '',
                  encadreurIds:
                      (map['encadreur_ids'] as List<dynamic>?)
                          ?.map((e) => e as String)
                          .toList() ??
                      [],
                  academicienIds:
                      (map['academicien_ids'] as List<dynamic>?)
                          ?.map((e) => e as String)
                          .toList() ??
                      [],
                  atelierIds:
                      (map['atelier_ids'] as List<dynamic>?)
                          ?.map((e) => e as String)
                          .toList() ??
                      [],
                );
              })
              .where((s) => s.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          // ignore: avoid_print
          print('[Seance] Synced ${remote.length} items from backend');
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Seance] Sync exception: $e');
      return false;
    }
  }

  /// Parse le statut depuis la reponse API.
  SeanceStatus _parseStatut(String? statut) {
    switch (statut?.toLowerCase()) {
      case 'ouverte':
        return SeanceStatus.ouverte;
      case 'fermee':
        return SeanceStatus.fermee;
      default:
        return SeanceStatus.fermee;
    }
  }
}
