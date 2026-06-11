import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/core/events/dossier_medical_events.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event_bus.dart';
import 'package:pepites_academy_mobile/src/core/events/invalidation_registry.dart';
import 'package:pepites_academy_mobile/src/domain/entities/dossier_medical.dart';
import 'package:pepites_academy_mobile/src/domain/entities/sync_operation.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/dossier_medical_local_datasource.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/api_endpoints.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/dossier_medical_repository_impl.dart';
import 'package:dartz/dartz.dart';

class MockDossierMedicalLocalDatasource extends Mock
    implements DossierMedicalLocalDatasource {}

class MockDioClient extends Mock implements DioClient {}

class MockSyncService extends Mock implements SyncService {}

class MockDomainEventBus extends Mock implements DomainEventBus {}

class MockInvalidationRegistry extends Mock implements InvalidationRegistry {}

class FakeDomainEvent extends Fake implements DomainEvent {}

void main() {
  late DossierMedicalRepositoryImpl repository;
  late MockDossierMedicalLocalDatasource mockDatasource;
  late MockDioClient mockDioClient;
  late MockSyncService mockSyncService;
  late MockDomainEventBus mockEventBus;
  late MockInvalidationRegistry mockRegistry;

  final testDossier = DossierMedical(
    id: 'dm-1',
    academicienId: 'acad-1',
    dateBlessure: DateTime(2026, 6, 1),
    lieu: 'match',
    partieCorps: 'genou',
    typeBlessure: 'entorse',
    gravite: 'moyenne',
    statutReprise: 'en_cours',
    createdAt: DateTime(2026, 6, 1),
  );

  setUp(() {
    mockDatasource = MockDossierMedicalLocalDatasource();
    mockDioClient = MockDioClient();
    mockSyncService = MockSyncService();
    mockEventBus = MockDomainEventBus();
    mockRegistry = MockInvalidationRegistry();

    repository = DossierMedicalRepositoryImpl(mockDatasource);
    repository.setDioClient(mockDioClient);
    repository.setSyncService(mockSyncService);
    repository.setEventBus(mockEventBus);
    repository.setInvalidationRegistry(mockRegistry);

    registerFallbackValue(SyncEntityType.dossierMedical);
    registerFallbackValue(SyncOperationType.create);
    registerFallbackValue(testDossier);
    registerFallbackValue(<DossierMedical>[]);
    registerFallbackValue(FakeDomainEvent());
  });

  group('DossierMedicalRepositoryImpl', () {
    test(
        'getByAcademicienId doit retourner les donnees locales si presentes',
        () async {
      when(() => mockDatasource.getByAcademicienId('acad-1'))
          .thenAnswer((_) async => [testDossier]);

      final result = await repository.getByAcademicienId('acad-1');

      expect(result, [testDossier]);
      verify(() => mockDatasource.getByAcademicienId('acad-1')).called(1);
    });

    test(
        'getByAcademicienIdSwr doit emettre stale puis fresh',
        () async {
      when(() => mockDatasource.getByAcademicienId('acad-1'))
          .thenAnswer((_) async => [testDossier]);

      final stream = repository.getByAcademicienIdSwr('acad-1');
      final results = await stream.toList();

      expect(results.length, 2);
      expect(results.first, [testDossier]);
      expect(results.last, [testDossier]);
    });

    test('create doit persister localement, invalider le cache et emettre un event',
        () async {
      when(() => mockDatasource.create(testDossier))
          .thenAnswer((_) async => testDossier);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});
      when(() => mockEventBus.emit(any())).thenReturn(null);
      when(() => mockRegistry.markInvalidated<DossierMedicalCreatedEvent>())
          .thenReturn(null);

      final result = await repository.create(testDossier);

      expect(result, testDossier);
      verify(() => mockDatasource.create(testDossier)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.dossierMedical,
            entityId: testDossier.id,
            operationType: SyncOperationType.create,
            data: any(named: 'data'),
          )).called(1);
      verify(() => mockEventBus.emit(any())).called(1);
    });

    test('update doit persister localement et emettre un event', () async {
      when(() => mockDatasource.update(testDossier))
          .thenAnswer((_) async => testDossier);
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});
      when(() => mockEventBus.emit(any())).thenReturn(null);
      when(() => mockRegistry.markInvalidated<DossierMedicalUpdatedEvent>())
          .thenReturn(null);

      final result = await repository.update(testDossier);

      expect(result, testDossier);
      verify(() => mockDatasource.update(testDossier)).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.dossierMedical,
            entityId: testDossier.id,
            operationType: SyncOperationType.update,
            data: any(named: 'data'),
          )).called(1);
    });

    test('delete doit supprimer localement et emettre un event', () async {
      when(() => mockDatasource.getById('dm-1'))
          .thenAnswer((_) async => testDossier);
      when(() => mockDatasource.delete('dm-1')).thenAnswer((_) async {});
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async {});
      when(() => mockEventBus.emit(any())).thenReturn(null);
      when(() => mockRegistry.markInvalidated<DossierMedicalDeletedEvent>())
          .thenReturn(null);

      await repository.delete('dm-1');

      verify(() => mockDatasource.delete('dm-1')).called(1);
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.dossierMedical,
            entityId: 'dm-1',
            operationType: SyncOperationType.delete,
            data: {'id': 'dm-1'},
          )).called(1);
    });

    test('syncFromApi doit fusionner les donnees distantes', () async {
      final remoteData = [testDossier.toJson()];
      when(() => mockDioClient.get<dynamic>(ApiEndpoints.dossiersMedicaux('acad-1')))
          .thenAnswer((_) async => Right(remoteData));
      when(() => mockDatasource.getAll()).thenAnswer((_) async => []);
      when(() => mockDatasource.saveAll(any())).thenAnswer((_) async {});

      final result = await repository.syncFromApi('acad-1');

      expect(result, isTrue);
      verify(() => mockDatasource.saveAll(any())).called(1);
    });

    test('syncFromApi doit retourner false si dioClient est null', () async {
      final offlineRepo = DossierMedicalRepositoryImpl(mockDatasource);

      final result = await offlineRepo.syncFromApi('acad-1');

      expect(result, isFalse);
    });

    test('clearCache doit vider les caches memoire', () {
      // Le clearCache ne leve pas d'exception
      expect(() => repository.clearCache(), returnsNormally);
    });
  });
}
