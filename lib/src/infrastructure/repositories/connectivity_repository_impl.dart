import '../../domain/entities/connectivity_status.dart';
import '../../domain/repositories/connectivity_repository.dart';
import '../datasources/connectivity_datasource.dart';

/// Implementation du repository de connectivite.
/// Delegue la surveillance reseau au datasource connectivity_plus.
class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final ConnectivityDatasource _datasource;

  ConnectivityRepositoryImpl(this._datasource);

  @override
  Future<ConnectivityStatus> getCurrentStatus() async {
    return _datasource.getCurrentStatus();
  }

  @override
  Stream<ConnectivityStatus> get statusStream => _datasource.statusStream;

  @override
  void dispose() {
    _datasource.dispose();
  }
}
