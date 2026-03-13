import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/domain/entities/sync_operation.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/exercice_local_datasource.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/api_endpoints.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/exercice_repository_impl.dart';
import 'package:pepites_academy_mobile/src/domain/failures/network_failure.dart';

class MockExerciceLocalDatasource extends Mock implements ExerciceLocalDatasource {}
class MockDioClient extends Mock implements DioClient {}
class MockSyncService extends Mock implements SyncService {}

void main() {
  late ExerciceRepositoryImpl repository;
  late MockExerciceLocalDatasource mockDatasource;
  late MockDioClient mockDioClient;
  late MockSyncService mockSyncService;

  const fallbackExercice = Exercice(
    id: '', 
    nom: '', 
    description: '', 
    ordre: 0, 
    statut: ExerciceStatut.cree, 
    atelierId: ''
  );

  setUp(() {
    mockDatasource = MockExerciceLocalDatasource();
    mockDioClient = MockDioClient();
    mockSyncService = MockSyncService();
    repository = ExerciceRepositoryImpl(mockDatasource);
    repository.setDioClient(mockDioClient);
    repository.setSyncService(mockSyncService);

    registerFallbackValue(SyncEntityType.exercice);
    registerFallbackValue(SyncOperationType.create);
    registerFallbackValue(fallbackExercice);
    registerFallbackValue(<Exercice>[]);
  });

  group('ExerciceRepositoryImpl', () {
    const testExercice = Exercice(
      id: '1',
      atelierId: 'atelier-1',
      nom: 'Test Exercice',
      description: 'Desc',
      ordre: 1,
      statut: ExerciceStatut.cree,
    );

    test('getByAtelierId doit retourner les données locales si présentes', () async {
      // Arrange
      when(() => mockDatasource.getByAtelier('atelier-1'))
          .thenReturn(<Exercice>[testExercice]);

      // Act
      final result = await repository.getByAtelierId('atelier-1');

      // Assert
      expect(result, [testExercice]);
      verify(() => mockDatasource.getByAtelier('atelier-1')).called(1);
    });

    test('getByAtelierId doit synchroniser si le cache local est vide', () async {
      // Arrange
      when(() => mockDatasource.getByAtelier('atelier-1'))
          .thenReturn(<Exercice>[]);
      when(() => mockDioClient.get<dynamic>(ApiEndpoints.exercices))
          .thenAnswer((_) async => Right([testExercice.toJson()]));
      when(() => mockDatasource.upsertAll(any()))
          .thenAnswer((_) async => Future<void>.value());

      // Act
      await repository.getByAtelierId('atelier-1');

      // Assert
      verify(() => mockDioClient.get(ApiEndpoints.exercices)).called(1);
      verify(() => mockDatasource.upsertAll(any())).called(1);
    });

    test('reorder doit mettre à jour localement et enfiler une opération de sync', () async {
      // Arrange
      final ids = ['1', '2'];
      when(() => mockDatasource.reorder('atelier-1', ids))
          .thenAnswer((_) async => <Exercice>[]);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Future<void>.value());

      // Act
      await repository.reorder('atelier-1', ids);

      // Assert
      verify(() => mockDatasource.reorder('atelier-1', ids)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.exercice,
            entityId: 'atelier-1',
            operationType: SyncOperationType.reorder,
            data: {
              'atelier_id': 'atelier-1',
              'exercice_ids': ids,
            },
          )).called(1);
    });

    test('update doit mettre à jour localement et enfiler une opération de sync', () async {
      // Arrange
      when(() => mockDatasource.update(testExercice)).thenAnswer((_) async => testExercice);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Future<void>.value());

      // Act
      final result = await repository.update(testExercice);

      // Assert
      expect(result, testExercice);
      verify(() => mockDatasource.update(testExercice)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.exercice,
            entityId: testExercice.id,
            operationType: SyncOperationType.update,
            data: any(named: 'data'),
          )).called(1);
    });

    test('delete doit supprimer localement et enfiler une opération de sync', () async {
      // Arrange
      when(() => mockDatasource.delete('1')).thenAnswer((_) async => Future<void>.value());
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Future<void>.value());

      // Act
      await repository.delete('1');

      // Assert
      verify(() => mockDatasource.delete('1')).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.exercice,
            entityId: '1',
            operationType: SyncOperationType.delete,
            data: {'id': '1'},
          )).called(1);
    });

    test('getById doit déléguer au datasource local', () async {
      // Arrange
      when(() => mockDatasource.getById('1')).thenReturn(testExercice);

      // Act
      final result = await repository.getById('1');

      // Assert
      expect(result, testExercice);
      verify(() => mockDatasource.getById('1')).called(1);
    });

    test('syncFromApi doit gérer une réponse sous forme de Map', () async {
      // Arrange
      final mapData = {
        'exercices': [testExercice.toJson()]
      };
      when(() => mockDioClient.get<dynamic>(ApiEndpoints.exercices))
          .thenAnswer((_) async => Right(mapData));
      when(() => mockDatasource.upsertAll(any()))
          .thenAnswer((_) async => Future<void>.value());

      // Act
      final result = await repository.syncFromApi();

      // Assert
      expect(result, isTrue);
      verify(() => mockDatasource.upsertAll(any())).called(1);
    });

    test('syncFromApi doit retourner false en cas de failure API', () async {
      // Arrange
      when(() => mockDioClient.get<dynamic>(ApiEndpoints.exercices))
          .thenAnswer((_) async => const Left(NetworkFailure(type: NetworkFailureType.serverError)));

      // Act
      final result = await repository.syncFromApi();

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockDatasource.upsertAll(any()));
    });

    group('close', () {
      const closableExercice = Exercice(
        id: '1',
        atelierId: 'atelier-1',
        nom: 'Test Exercice',
        description: 'Desc',
        ordre: 1,
        statut: ExerciceStatut.applique,
      );

      test('doit mettre a jour le statut local et retourner true si atelier_closed est true', () async {
        // Arrange
        when(() => mockDatasource.getById('1')).thenReturn(closableExercice);
        when(() => mockDatasource.update(any())).thenAnswer(
            (inv) async => inv.positionalArguments[0] as Exercice);
        when(() => mockDioClient.put<dynamic>(
              '${ApiEndpoints.exercices}/1/close',
              data: any(named: 'data'),
            )).thenAnswer((_) async => const Right({'atelier_closed': true}));

        // Act
        final result = await repository.close('1');

        // Assert
        expect(result, isTrue);
        verify(() => mockDatasource.update(
            any(that: predicate<Exercice>((e) => e.statut == ExerciceStatut.ferme)),
        )).called(1);
        verify(() => mockDioClient.put<dynamic>(
              '${ApiEndpoints.exercices}/1/close',
              data: any(named: 'data'),
            )).called(1);
      });

      test('doit retourner false si atelier_closed est false', () async {
        // Arrange
        when(() => mockDatasource.getById('1')).thenReturn(closableExercice);
        when(() => mockDatasource.update(any())).thenAnswer(
            (inv) async => inv.positionalArguments[0] as Exercice);
        when(() => mockDioClient.put<dynamic>(
              '${ApiEndpoints.exercices}/1/close',
              data: any(named: 'data'),
            )).thenAnswer((_) async => const Right({'atelier_closed': false}));

        // Act
        final result = await repository.close('1');

        // Assert
        expect(result, isFalse);
      });

      test('doit retourner false en cas d erreur API et enfiler une operation de sync', () async {
        // Arrange
        when(() => mockDatasource.getById('1')).thenReturn(closableExercice);
        when(() => mockDatasource.update(any())).thenAnswer(
            (inv) async => inv.positionalArguments[0] as Exercice);
        when(() => mockDioClient.put<dynamic>(
              '${ApiEndpoints.exercices}/1/close',
              data: any(named: 'data'),
            )).thenAnswer((_) async => const Left(
              NetworkFailure(type: NetworkFailureType.serverError),
            ));

        // Act
        final result = await repository.close('1');

        // Assert
        expect(result, isFalse);
        // Le statut local doit quand meme avoir ete mis a jour
        verify(() => mockDatasource.update(
            any(that: predicate<Exercice>((e) => e.statut == ExerciceStatut.ferme)),
        )).called(1);
      });

      test('doit mettre a jour localement et enfiler la sync si hors-ligne (pas de dioClient)', () async {
        // Arrange : repository sans DioClient (mode hors-ligne)
        final offlineRepository = ExerciceRepositoryImpl(mockDatasource);
        offlineRepository.setSyncService(mockSyncService);

        when(() => mockDatasource.getById('1')).thenReturn(closableExercice);
        when(() => mockDatasource.update(any())).thenAnswer(
            (inv) async => inv.positionalArguments[0] as Exercice);
        when(() => mockSyncService.enqueueOperation(
              entityType: any(named: 'entityType'),
              entityId: any(named: 'entityId'),
              operationType: any(named: 'operationType'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Future<void>.value());

        // Act
        final result = await offlineRepository.close('1');

        // Assert
        expect(result, isFalse);
        verify(() => mockDatasource.update(
            any(that: predicate<Exercice>((e) => e.statut == ExerciceStatut.ferme)),
        )).called(1);
        verify(() => mockSyncService.enqueueOperation(
              entityType: SyncEntityType.exercice,
              entityId: '1',
              operationType: SyncOperationType.update,
              data: {'statut': 'ferme'},
            )).called(1);
      });

      test('doit gerer le cas ou l exercice n existe pas localement', () async {
        // Arrange
        when(() => mockDatasource.getById('unknown')).thenReturn(null);
        when(() => mockDioClient.put<dynamic>(
              '${ApiEndpoints.exercices}/unknown/close',
              data: any(named: 'data'),
            )).thenAnswer((_) async => const Right({'atelier_closed': false}));

        // Act
        final result = await repository.close('unknown');

        // Assert
        expect(result, isFalse);
        // Le datasource.update ne doit pas etre appele si l'exercice est introuvable
        verifyNever(() => mockDatasource.update(any()));
      });
    });
  });
}
