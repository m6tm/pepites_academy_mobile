import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/role_repository_impl.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/domain/entities/role.dart';

// Mocks
class MockDioClient extends Mock implements DioClient {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late RoleRepositoryImpl roleRepository;
  late MockDioClient mockDioClient;
  late MockSharedPreferences mockSharedPrefs;

  setUp(() {
    mockDioClient = MockDioClient();
    mockSharedPrefs = MockSharedPreferences();

    roleRepository = RoleRepositoryImpl(mockDioClient, mockSharedPrefs);
  });

  group('RoleRepositoryImpl - Cache Memory Invalidation', () {
    test(
      'CRITIQUE: clearLocalRole() doit invalider tous les caches memoire',
      () async {
        // Arrange
        when(() => mockSharedPrefs.remove(any()))
            .thenAnswer((_) async => true);

        // Simuler un role en cache
        when(() => mockSharedPrefs.getString('user_role'))
            .thenReturn('encadreur_chef');

        // Charger le role pour remplir le cache memoire
        final initialRole = await roleRepository.getCurrentUserRole();
        expect(initialRole, Role.encadreurChef);

        // Act - Nettoyer le cache
        await roleRepository.clearLocalRole();

        // Assert - Verifier que toutes les cles ont ete supprimees
        verify(() => mockSharedPrefs.remove('user_role')).called(1);
        verify(() => mockSharedPrefs.remove('user_id')).called(1);
        verify(() => mockSharedPrefs.remove('user_first_name')).called(1);
        verify(() => mockSharedPrefs.remove('user_last_name')).called(1);
        verify(() => mockSharedPrefs.remove('user_email')).called(1);
        verify(() => mockSharedPrefs.remove('user_photo')).called(1);

        // Verifier que le cache memoire est vide
        expect(roleRepository.cachedRole, isNull,
            reason: '_cachedRole doit etre null apres clearLocalRole()');
      },
    );

    test(
      'getCurrentUserRole() doit retourner le role depuis le cache memoire si disponible',
      () async {
        // Arrange
        when(() => mockSharedPrefs.getString('user_role'))
            .thenReturn('admin');

        // Act - Premiere lecture (charge depuis SharedPreferences)
        final role1 = await roleRepository.getCurrentUserRole();

        // Act - Deuxieme lecture (doit retourner depuis le cache memoire)
        final role2 = await roleRepository.getCurrentUserRole();

        // Assert
        expect(role1, Role.admin);
        expect(role2, Role.admin);

        // Verifier que getString n'a ete appele qu'une seule fois
        verify(() => mockSharedPrefs.getString('user_role')).called(1);
      },
    );

    test(
      'REGRESSION: Apres clearLocalRole(), getCurrentUserRole() doit lire depuis SharedPreferences',
      () async {
        // Arrange
        when(() => mockSharedPrefs.getString('user_role'))
            .thenReturn('encadreur_chef');
        when(() => mockSharedPrefs.remove(any()))
            .thenAnswer((_) async => true);

        // Act - Charger le role initial (Encadreur Chef)
        final role1 = await roleRepository.getCurrentUserRole();
        expect(role1, Role.encadreurChef);

        // Nettoyer le cache
        await roleRepository.clearLocalRole();

        // Simuler un nouveau role dans SharedPreferences (Admin)
        when(() => mockSharedPrefs.getString('user_role'))
            .thenReturn('admin');

        // Act - Recharger le role (doit lire depuis SharedPreferences, pas le cache)
        final role2 = await roleRepository.getCurrentUserRole();

        // Assert
        expect(role2, Role.admin,
            reason: 'Apres clearLocalRole(), le nouveau role doit etre charge '
                'depuis SharedPreferences');
      },
    );

    test(
      'getCurrentUserRole() doit retourner Role.visiteur si aucun role n\'est stocke',
      () async {
        // Arrange
        when(() => mockSharedPrefs.getString('user_role')).thenReturn(null);

        // Act
        final role = await roleRepository.getCurrentUserRole();

        // Assert
        expect(role, Role.visiteur,
            reason: 'Le role par defaut doit etre visiteur');
      },
    );

    test(
      'persistRoleLocally() doit mettre a jour le cache memoire',
      () async {
        // Arrange
        when(() => mockSharedPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await roleRepository.persistRoleLocally(Role.admin);

        // Assert
        verify(() => mockSharedPrefs.setString('user_role', 'admin')).called(1);
        expect(roleRepository.cachedRole, Role.admin,
            reason: '_cachedRole doit etre mis a jour apres persistRoleLocally()');
      },
    );
  });

  group('RoleRepositoryImpl - Scenario de reconnexion', () {
    test(
      'INTEGRATION: Scenario complet - User1 logout puis User2 login',
      () async {
        // Arrange
        when(() => mockSharedPrefs.getString('user_role'))
            .thenReturn('encadreur_chef');
        when(() => mockSharedPrefs.remove(any()))
            .thenAnswer((_) async => true);
        when(() => mockSharedPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        // ACT 1 - User 1 (Encadreur Chef) se connecte
        final user1Role = await roleRepository.getCurrentUserRole();
        expect(user1Role, Role.encadreurChef);
        expect(roleRepository.cachedRole, Role.encadreurChef);

        // ACT 2 - User 1 se deconnecte
        await roleRepository.clearLocalRole();
        expect(roleRepository.cachedRole, isNull,
            reason: 'Le cache doit etre vide apres logout');

        // ACT 3 - User 2 (Admin) se connecte
        when(() => mockSharedPrefs.getString('user_role')).thenReturn('admin');
        await roleRepository.persistRoleLocally(Role.admin);

        // ACT 4 - Recuperer le role de User 2
        final user2Role = await roleRepository.getCurrentUserRole();

        // ASSERT
        expect(user2Role, Role.admin,
            reason: 'Le role de User 2 doit etre admin, pas encadreur_chef');
        expect(roleRepository.cachedRole, Role.admin);
      },
    );
  });
}
