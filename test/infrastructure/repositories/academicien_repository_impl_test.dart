import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/core/events/academicien_events.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event_bus.dart';
import 'package:pepites_academy_mobile/src/core/events/invalidation_registry.dart';
import 'package:pepites_academy_mobile/src/domain/entities/academicien.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/academicien_local_datasource.dart';
import 'package:pepites_academy_mobile/src/infrastructure/network/dio_client.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/academicien_repository_impl.dart';

class MockAcademicienLocalDatasource extends Mock
    implements AcademicienLocalDatasource {}

class MockDioClient extends Mock implements DioClient {}

class MockSyncService extends Mock implements SyncService {}

class MockDomainEventBus extends Mock implements DomainEventBus {}

class MockInvalidationRegistry extends Mock implements InvalidationRegistry {}

class FakeDomainEvent extends Fake implements DomainEvent {}

void main() {
  late AcademicienRepositoryImpl repository;
  late MockAcademicienLocalDatasource mockDatasource;
  late MockDioClient mockDioClient;
  late MockSyncService mockSyncService;
  late MockDomainEventBus mockEventBus;
  late MockInvalidationRegistry mockRegistry;

  final localId = '1740000000000';
  final serverId = '550e8400-e29b-41d4-a716-446655440000';

  final localAcademicien = Academicien(
    id: localId,
    nom: 'Doe',
    prenom: 'John',
    dateNaissance: DateTime(2010, 5, 15),
    lieuNaissance: 'Paris',
    nationalite: 'Française',
    sexe: 'M',
    photoUrl: '',
    telephoneEleve: '0600000000',
    taille: 150,
    email: 'john@example.com',
    whatsapp: '0600000000',
    posteFootballId: '1',
    niveauScolaireId: '2',
    codeQrUnique: 'PA-ACA-12345678-0000',
    nomParent: 'Doe',
    prenomParent: 'Jane',
    fonctionParent: 'Mère',
    telephoneParent: '0611111111',
  );

  final remoteAcademicien = Academicien(
    id: serverId,
    nom: 'Doe',
    prenom: 'John',
    dateNaissance: DateTime(2010, 5, 15),
    lieuNaissance: 'Paris',
    nationalite: 'Française',
    sexe: 'M',
    photoUrl: 'https://example.com/photo.jpg',
    telephoneEleve: '0600000000',
    taille: 150,
    email: 'john@example.com',
    whatsapp: '0600000000',
    posteFootballId: '1',
    niveauScolaireId: '2',
    codeQrUnique: 'PA-ACA-12345678-0000',
    nomParent: 'Doe',
    prenomParent: 'Jane',
    fonctionParent: 'Mère',
    telephoneParent: '0611111111',
  );

  setUp(() {
    mockDatasource = MockAcademicienLocalDatasource();
    mockDioClient = MockDioClient();
    mockSyncService = MockSyncService();
    mockEventBus = MockDomainEventBus();
    mockRegistry = MockInvalidationRegistry();

    repository = AcademicienRepositoryImpl(mockDatasource);
    repository.setDioClient(mockDioClient);
    repository.setSyncService(mockSyncService);
    repository.setEventBus(mockEventBus);
    repository.setInvalidationRegistry(mockRegistry);

    registerFallbackValue(FakeDomainEvent());
    registerFallbackValue(localAcademicien);
  });

  group('AcademicienRepositoryImpl', () {
    test(
        'upsertAllFromRemote remplace l\'ID local par l\'UUID serveur sans doublon',
        () async {
      List<Academicien>? savedList;

      when(() => mockDatasource.getAll())
          .thenAnswer((_) async => [localAcademicien]);
      when(() => mockDatasource.saveAll(any())).thenAnswer((invocation) async {
        savedList = invocation.positionalArguments[0] as List<Academicien>;
      });

      await repository.upsertAllFromRemote([remoteAcademicien]);

      expect(savedList, isNotNull);
      expect(savedList!.length, 1);
      expect(savedList!.first.id, serverId);
      expect(savedList!.first.photoUrl, 'https://example.com/photo.jpg');
    });

    test(
        'migrateLocalId supprime l\'ancien ID local si l\'UUID serveur existe deja',
        () async {
      when(() => mockDatasource.getById(localId))
          .thenAnswer((_) async => localAcademicien);
      when(() => mockDatasource.getById(serverId))
          .thenAnswer((_) async => remoteAcademicien);
      when(() => mockDatasource.delete(localId))
          .thenAnswer((_) async {});
      when(() => mockEventBus.emit(any())).thenReturn(null);

      await repository.migrateLocalId(localId, serverId);

      verify(() => mockDatasource.getById(localId)).called(1);
      verify(() => mockDatasource.getById(serverId)).called(1);
      verifyNever(() => mockDatasource.create(any()));
      verify(() => mockDatasource.delete(localId)).called(1);
      verify(() => mockEventBus.emit(any())).called(1);
    });
  });
}
