import '../../domain/entities/atelier.dart';
import '../../domain/repositories/atelier_repository.dart';
import '../datasources/atelier_local_datasource.dart';

/// Implementation locale du repository d'ateliers.
/// Delegue les operations au datasource local.
class AtelierRepositoryImpl implements AtelierRepository {
  final AtelierLocalDatasource _datasource;

  AtelierRepositoryImpl(this._datasource);

  @override
  Future<List<Atelier>> getBySeance(String seanceId) async {
    return _datasource.getBySeance(seanceId);
  }

  @override
  Future<Atelier?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<Atelier> create(Atelier atelier) async {
    return _datasource.add(atelier);
  }

  @override
  Future<Atelier> update(Atelier atelier) async {
    return _datasource.update(atelier);
  }

  @override
  Future<void> delete(String id) async {
    return _datasource.delete(id);
  }

  @override
  Future<void> reorder(String seanceId, List<String> atelierIds) async {
    return _datasource.reorder(seanceId, atelierIds);
  }
}
