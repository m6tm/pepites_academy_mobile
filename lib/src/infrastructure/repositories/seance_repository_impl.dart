import 'dart:convert';

import '../../../l10n/app_localizations.dart';
import '../../application/services/sync_service.dart';
import '../../domain/entities/seance.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/seance_repository.dart';
import '../datasources/seance_local_datasource.dart';

/// Implementation locale du repository de seances.
/// Delegue les operations au datasource local.
class SeanceRepositoryImpl implements SeanceRepository {
  final SeanceLocalDatasource _datasource;
  SyncService? _syncService;
  AppLocalizations? _l10n;

  SeanceRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
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
}
