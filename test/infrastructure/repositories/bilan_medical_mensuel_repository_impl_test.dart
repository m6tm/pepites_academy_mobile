import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/core/events/bilan_medical_mensuel_events.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event_bus.dart';
import 'package:pepites_academy_mobile/src/core/events/invalidation_registry.dart';
import 'package:pepites_academy_mobile/src/domain/entities/bilan_medical_mensuel.dart';
import 'package:pepites_academy_mobile/src/domain/entities/sync_operation.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/bilan_medical_mensuel_local_datasource.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/api_endpoints.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/bilan_medical_mensuel_repository_impl.dart';

class MockBilanMedicalMensuelLocalDatasource extends Mock
    implements BilanMedicalMensuelLocalDatasource {}

class MockDioClient extends Mock implements DioClient {}

class MockSyncService extends Mock implements SyncService {}

class MockDomainEventBus extends Mock implements DomainEventBus {}

class MockInvalidationRegistry extends Mock implements InvalidationRegistry {}

class FakeDomainEvent extends Fake implements DomainEvent {}

void main() {
  late BilanMedicalMensuelRepositoryImpl repository;
  late MockBilanMedicalMensuelLocalDatasource mockDatasource;
  late MockDioClient mockDioClient;
  late MockSyncService mockSyncService;
  late MockDomainEventBus mockEventBus;
  late MockInvalidationRegistry mockRegistry;

  final testBilan = BilanMedicalMensuel(
    id: 'bm-1',
    academicienId: 'acad-1',
    medecinId: 'med-1',
    mois: 5,
    annee: 2026,
    blessuresMusculaire: 2,
    blessuresArticulaire: 1,
    blessuresTraumatique: 0,
    createdAt: DateTime(2026, 5, 1),
  );

  setUp(() {
    mockDatasource = MockBilanMedicalMensuelLocalDatasource();
    mockDioClient = MockDioClient();
    mockSyncService = MockSyncService();
    mockEventBus = MockDomainEventBus();
    mockRegistry = MockInvalidationRegistry();

    repository = BilanMedicalMensuelRepositoryImpl(mockDatasource);
    repository.setDioClient(mockDioClient);
    repository.setSyncService(mockSyncService);
    repository.setEventBus(mockEventBus);
    repository.setInvalidationRegistry(mockRegistry);

    registerFallbackValue(SyncEntityType.bilanMedicalMensuel);
    registerFallbackValue(SyncOperationType.create);
    registerFallbackValue(testBilan);
    registerFallbackValue(<BilanMedicalMensuel>[]);
    registerFallbackValue(FakeDomainEvent());
  });

  group('BilanMedicalMensuelRepositoryImpl', () {
    test('getByAcademicienId doit retourner les donnees locales', () async {
      when(() => mockDatasource.getByAcademicienId('acad-1'))
          .thenAnswer((_) async => [testBilan]);

      final result = await repository.getByAcademicienId('acad-1');

      expect(result, [testBilan]);
      verify(() => mockDatasource.getByAcademicienId('acad-1')).called(1);
    });

    test('getById doit retourner un bilan par son id', () async {
      when(() => mockDatasource.getById('bm-1'))
          .thenAnswer((_) async => testBilan);

      final result = await repository.getById('bm-1');

      expect(result, testBilan);
    });

    test(
        'create doit persister localement, invalider le cache et emettre un event',
        () async {
      when(() => mockDatasource.create(testBilan))
          .thenAnswer((_) async => testBilan);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});
      when(() => mockEventBus.emit(any())).thenReturn(null);
      when(() => mockRegistry.markInvalidated<BilanMedicalMensuelCreatedEvent>())
          .thenReturn(null);

      final result = await repository.create(testBilan);

      expect(result, testBilan);
      verify(() => mockDatasource.create(testBilan)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.bilanMedicalMensuel,
            entityId: testBilan.id,
            operationType: SyncOperationType.create,
            data: any(named: 'data'),
          )).called(1);
      verify(() => mockEventBus.emit(any())).called(1);
    });

    test('update doit persister localement et emettre un event', () async {
      when(() => mockDatasource.update(testBilan))
          .thenAnswer((_) async => testBilan);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});
      when(() => mockEventBus.emit(any())).thenReturn(null);
      when(() => mockRegistry.markInvalidated<BilanMedicalMensuelUpdatedEvent>())
          .thenReturn(null);

      final result = await repository.update(testBilan);

      expect(result, testBilan);
      verify(() => mockDatasource.update(testBilan)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.bilanMedicalMensuel,
            entityId: testBilan.id,
            operationType: SyncOperationType.update,
            data: any(named: 'data'),
          )).called(1);
    });

    test('delete doit supprimer localement et emettre un event', () async {
      when(() => mockDatasource.getById('bm-1'))
          .thenAnswer((_) async => testBilan);
      when(() => mockDatasource.delete('bm-1')).thenAnswer((_) async {});
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});
      when(() => mockEventBus.emit(any())).thenReturn(null);
      when(() => mockRegistry.markInvalidated<BilanMedicalMensuelDeletedEvent>())
          .thenReturn(null);

      await repository.delete('bm-1');

      verify(() => mockDatasource.delete('bm-1')).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.bilanMedicalMensuel,
            entityId: 'bm-1',
            operationType: SyncOperationType.delete,
            data: {'id': 'bm-1'},
          )).called(1);
    });

    test('syncFromApi doit fusionner les donnees distantes', () async {
      final remoteData = [testBilan.toJson()];
      when(() => mockDioClient.get<dynamic>(ApiEndpoints.bilansMedicaux('acad-1')))
          .thenAnswer((_) async => Right(remoteData));
      when(() => mockDatasource.getAll()).thenAnswer((_) async => []);
      when(() => mockDatasource.saveAll(any())).thenAnswer((_) async {});

      final result = await repository.syncFromApi('acad-1');

      expect(result, isTrue);
      verify(() => mockDatasource.saveAll(any())).called(1);
    });

    test('syncFromApi doit retourner false si dioClient est null', () async {
      final offlineRepo = BilanMedicalMensuelRepositoryImpl(mockDatasource);

      final result = await offlineRepo.syncFromApi('acad-1');

      expect(result, isFalse);
    });

    test('clearCache doit vider les caches memoire', () {
      expect(() => repository.clearCache(), returnsNormally);
    });
  });
}
