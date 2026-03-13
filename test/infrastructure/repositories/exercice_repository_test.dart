import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/domain/entities/sync_operation.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/exercice_local_datasource.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/exercice_repository_impl.dart';

class MockExerciceLocalDatasource extends Mock implements ExerciceLocalDatasource {}
class MockSyncService extends Mock implements SyncService {}
class MockDioClient extends Mock implements DioClient {}

void main() {
  late ExerciceRepositoryImpl repository;
  late MockExerciceLocalDatasource mockDatasource;
  late MockSyncService mockSyncService;
  late MockDioClient mockDioClient;

  const tExercice = Exercice(
    id: '1',
    nom: 'Passement de jambes',
    description: 'Desc',
    ordre: 1,
    statut: ExerciceStatut.cree,
    atelierId: '10',
  );

  setUp(() {
    mockDatasource = MockExerciceLocalDatasource();
    mockSyncService = MockSyncService();
    mockDioClient = MockDioClient();
    repository = ExerciceRepositoryImpl(mockDatasource);
    repository.setSyncService(mockSyncService);
    repository.setDioClient(mockDioClient);
    
    registerFallbackValue(tExercice);
    registerFallbackValue(SyncEntityType.exercice);
    registerFallbackValue(SyncOperationType.create);
  });

  group('getByAtelierId', () {
    test('should return local data if available', () async {
      when(() => mockDatasource.getByAtelier(any())).thenReturn([tExercice]);

      final result = await repository.getByAtelierId('10');

      expect(result, [tExercice]);
      verify(() => mockDatasource.getByAtelier('10')).called(1);
    });
  });

  group('close', () {
    test('should update locally and call API, returning true if atelier also closed', () async {
      when(() => mockDatasource.getById(any())).thenReturn(tExercice);
      when(() => mockDatasource.update(any())).thenAnswer((_) async => tExercice);
      when(() => mockDioClient.put<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => const Right({'atelier_closed': true}),
      );

      final result = await repository.close('1');

      expect(result, true);
      verify(() => mockDatasource.update(any())).called(1);
      verify(() => mockDioClient.put<dynamic>(any(), data: any(named: 'data'))).called(1);
    });

    test('should enqueue sync operation if offline', () async {
      // Offline scenario: new repository without DioClient
      final offlineRepo = ExerciceRepositoryImpl(mockDatasource);
      offlineRepo.setSyncService(mockSyncService);
      
      when(() => mockDatasource.getById(any())).thenReturn(tExercice);
      when(() => mockDatasource.update(any())).thenAnswer((_) async => tExercice);
      
      when(() => mockSyncService.enqueueOperation(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        operationType: any(named: 'operationType'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await offlineRepo.close('1');

      expect(result, false);
      verify(() => mockSyncService.enqueueOperation(
        entityType: SyncEntityType.exercice,
        entityId: '1',
        operationType: SyncOperationType.update,
        data: {'statut': 'ferme'},
      )).called(1);
    });
  });
}
