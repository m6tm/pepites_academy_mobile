import '../../application/services/sync_service.dart';
import '../../domain/entities/presence.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/presence_repository.dart';
import '../datasources/presence_local_datasource.dart';

/// Implementation locale du repository de presences.
/// Delegue les operations au datasource local.
class PresenceRepositoryImpl implements PresenceRepository {
  final PresenceLocalDatasource _datasource;
  SyncService? _syncService;

  PresenceRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  @override
  Future<Presence> mark(Presence presence) async {
    final marked = await _datasource.add(presence);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.presence,
      entityId: marked.id,
      operationType: SyncOperationType.create,
      data: marked.toJson(),
    );
    return marked;
  }

  @override
  Future<List<Presence>> getBySeance(String seanceId) async {
    return _datasource.getBySeance(seanceId);
  }

  @override
  Future<List<Presence>> getByProfil(String profilId) async {
    return _datasource.getByProfil(profilId);
  }

  /// Verifie si un profil est deja enregistre pour une seance.
  bool isAlreadyPresent(String profilId, String seanceId) {
    return _datasource.isAlreadyPresent(profilId, seanceId);
  }
}
