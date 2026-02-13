import '../../domain/entities/seance.dart';
import '../../domain/repositories/seance_repository.dart';
import '../datasources/seance_local_datasource.dart';

/// Implementation locale du repository de seances.
/// Delegue les operations au datasource local.
class SeanceRepositoryImpl implements SeanceRepository {
  final SeanceLocalDatasource _datasource;

  SeanceRepositoryImpl(this._datasource);

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
    return _datasource.add(seance);
  }

  @override
  Future<Seance> update(Seance seance) async {
    return _datasource.update(seance);
  }

  @override
  Future<Seance> ouvrir(String id) async {
    final seance = _datasource.getById(id);
    if (seance == null) {
      throw Exception('Seance non trouvee : $id');
    }
    final updated = seance.copyWith(statut: SeanceStatus.ouverte);
    return _datasource.update(updated);
  }

  @override
  Future<Seance> fermer(String id) async {
    final seance = _datasource.getById(id);
    if (seance == null) {
      throw Exception('Seance non trouvee : $id');
    }
    final updated = seance.copyWith(statut: SeanceStatus.fermee);
    return _datasource.update(updated);
  }

  @override
  Future<void> delete(String id) async {
    return _datasource.delete(id);
  }
}
