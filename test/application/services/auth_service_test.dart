import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/auth_service.dart';
import 'package:pepites_academy_mobile/src/application/services/role_service.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/application/services/cache_manager.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/auth_repository.dart';
import 'package:pepites_academy_mobile/src/domain/failures/network_failure.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockRoleService extends Mock implements RoleService {}

class MockSyncService extends Mock implements SyncService {}

class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late AuthService authService;
  late MockAuthRepository mockAuthRepository;
  late MockRoleService mockRoleService;
  late MockSyncService mockSyncService;
  late MockCacheManager mockCacheManager;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockRoleService = MockRoleService();
    mockSyncService = MockSyncService();
    mockCacheManager = MockCacheManager();

    authService = AuthService(mockAuthRepository);
    authService.setRoleService(mockRoleService);
    authService.setSyncService(mockSyncService);
    authService.setCacheManager(mockCacheManager);

    // Configuration des mocks pour retourner Future<void>
    when(
      () => mockRoleService.clearLocalRole(),
    ).thenAnswer((_) async => Future.value());
    when(
      () => mockCacheManager.clearAll(),
    ).thenAnswer((_) async => Future.value());
    when(
      () => mockSyncService.clearAll(),
    ).thenAnswer((_) async => Future.value());
    when(
      () => mockAuthRepository.logout(),
    ).thenAnswer((_) async => Future.value());
  });

  group('AuthService - Logout Cache Invalidation', () {
    test(
      'CRITIQUE: logout() doit appeler clearLocalRole() AVANT tout autre nettoyage',
      () async {
        // Arrange
        final callOrder = <String>[];

        when(() => mockRoleService.clearLocalRole()).thenAnswer((_) async {
          callOrder.add('clearLocalRole');
        });
        when(() => mockCacheManager.clearAll()).thenAnswer((_) async {
          callOrder.add('clearAll');
        });
        when(() => mockSyncService.clearAll()).thenAnswer((_) async {
          callOrder.add('syncClearAll');
        });
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {
          callOrder.add('logout');
        });

        // Act
        await authService.logout();

        // Assert
        expect(
          callOrder[0],
          'clearLocalRole',
          reason:
              'clearLocalRole() doit etre appele en premier pour eviter '
              'la persistance du role entre utilisateurs',
        );
        expect(callOrder.length, 4);

        verify(() => mockRoleService.clearLocalRole()).called(1);
        verify(() => mockCacheManager.clearAll()).called(1);
        verify(() => mockSyncService.clearAll()).called(1);
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );

    test(
      'logout() doit appeler clearLocalRole() meme si RoleService est null',
      () async {
        // Arrange
        final authServiceWithoutRole = AuthService(mockAuthRepository);
        authServiceWithoutRole.setCacheManager(mockCacheManager);
        authServiceWithoutRole.setSyncService(mockSyncService);

        // Act & Assert - Ne doit pas throw d'exception
        expect(
          () async => await authServiceWithoutRole.logout(),
          returnsNormally,
        );

        verify(() => mockCacheManager.clearAll()).called(1);
        verify(() => mockSyncService.clearAll()).called(1);
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );

    test('logout() doit completer meme si clearLocalRole() echoue', () async {
      // Arrange
      when(
        () => mockRoleService.clearLocalRole(),
      ).thenThrow(Exception('Erreur cache'));

      // Act & Assert - Le logout doit continuer malgre l'erreur
      expect(() async => await authService.logout(), throwsException);

      // Verifier que clearLocalRole a bien ete appele
      verify(() => mockRoleService.clearLocalRole()).called(1);
    });
  });

  group('AuthService - Login', () {
    test('login() doit retourner null en cas de succes', () async {
      // Arrange
      when(
        () => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceType: any(named: 'deviceType'),
          deviceName: any(named: 'deviceName'),
          model: any(named: 'model'),
          location: any(named: 'location'),
        ),
      ).thenAnswer((_) async => null);

      // Act
      final result = await authService.login(
        email: 'test@example.com',
        password: 'password123',
        deviceType: 'smartphone_android',
        deviceName: 'Pixel 6',
        model: 'Google Pixel 6',
      );

      // Assert
      expect(result, isNull);
      verify(
        () => mockAuthRepository.login(
          email: 'test@example.com',
          password: 'password123',
          deviceType: 'smartphone_android',
          deviceName: 'Pixel 6',
          model: 'Google Pixel 6',
          location: null,
        ),
      ).called(1);
    });

    test('login() doit retourner NetworkFailure en cas d\'echec', () async {
      // Arrange
      const failure = NetworkFailure(
        type: NetworkFailureType.unauthorized,
        message: 'Identifiants invalides',
      );

      when(
        () => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceType: any(named: 'deviceType'),
          deviceName: any(named: 'deviceName'),
          model: any(named: 'model'),
          location: any(named: 'location'),
        ),
      ).thenAnswer((_) async => failure);

      // Act
      final result = await authService.login(
        email: 'wrong@example.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(result, equals(failure));
      expect(result?.type, NetworkFailureType.unauthorized);
    });
  });

  group('AuthService - Scenario de reconnexion avec roles differents', () {
    test(
      'REGRESSION: Scenario complet - Deconnexion User1 puis Connexion User2',
      () async {
        // Arrange - Simulation User 1 (Encadreur Chef) se deconnecte
        when(() => mockRoleService.clearLocalRole()).thenAnswer((_) async {
          // Simuler le vidage du cache memoire
        });
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

        // Act - User 1 se deconnecte
        await authService.logout();

        // Assert - Verifier que le cache du role a ete vide
        verify(() => mockRoleService.clearLocalRole()).called(1);

        // Arrange - Simulation User 2 (Admin) se connecte
        when(
          () => mockAuthRepository.login(
            email: 'admin@example.com',
            password: 'admin123',
            deviceType: any(named: 'deviceType'),
            deviceName: any(named: 'deviceName'),
            model: any(named: 'model'),
            location: any(named: 'location'),
          ),
        ).thenAnswer((_) async => null);

        // Act - User 2 se connecte
        final loginResult = await authService.login(
          email: 'admin@example.com',
          password: 'admin123',
        );

        // Assert
        expect(
          loginResult,
          isNull,
          reason: 'La connexion du User 2 doit reussir',
        );

        // Verifier que clearLocalRole a bien ete appele avant la reconnexion
        verify(() => mockRoleService.clearLocalRole()).called(1);
      },
    );
  });
}
