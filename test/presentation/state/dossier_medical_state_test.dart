import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/core/events/app_events.dart';
import 'package:pepites_academy_mobile/src/core/events/dossier_medical_events.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event_bus.dart';
import 'package:pepites_academy_mobile/src/core/events/invalidation_registry.dart';
import 'package:pepites_academy_mobile/src/domain/entities/dossier_medical.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/dossier_medical_repository_impl.dart';
import 'package:pepites_academy_mobile/src/presentation/state/dossier_medical_state.dart';

class MockDossierMedicalRepositoryImpl extends Mock
    implements DossierMedicalRepositoryImpl {}

class MockDomainEventBus extends Mock implements DomainEventBus {}

class MockInvalidationRegistry extends Mock implements InvalidationRegistry {}

void main() {
  late DossierMedicalState state;
  late MockDossierMedicalRepositoryImpl mockRepository;
  late MockDomainEventBus mockEventBus;
  late MockInvalidationRegistry mockRegistry;

  final testDossier = DossierMedical(
    id: 'dm-1',
    academicienId: 'acad-1',
    dateBlessure: DateTime(2026, 6, 1),
    lieu: 'entrainement',
    statutReprise: 'en_cours',
    createdAt: DateTime(2026, 6, 1),
  );

  setUp(() {
    mockRepository = MockDossierMedicalRepositoryImpl();
    mockEventBus = MockDomainEventBus();
    mockRegistry = MockInvalidationRegistry();

    // Stubber les streams du bus d'evenements pour eviter les Null
    when(() => mockEventBus.on<DossierMedicalCreatedEvent>())
        .thenAnswer((_) => const Stream<DossierMedicalCreatedEvent>.empty());
    when(() => mockEventBus.on<DossierMedicalUpdatedEvent>())
        .thenAnswer((_) => const Stream<DossierMedicalUpdatedEvent>.empty());
    when(() => mockEventBus.on<DossierMedicalDeletedEvent>())
        .thenAnswer((_) => const Stream<DossierMedicalDeletedEvent>.empty());
    when(() => mockEventBus.on<AppResumedEvent>())
        .thenAnswer((_) => const Stream<AppResumedEvent>.empty());

    state = DossierMedicalState(mockRepository, mockEventBus, mockRegistry);
  });

  tearDown(() {
    state.dispose();
  });

  group('DossierMedicalState', () {
    test('doit charger les dossiers avec loadDossiers', () async {
      when(() => mockRepository.getByAcademicienId('acad-1'))
          .thenAnswer((_) async => [testDossier]);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalCreatedEvent>(
            any(),
          )).thenReturn(false);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalUpdatedEvent>(
            any(),
          )).thenReturn(false);

      await state.loadDossiers('acad-1');

      expect(state.dossiers, [testDossier]);
      expect(state.isLoading, isFalse);
      expect(state.isEmpty, isFalse);
    });

    test('doit refleter un etat vide', () async {
      when(() => mockRepository.getByAcademicienId('acad-1'))
          .thenAnswer((_) async => []);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalCreatedEvent>(
            any(),
          )).thenReturn(false);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalUpdatedEvent>(
            any(),
          )).thenReturn(false);

      await state.loadDossiers('acad-1');

      expect(state.dossiers, isEmpty);
      expect(state.isEmpty, isTrue);
    });

    test('doit gerer une erreur de chargement', () async {
      when(() => mockRepository.getByAcademicienId('acad-1'))
          .thenThrow(Exception('Erreur reseau'));
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalCreatedEvent>(
            any(),
          )).thenReturn(false);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalUpdatedEvent>(
            any(),
          )).thenReturn(false);

      await state.loadDossiers('acad-1');

      expect(state.hasError, isTrue);
      expect(state.isLoading, isFalse);
    });

    test('refresh ne doit pas re-fetch si les donnees sont recentes', () async {
      when(() => mockRepository.getByAcademicienId('acad-1'))
          .thenAnswer((_) async => [testDossier]);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalCreatedEvent>(
            any(),
          )).thenReturn(false);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalUpdatedEvent>(
            any(),
          )).thenReturn(false);

      await state.loadDossiers('acad-1');
      // Refresh immediat ne doit pas declencher un nouveau fetch
      await state.refresh('acad-1');

      verify(() => mockRepository.getByAcademicienId('acad-1')).called(1);
    });

    test('syncFromApi doit recharger les donnees en cas de succes', () async {
      when(() => mockRepository.syncFromApi('acad-1'))
          .thenAnswer((_) async => true);
      when(() => mockRepository.getByAcademicienId('acad-1'))
          .thenAnswer((_) async => [testDossier]);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalCreatedEvent>(
            any(),
          )).thenReturn(false);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalUpdatedEvent>(
            any(),
          )).thenReturn(false);

      final result = await state.syncFromApi('acad-1');

      expect(result, isTrue);
      expect(state.dossiers, [testDossier]);
    });

    test('syncFromApi doit retourner false en cas d echec', () async {
      when(() => mockRepository.syncFromApi('acad-1'))
          .thenThrow(Exception('Sync error'));

      final result = await state.syncFromApi('acad-1');

      expect(result, isFalse);
      expect(state.hasError, isTrue);
    });

    test('doit rafraichir automatiquement sur DossierMedicalCreatedEvent',
        () async {
      when(() => mockRepository.getByAcademicienId('acad-1'))
          .thenAnswer((_) async => [testDossier]);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalCreatedEvent>(
            any(),
          )).thenReturn(false);
      when(() => mockRegistry.wasInvalidatedAfter<DossierMedicalUpdatedEvent>(
            any(),
          )).thenReturn(false);

      await state.loadDossiers('acad-1');

      // Verifier que l'abonnement au bus a ete effectue
      verify(() => mockEventBus.on<DossierMedicalCreatedEvent>()).called(1);
      expect(state.dossiers, [testDossier]);
    });
  });
}
