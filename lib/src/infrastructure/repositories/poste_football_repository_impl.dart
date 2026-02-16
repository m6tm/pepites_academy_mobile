import '../../domain/entities/poste_football.dart';
import '../../domain/repositories/poste_football_repository.dart';
import '../datasources/poste_football_local_datasource.dart';
import '../datasources/academicien_local_datasource.dart';

/// Implementation concrete de [PosteFootballRepository] utilisant le stockage local.
class PosteFootballRepositoryImpl implements PosteFootballRepository {
  final PosteFootballLocalDatasource _datasource;
  final AcademicienLocalDatasource _academicienDatasource;

  PosteFootballRepositoryImpl(this._datasource, this._academicienDatasource);

  @override
  Future<List<PosteFootball>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<PosteFootball?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<PosteFootball> create(PosteFootball poste) async {
    return _datasource.add(poste);
  }

  @override
  Future<PosteFootball> update(PosteFootball poste) async {
    return _datasource.update(poste);
  }

  @override
  Future<void> delete(String id) async {
    return _datasource.delete(id);
  }

  @override
  Future<int> countAcademiciens(String posteId) async {
    final academiciens = await _academicienDatasource.getAll();
    return academiciens.where((a) => a.posteFootballId == posteId).length;
  }
}
