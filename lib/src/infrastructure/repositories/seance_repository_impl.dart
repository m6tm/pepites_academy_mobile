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
