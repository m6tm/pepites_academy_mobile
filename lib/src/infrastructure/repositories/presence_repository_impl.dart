import '../../domain/entities/presence.dart';
import '../../domain/repositories/presence_repository.dart';
import '../datasources/presence_local_datasource.dart';

/// Implementation locale du repository de presences.
/// Delegue les operations au datasource local.
class PresenceRepositoryImpl implements PresenceRepository {
  final PresenceLocalDatasource _datasource;

  PresenceRepositoryImpl(this._datasource);

  @override
  Future<Presence> mark(Presence presence) async {
    return _datasource.add(presence);
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
