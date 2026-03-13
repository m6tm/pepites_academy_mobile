import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/sync_operation.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/atelier_local_datasource.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/atelier_repository_impl.dart';

class MockAtelierLocalDatasource extends Mock implements AtelierLocalDatasource {}
class MockSyncService extends Mock implements SyncService {}
class MockDioClient extends Mock implements DioClient {}

void main() {
  late AtelierRepositoryImpl repository;
  late MockAtelierLocalDatasource mockDatasource;
  late MockSyncService mockSyncService;
  late MockDioClient mockDioClient;

  const tAtelier = Atelier(
    id: '1',
    nom: 'Dribble',
    description: 'Desc',
    type: AtelierType.dribble,
    ordre: 1,
    statut: AtelierStatut.cree,
    seanceId: '42',
  );

  setUp(() {
    mockDatasource = MockAtelierLocalDatasource();
    mockSyncService = MockSyncService();
    mockDioClient = MockDioClient();
    repository = AtelierRepositoryImpl(mockDatasource);
    repository.setSyncService(mockSyncService);
    repository.setDioClient(mockDioClient);

    registerFallbackValue(tAtelier);
    registerFallbackValue(SyncEntityType.atelier);
    registerFallbackValue(SyncOperationType.create);
  });

  group('getBySeanceId', () {
    test('should return local data if available', () async {
      when(() => mockDatasource.getBySeance(any())).thenReturn([tAtelier]);

      final result = await repository.getBySeanceId('42');

      expect(result, [tAtelier]);
      verify(() => mockDatasource.getBySeance('42')).called(1);
    });

    test('should sync from API if local data is empty', () async {
      int callCount = 0;
      when(() => mockDatasource.getBySeance(any())).thenAnswer((_) {
        if (callCount == 0) {
          callCount++;
          return [];
        }
        return [tAtelier];
      });
      when(() => mockDioClient.get<dynamic>(any())).thenAnswer(
        (_) async => Right([tAtelier.toJson()]),
      );
      when(() => mockDatasource.upsertAll(any())).thenAnswer((_) async {});

      final result = await repository.getBySeanceId('42');

      expect(result, [tAtelier]);
      verify(() => mockDioClient.get<dynamic>(any())).called(1);
      verify(() => mockDatasource.upsertAll(any())).called(1);
    });
  });

  group('create', () {
    test('should save locally and enqueue sync operation', () async {
      when(() => mockDatasource.add(any())).thenAnswer((_) async => tAtelier);
      when(() => mockSyncService.enqueueOperation(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        operationType: any(named: 'operationType'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.create(tAtelier);

      expect(result, tAtelier);
      verify(() => mockDatasource.add(tAtelier)).called(1);
      verify(() => mockSyncService.enqueueOperation(
        entityType: SyncEntityType.atelier,
        entityId: '1',
        operationType: SyncOperationType.create,
        data: tAtelier.toJson(),
      )).called(1);
    });
  });

  group('reorder', () {
    test('should call datasource reorder and enqueue sync operation', () async {
      when(() => mockDatasource.reorder(any(), any())).thenAnswer((_) async => []);
      when(() => mockSyncService.enqueueOperation(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        operationType: any(named: 'operationType'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final ids = ['1', '2'];
      await repository.reorder('42', ids);

      verify(() => mockDatasource.reorder('42', ids)).called(1);
      verify(() => mockSyncService.enqueueOperation(
        entityType: SyncEntityType.atelier,
        entityId: '42',
        operationType: SyncOperationType.reorder,
        data: {'order': ids},
      )).called(1);
    });
  });
}
