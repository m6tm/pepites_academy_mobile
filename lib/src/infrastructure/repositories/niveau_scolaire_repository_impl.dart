import '../../domain/entities/niveau_scolaire.dart';
import '../../domain/repositories/niveau_scolaire_repository.dart';
import '../datasources/niveau_scolaire_local_datasource.dart';
import '../datasources/academicien_local_datasource.dart';

/// Implementation concrete de [NiveauScolaireRepository] utilisant le stockage local.
class NiveauScolaireRepositoryImpl implements NiveauScolaireRepository {
  final NiveauScolaireLocalDatasource _datasource;
  final AcademicienLocalDatasource _academicienDatasource;

  NiveauScolaireRepositoryImpl(this._datasource, this._academicienDatasource);

  @override
  Future<List<NiveauScolaire>> getAll() async {
    final niveaux = _datasource.getAll();
    niveaux.sort((a, b) => a.ordre.compareTo(b.ordre));
    return niveaux;
  }

  @override
  Future<NiveauScolaire?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<NiveauScolaire> create(NiveauScolaire niveau) async {
    return _datasource.add(niveau);
  }

  @override
  Future<NiveauScolaire> update(NiveauScolaire niveau) async {
    return _datasource.update(niveau);
  }

  @override
  Future<void> delete(String id) async {
    return _datasource.delete(id);
  }

  @override
  Future<int> countAcademiciens(String niveauId) async {
    final academiciens = await _academicienDatasource.getAll();
    return academiciens.where((a) => a.niveauScolaireId == niveauId).length;
  }
}
