import '../../domain/entities/encadreur.dart';
import '../../domain/repositories/encadreur_repository.dart';
import '../datasources/encadreur_local_datasource.dart';

/// Implémentation concrète de [EncadreurRepository] utilisant le stockage local.
class EncadreurRepositoryImpl implements EncadreurRepository {
  final EncadreurLocalDatasource _datasource;

  EncadreurRepositoryImpl(this._datasource);

  @override
  Future<Encadreur?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Encadreur>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<Encadreur> create(Encadreur encadreur) async {
    return _datasource.add(encadreur);
  }

  @override
  Future<Encadreur> update(Encadreur encadreur) async {
    return _datasource.update(encadreur);
  }

  @override
  Future<void> delete(String id) async {
    return _datasource.delete(id);
  }

  @override
  Future<Encadreur?> getByQrCode(String qrCode) async {
    return _datasource.getByQrCode(qrCode);
  }

  @override
  Future<List<Encadreur>> search(String query) async {
    final all = _datasource.getAll();
    final lowerQuery = query.toLowerCase();
    return all.where((e) {
      return e.nom.toLowerCase().contains(lowerQuery) ||
          e.prenom.toLowerCase().contains(lowerQuery) ||
          e.specialite.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
