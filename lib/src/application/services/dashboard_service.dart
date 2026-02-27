import '../../domain/entities/global_stats.dart';
import '../../infrastructure/network/api_endpoints.dart';
import '../../infrastructure/network/dio_client.dart';

/// Service applicatif pour recuperer les statistiques du dashboard.
class DashboardService {
  final DioClient _dioClient;

  DashboardService({required DioClient dioClient}) : _dioClient = dioClient;

  /// Recupere les statistiques globales depuis le backend.
  Future<GlobalStats?> getGlobalStats() async {
    final result = await _dioClient.get<dynamic>(ApiEndpoints.dashboardStats);

    return result.fold(
      (failure) {
        // ignore: avoid_print
        print('[DashboardService] Erreur recuperation stats: ${failure.message}');
        return null;
      },
      (data) {
        if (data is Map<String, dynamic>) {
          return GlobalStats.fromJson(data);
        }
        return null;
      },
    );
  }
}
