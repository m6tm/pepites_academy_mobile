import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/domain/entities/dashboard_stats.dart';
import 'package:pepites_academy_mobile/src/domain/entities/global_stats.dart';
import 'package:pepites_academy_mobile/src/domain/failures/network_failure.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/api_endpoints.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/dashboard_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockDioClient extends Mock implements DioClient {}

class FakeSharedPreferences extends Fake implements SharedPreferences {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    SharedPreferences.setMockInitialValues({});
  });

  group('DashboardRepositoryImpl', () {
    final testGlobalStats = const GlobalStats(
      nbAcademiciens: 50,
      nbEncadreurs: 10,
      nbSeancesMois: 12,
      tauxPresenceMoyen: 85.5,
      objectifsAtteints: 78.0,
      satisfactionCoachs: 92.0,
    );

    final testDashboardStats = DashboardStats(
      globalStats: testGlobalStats,
      nbSeancesTotal: 100,
      nbAnnotationsTotal: 500,
      nbPresencesTotal: 1500,
      nbSeancesJour: 2,
      nbPresencesJour: 45,
    );

    final testJsonResponse = {
      'global_stats': {
        'nb_academiciens': 50,
        'nb_encadreurs': 10,
        'nb_seances_mois': 12,
        'taux_presence_moyen': 85.5,
        'objectifs_atteints': 78.0,
        'satisfaction_coachs': 92.0,
      },
      'nb_seances_total': 100,
      'nb_annotations_total': 500,
      'nb_presences_total': 1500,
      'nb_seances_jour': 2,
      'nb_presences_jour': 45,
      'current_season': null,
      'users_by_role': {},
      'last_updated_at': '2024-10-15T10:00:00.000Z',
    };

    test(
      'getStats doit retourner les stats depuis l\'API si pas de cache',
      () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        repository = DashboardRepositoryImpl(mockDioClient, prefs);

        when(
          () => mockDioClient.get<dynamic>(ApiEndpoints.dashboardStats),
        ).thenAnswer((_) async => Right(testJsonResponse));

        // Act
        final (stats, error, isFromCache) = await repository.getStats();

        // Assert
        expect(stats, isNotNull);
        expect(stats?.nbAcademiciens, 50);
        expect(stats?.nbSeancesTotal, 100);
        expect(error, isNull);
        expect(isFromCache, false);
        verify(
          () => mockDioClient.get<dynamic>(ApiEndpoints.dashboardStats),
        ).called(1);
      },
    );

    test('getStats doit retourner le cache si disponible', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_dashboard_stats',
        testDashboardStats.toJson().toString(),
      );
      await prefs.setInt(
        'cached_dashboard_stats_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      repository = DashboardRepositoryImpl(mockDioClient, prefs);

      // Act
      final (stats, error, isFromCache) = await repository.getStats();

      // Assert
      expect(stats, isNotNull);
      expect(isFromCache, true);
      // L'API ne doit pas être appelée si le cache est valide
      verifyNever(() => mockDioClient.get<dynamic>(any()));
    });

    test('getStats avec forceRefresh doit ignorer le cache', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_dashboard_stats',
        testDashboardStats.toJson().toString(),
      );
      await prefs.setInt(
        'cached_dashboard_stats_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      repository = DashboardRepositoryImpl(mockDioClient, prefs);

      when(
        () => mockDioClient.get<dynamic>(ApiEndpoints.dashboardStats),
      ).thenAnswer((_) async => Right(testJsonResponse));

      // Act
      final (stats, error, isFromCache) = await repository.getStats(
        forceRefresh: true,
      );

      // Assert
      expect(stats, isNotNull);
      expect(isFromCache, false);
      verify(
        () => mockDioClient.get<dynamic>(ApiEndpoints.dashboardStats),
      ).called(1);
    });

    test(
      'getStats doit retourner le cache en fallback si l\'API echoue',
      () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'cached_dashboard_stats',
          testDashboardStats.toJson().toString(),
        );
        await prefs.setInt(
          'cached_dashboard_stats_timestamp',
          DateTime.now().millisecondsSinceEpoch,
        );

        repository = DashboardRepositoryImpl(mockDioClient, prefs);

        const failure = NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur serveur',
        );
        when(
          () => mockDioClient.get<dynamic>(ApiEndpoints.dashboardStats),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final (stats, error, isFromCache) = await repository.getStats(
          forceRefresh: true,
        );

        // Assert
        expect(stats, isNotNull); // Cache en fallback
        expect(error, isNotNull); // Erreur présente
        expect(isFromCache, true);
      },
    );

    test(
      'getStats doit retourner une erreur si pas de cache et API echoue',
      () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        repository = DashboardRepositoryImpl(mockDioClient, prefs);

        const failure = NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur serveur',
        );
        when(
          () => mockDioClient.get<dynamic>(ApiEndpoints.dashboardStats),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final (stats, error, isFromCache) = await repository.getStats();

        // Assert
        expect(stats, isNull);
        expect(error, isNotNull);
        expect(isFromCache, false);
      },
    );

    test('invalidateCache doit effacer le cache', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_dashboard_stats',
        testDashboardStats.toJson().toString(),
      );
      await prefs.setInt(
        'cached_dashboard_stats_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      repository = DashboardRepositoryImpl(mockDioClient, prefs);

      // Act
      await repository.invalidateCache();

      // Assert
      expect(prefs.containsKey('cached_dashboard_stats'), false);
      expect(prefs.containsKey('cached_dashboard_stats_timestamp'), false);
    });

    test('statsStream doit emettre les nouvelles stats', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      repository = DashboardRepositoryImpl(mockDioClient, prefs);

      when(
        () => mockDioClient.get<dynamic>(ApiEndpoints.dashboardStats),
      ).thenAnswer((_) async => Right(testJsonResponse));

      // Act
      final streamFuture = repository.statsStream.first;
      await repository.getStats(forceRefresh: true);
      final emittedStats = await streamFuture.timeout(Duration(seconds: 2));

      // Assert
      expect(emittedStats, isNotNull);
      expect(emittedStats.nbAcademiciens, 50);
    });

    test('getCachedStatsSync doit retourner null si pas de cache', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      repository = DashboardRepositoryImpl(mockDioClient, prefs);

      // Act
      final stats = repository.getCachedStatsSync();

      // Assert
      expect(stats, isNull);
    });

    test(
      'getCachedStatsSync doit retourner le cache memoire si disponible',
      () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        repository = DashboardRepositoryImpl(mockDioClient, prefs);

        when(
          () => mockDioClient.get<dynamic>(ApiEndpoints.dashboardStats),
        ).thenAnswer((_) async => Right(testJsonResponse));

        // Charger les stats en memoire
        await repository.getStats(forceRefresh: true);

        // Act
        final stats = repository.getCachedStatsSync();

        // Assert
        expect(stats, isNotNull);
        expect(stats?.nbAcademiciens, 50);
      },
    );

    test('getCurrentSeason doit retourner la saison depuis l\'API', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      repository = DashboardRepositoryImpl(mockDioClient, prefs);

      final seasonJson = {
        'id': 'season-1',
        'name': 'Saison 2024-2025',
        'start_date': '2024-09-01T00:00:00.000Z',
        'status': 'open',
      };
      when(
        () => mockDioClient.get<dynamic>('${ApiEndpoints.seasons}/current'),
      ).thenAnswer((_) async => Right(seasonJson));

      // Act
      final (season, error) = await repository.getCurrentSeason();

      // Assert
      expect(season, isNotNull);
      expect(season?.name, 'Saison 2024-2025');
      expect(season?.status, SeasonStatus.open);
      expect(error, isNull);
    });

    test(
      'getCurrentSeason doit retourner null si pas de saison active',
      () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        repository = DashboardRepositoryImpl(mockDioClient, prefs);

        when(
          () => mockDioClient.get<dynamic>('${ApiEndpoints.seasons}/current'),
        ).thenAnswer((_) async => Right({'season': null}));

        // Act
        final (season, error) = await repository.getCurrentSeason();

        // Assert
        expect(season, isNull);
        expect(error, isNull);
      },
    );

    test(
      'openSeason doit appeler l\'API et retourner null si succes',
      () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        repository = DashboardRepositoryImpl(mockDioClient, prefs);

        when(
          () => mockDioClient.post<dynamic>(
            ApiEndpoints.seasons,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => const Right({}));

        // Act
        final error = await repository.openSeason(
          name: 'Saison 2025-2026',
          startDate: DateTime(2025, 9, 1),
        );

        // Assert
        expect(error, isNull);
        verify(
          () => mockDioClient.post<dynamic>(
            ApiEndpoints.seasons,
            data: any(named: 'data'),
          ),
        ).called(1);
      },
    );

    test(
      'closeSeason doit appeler l\'API et retourner null si succes',
      () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        repository = DashboardRepositoryImpl(mockDioClient, prefs);

        when(
          () => mockDioClient.put<dynamic>(
            any(that: contains('season-1')),
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => const Right({}));

        // Act
        final error = await repository.closeSeason(
          seasonId: 'season-1',
          endDate: DateTime(2025, 6, 30),
        );

        // Assert
        expect(error, isNull);
      },
    );
  });
}
