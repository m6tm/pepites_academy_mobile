import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/dashboard_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/dashboard_stats.dart';
import 'package:pepites_academy_mobile/src/domain/entities/global_stats.dart';
import 'package:pepites_academy_mobile/src/domain/failures/network_failure.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/dashboard_repository.dart';

// Mock du repository
class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late DashboardService service;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    service = DashboardService(repository: mockRepository);
  });

  group('DashboardService', () {
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

    final testSeason = Season(
      id: 'season-1',
      name: 'Saison 2024-2025',
      startDate: DateTime(2024, 9, 1),
      status: SeasonStatus.open,
    );

    test('getStats doit retourner les statistiques du repository', () async {
      // Arrange
      when(
        () => mockRepository.getStats(forceRefresh: false),
      ).thenAnswer((_) async => (testDashboardStats, null, false));

      // Act
      final (stats, error, isFromCache) = await service.getStats();

      // Assert
      expect(stats, testDashboardStats);
      expect(error, isNull);
      expect(isFromCache, false);
      verify(() => mockRepository.getStats(forceRefresh: false)).called(1);
    });

    test(
      'getStats avec forceRefresh doit forcer le rafraichissement',
      () async {
        // Arrange
        when(
          () => mockRepository.getStats(forceRefresh: true),
        ).thenAnswer((_) async => (testDashboardStats, null, false));

        // Act
        final (stats, error, isFromCache) = await service.getStats(
          forceRefresh: true,
        );

        // Assert
        expect(stats, testDashboardStats);
        verify(() => mockRepository.getStats(forceRefresh: true)).called(1);
      },
    );

    test(
      'getStats doit retourner une erreur si le repository echoue',
      () async {
        // Arrange
        const failure = NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur serveur',
        );
        when(
          () => mockRepository.getStats(forceRefresh: false),
        ).thenAnswer((_) async => (null, failure, false));

        // Act
        final (stats, error, isFromCache) = await service.getStats();

        // Assert
        expect(stats, isNull);
        expect(error, failure);
        expect(isFromCache, false);
      },
    );

    test('getCurrentSeason doit retourner la saison en cours', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentSeason(),
      ).thenAnswer((_) async => (testSeason, null));

      // Act
      final (season, error) = await service.getCurrentSeason();

      // Assert
      expect(season, testSeason);
      expect(error, isNull);
      verify(() => mockRepository.getCurrentSeason()).called(1);
    });

    test(
      'getCurrentSeason doit retourner null si pas de saison active',
      () async {
        // Arrange
        when(
          () => mockRepository.getCurrentSeason(),
        ).thenAnswer((_) async => (null, null));

        // Act
        final (season, error) = await service.getCurrentSeason();

        // Assert
        expect(season, isNull);
        expect(error, isNull);
      },
    );

    test('openSeason doit deleguer au repository', () async {
      // Arrange
      when(
        () => mockRepository.openSeason(
          name: any(named: 'name'),
          startDate: any(named: 'startDate'),
        ),
      ).thenAnswer((_) async => null);

      // Act
      final error = await service.openSeason(
        name: 'Saison 2025-2026',
        startDate: DateTime(2025, 9, 1),
      );

      // Assert
      expect(error, isNull);
      verify(
        () => mockRepository.openSeason(
          name: 'Saison 2025-2026',
          startDate: DateTime(2025, 9, 1),
        ),
      ).called(1);
    });

    test(
      'openSeason doit retourner une erreur si le repository echoue',
      () async {
        // Arrange
        const failure = NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur creation saison',
        );
        when(
          () => mockRepository.openSeason(
            name: any(named: 'name'),
            startDate: any(named: 'startDate'),
          ),
        ).thenAnswer((_) async => failure);

        // Act
        final error = await service.openSeason(
          name: 'Saison 2025-2026',
          startDate: DateTime(2025, 9, 1),
        );

        // Assert
        expect(error, failure);
      },
    );

    test('closeSeason doit deleguer au repository', () async {
      // Arrange
      when(
        () => mockRepository.closeSeason(
          seasonId: any(named: 'seasonId'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => null);

      // Act
      final error = await service.closeSeason(
        seasonId: 'season-1',
        endDate: DateTime(2025, 6, 30),
      );

      // Assert
      expect(error, isNull);
      verify(
        () => mockRepository.closeSeason(
          seasonId: 'season-1',
          endDate: DateTime(2025, 6, 30),
        ),
      ).called(1);
    });

    test('refreshStats doit forcer le rafraichissement', () async {
      // Arrange
      when(
        () => mockRepository.getStats(forceRefresh: true),
      ).thenAnswer((_) async => (testDashboardStats, null, false));

      // Act
      final (stats, error, isFromCache) = await service.refreshStats();

      // Assert
      expect(stats, testDashboardStats);
      verify(() => mockRepository.getStats(forceRefresh: true)).called(1);
    });

    test('invalidateCache doit deleguer au repository', () async {
      // Arrange
      when(() => mockRepository.invalidateCache()).thenAnswer((_) async {});

      // Act
      await service.invalidateCache();

      // Assert
      verify(() => mockRepository.invalidateCache()).called(1);
    });

    test('getCachedStatsSync doit retourner le cache du repository', () {
      // Arrange
      when(
        () => mockRepository.getCachedStatsSync(),
      ).thenReturn(testDashboardStats);

      // Act
      final stats = service.getCachedStatsSync();

      // Assert
      expect(stats, testDashboardStats);
      verify(() => mockRepository.getCachedStatsSync()).called(1);
    });

    test('statsStream doit retourner le stream du repository', () {
      // Arrange
      final controller = StreamController<DashboardStats>();
      when(() => mockRepository.statsStream).thenReturn(controller.stream);

      // Act
      final stream = service.statsStream;

      // Assert
      expect(stream, isA<Stream<DashboardStats>>());
      verify(() => mockRepository.statsStream).called(1);

      controller.close();
    });

    test('nbAcademiciens doit retourner la valeur du cache', () {
      // Arrange
      when(
        () => mockRepository.getCachedStatsSync(),
      ).thenReturn(testDashboardStats);

      // Act
      final count = service.nbAcademiciens;

      // Assert
      expect(count, 50);
    });

    test('nbEncadreurs doit retourner la valeur du cache', () {
      // Arrange
      when(
        () => mockRepository.getCachedStatsSync(),
      ).thenReturn(testDashboardStats);

      // Act
      final count = service.nbEncadreurs;

      // Assert
      expect(count, 10);
    });

    test('nbSeancesJour doit retourner la valeur du cache', () {
      // Arrange
      when(
        () => mockRepository.getCachedStatsSync(),
      ).thenReturn(testDashboardStats);

      // Act
      final count = service.nbSeancesJour;

      // Assert
      expect(count, 2);
    });

    test('nbPresencesJour doit retourner la valeur du cache', () {
      // Arrange
      when(
        () => mockRepository.getCachedStatsSync(),
      ).thenReturn(testDashboardStats);

      // Act
      final count = service.nbPresencesJour;

      // Assert
      expect(count, 45);
    });

    test('hasActiveSeason doit retourner true si saison active', () {
      // Arrange
      final statsWithSeason = DashboardStats(
        globalStats: testGlobalStats,
        currentSeason: testSeason,
      );
      when(
        () => mockRepository.getCachedStatsSync(),
      ).thenReturn(statsWithSeason);

      // Act
      final hasSeason = service.hasActiveSeason;

      // Assert
      expect(hasSeason, isTrue);
    });

    test('hasActiveSeason doit retourner false si pas de cache', () {
      // Arrange
      when(() => mockRepository.getCachedStatsSync()).thenReturn(null);

      // Act
      final hasSeason = service.hasActiveSeason;

      // Assert
      expect(hasSeason, isFalse);
    });
  });
}
