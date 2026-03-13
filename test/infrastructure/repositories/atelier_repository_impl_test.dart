import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/sync_operation.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/atelier_local_datasource.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/api_endpoints.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/atelier_repository_impl.dart';
import 'package:pepites_academy_mobile/src/domain/failures/network_failure.dart';

class MockAtelierLocalDatasource extends Mock implements AtelierLocalDatasource {}
class MockDioClient extends Mock implements DioClient {}
class MockSyncService extends Mock implements SyncService {}

void main() {
  late AtelierRepositoryImpl repository;
  late MockAtelierLocalDatasource mockDatasource;
  late MockDioClient mockDioClient;
  late MockSyncService mockSyncService;

  const fallbackAtelier = Atelier(
    id: '', 
    nom: '', 
    description: '', 
    type: AtelierType.physique, 
    ordre: 0, 
    statut: AtelierStatut.cree, 
    seanceId: ''
  );

  setUp(() {
    mockDatasource = MockAtelierLocalDatasource();
    mockDioClient = MockDioClient();
    mockSyncService = MockSyncService();
    repository = AtelierRepositoryImpl(mockDatasource);
    repository.setDioClient(mockDioClient);
    repository.setSyncService(mockSyncService);

    registerFallbackValue(SyncEntityType.atelier);
    registerFallbackValue(SyncOperationType.create);
    registerFallbackValue(fallbackAtelier);
    registerFallbackValue(<Atelier>[]);
  });

  group('AtelierRepositoryImpl', () {
    const testAtelier = Atelier(
      id: '1',
      seanceId: 'seance-1',
      nom: 'Test Atelier',
      description: 'Desc',
      ordre: 1,
      type: AtelierType.tactique,
      statut: AtelierStatut.cree,
    );

    test('getBySeanceId doit retourner les données locales si présentes', () async {
      // Arrange
      when(() => mockDatasource.getBySeance('seance-1'))
          .thenReturn(<Atelier>[testAtelier]);

      // Act
      final result = await repository.getBySeanceId('seance-1');

      // Assert
      expect(result, [testAtelier]);
      verify(() => mockDatasource.getBySeance('seance-1')).called(1);
    });

    test('getBySeanceId doit synchroniser si le cache local est vide', () async {
      // Arrange
      when(() => mockDatasource.getBySeance('seance-1'))
          .thenReturn(<Atelier>[]);
      when(() => mockDioClient.get<dynamic>(ApiEndpoints.ateliers))
          .thenAnswer((_) async => Right([testAtelier.toJson()]));
      when(() => mockDatasource.upsertAll(any()))
          .thenAnswer((_) async => Future<void>.value());

      // Act
      await repository.getBySeanceId('seance-1');

      // Assert
      verify(() => mockDioClient.get(ApiEndpoints.ateliers)).called(1);
      verify(() => mockDatasource.upsertAll(any())).called(1);
    });

    test('create doit ajouter localement et enfiler une opération de sync', () async {
      // Arrange
      when(() => mockDatasource.add(any())).thenAnswer((_) async => testAtelier);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Future<void>.value());

      // Act
      final result = await repository.create(testAtelier);

      // Assert
      expect(result, testAtelier);
      verify(() => mockDatasource.add(testAtelier)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.atelier,
            entityId: testAtelier.id,
            operationType: SyncOperationType.create,
            data: any(named: 'data'),
          )).called(1);
    });

    test('reorder doit mettre à jour localement et enfiler une opération de sync', () async {
      // Arrange
      final ids = ['1', '2'];
      when(() => mockDatasource.reorder('seance-1', ids))
          .thenAnswer((_) async => <Atelier>[]);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Future<void>.value());

      // Act
      await repository.reorder('seance-1', ids);

      // Assert
      verify(() => mockDatasource.reorder('seance-1', ids)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.atelier,
            entityId: 'seance-1',
            operationType: SyncOperationType.reorder,
            data: {
              'seance_id': 'seance-1',
              'atelier_ids': ids,
            },
          )).called(1);
    });

    test('update doit mettre à jour localement et enfiler une opération de sync', () async {
      // Arrange
      when(() => mockDatasource.update(testAtelier)).thenAnswer((_) async => testAtelier);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Future<void>.value());

      // Act
      final result = await repository.update(testAtelier);

      // Assert
      expect(result, testAtelier);
      verify(() => mockDatasource.update(testAtelier)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.atelier,
            entityId: testAtelier.id,
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
            entityType: SyncEntityType.atelier,
            entityId: '1',
            operationType: SyncOperationType.delete,
            data: {'id': '1'},
          )).called(1);
    });

    test('getById doit déléguer au datasource local', () async {
      // Arrange
      when(() => mockDatasource.getById('1')).thenReturn(testAtelier);

      // Act
      final result = await repository.getById('1');

      // Assert
      expect(result, testAtelier);
      verify(() => mockDatasource.getById('1')).called(1);
    });

    test('syncFromApi doit gérer une réponse sous forme de Map', () async {
      // Arrange
      final mapData = {
        'ateliers': [testAtelier.toJson()]
      };
      when(() => mockDioClient.get<dynamic>(ApiEndpoints.ateliers))
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
      when(() => mockDioClient.get<dynamic>(ApiEndpoints.ateliers))
          .thenAnswer((_) async => const Left(NetworkFailure(type: NetworkFailureType.serverError)));

      // Act
      final result = await repository.syncFromApi();

      // Assert
      expect(result, isFalse);
      verifyNever(() => mockDatasource.upsertAll(any()));
    });
  });
}
