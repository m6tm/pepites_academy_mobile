import '../../domain/entities/academicien.dart';
import '../../domain/repositories/academicien_repository.dart';
import '../datasources/academicien_local_datasource.dart';

/// Implementation locale du repository academicien.
/// Delegue les operations au datasource local.
class AcademicienRepositoryImpl implements AcademicienRepository {
  final AcademicienLocalDatasource _datasource;

  AcademicienRepositoryImpl(this._datasource);

  @override
  Future<Academicien?> getById(String id) => _datasource.getById(id);

  @override
  Future<List<Academicien>> getAll() => _datasource.getAll();

  @override
  Future<Academicien> create(Academicien academicien) =>
      _datasource.create(academicien);

  @override
  Future<Academicien> update(Academicien academicien) =>
      _datasource.update(academicien);

  @override
  Future<Academicien?> getByQrCode(String qrCode) =>
      _datasource.getByQrCode(qrCode);

  @override
  Future<List<Academicien>> search(String query) =>
      _datasource.search(query);

  Future<void> delete(String id) => _datasource.delete(id);
}
