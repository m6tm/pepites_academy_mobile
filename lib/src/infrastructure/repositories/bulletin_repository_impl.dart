import '../../domain/entities/bulletin.dart';
import '../../domain/repositories/bulletin_repository.dart';
import '../datasources/bulletin_local_datasource.dart';

/// Implementation locale du repository de bulletins de formation.
/// Delegue les operations au datasource local.
class BulletinRepositoryImpl implements BulletinRepository {
  final BulletinLocalDatasource _datasource;

  BulletinRepositoryImpl(this._datasource);

  @override
  Future<Bulletin> create(Bulletin bulletin) async {
    return _datasource.add(bulletin);
  }

  @override
  Future<Bulletin> update(Bulletin bulletin) async {
    return _datasource.update(bulletin);
  }

  @override
  Future<Bulletin?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Bulletin>> getByAcademicien(String academicienId) async {
    return _datasource.getByAcademicien(academicienId);
  }

  @override
  Future<List<Bulletin>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<void> delete(String id) async {
    return _datasource.delete(id);
  }
}
