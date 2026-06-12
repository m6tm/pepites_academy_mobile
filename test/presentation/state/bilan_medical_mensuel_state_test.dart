import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/core/events/bilan_medical_mensuel_events.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event_bus.dart';
import 'package:pepites_academy_mobile/src/core/events/invalidation_registry.dart';
import 'package:pepites_academy_mobile/src/domain/entities/bilan_medical_mensuel.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/bilan_medical_mensuel_repository.dart';
import 'package:pepites_academy_mobile/src/presentation/state/bilan_medical_mensuel_state.dart';

class MockBilanMedicalMensuelRepository extends Mock
    implements BilanMedicalMensuelRepository {}

class MockInvalidationRegistry extends Mock implements InvalidationRegistry {}

void main() {
  late BilanMedicalMensuelState state;
  late MockBilanMedicalMensuelRepository mockRepository;
  late MockInvalidationRegistry mockRegistry;
  late DomainEventBus eventBus;

  const academicienId = 'acad-1';

  final testBilan = BilanMedicalMensuel(
    id: 'bm-1',
    academicienId: academicienId,
    medecinId: 'med-1',
    mois: 5,
    annee: 2026,
    blessuresMusculaire: 2,
    blessuresArticulaire: 1,
    blessuresTraumatique: 0,
    createdAt: DateTime(2026, 5, 1),
  );

  setUp(() {
    mockRepository = MockBilanMedicalMensuelRepository();
    mockRegistry = MockInvalidationRegistry();
    eventBus = DomainEventBus();
    state = BilanMedicalMensuelState(mockRepository, eventBus, mockRegistry);

    registerFallbackValue(testBilan);
    registerFallbackValue(<BilanMedicalMensuel>[]);
  });

  group('BilanMedicalMensuelState', () {
    test('loadBilans doit charger les bilans et notifier', () async {
      when(() => mockRepository.getByAcademicienId(academicienId))
          .thenAnswer((_) async => [testBilan]);

      int notificationCount = 0;
      state.addListener(() => notificationCount++);

      await state.loadBilans(academicienId);

      expect(state.bilans, [testBilan]);
      expect(state.isLoading, isFalse);
      expect(state.isEmpty, isFalse);
      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    test('loadBilans doit gerer les erreurs', () async {
      when(() => mockRepository.getByAcademicienId(academicienId))
          .thenThrow(Exception('network error'));

      await state.loadBilans(academicienId);

      expect(state.hasError, isTrue);
      expect(state.error, isNotNull);
      expect(state.isLoading, isFalse);
    });

    test('refresh ne recharge pas si les donnees sont recentes', () async {
      when(() => mockRepository.getByAcademicienId(academicienId))
          .thenAnswer((_) async => [testBilan]);

      await state.loadBilans(academicienId);
      verify(() => mockRepository.getByAcademicienId(academicienId)).called(1);

      await state.refresh(academicienId);
      verifyNever(() => mockRepository.getByAcademicienId(academicienId));
    });

    test('syncFromApi doit recharger les bilans apres succes', () async {
      when(() => mockRepository.syncFromApi(academicienId))
          .thenAnswer((_) async => true);
      when(() => mockRepository.getByAcademicienId(academicienId))
          .thenAnswer((_) async => [testBilan]);

      final result = await state.syncFromApi(academicienId);

      expect(result, isTrue);
      expect(state.bilans, [testBilan]);
    });

    test('syncFromApi doit retourner false en cas d erreur', () async {
      when(() => mockRepository.syncFromApi(academicienId))
          .thenThrow(Exception('sync error'));

      final result = await state.syncFromApi(academicienId);

      expect(result, isFalse);
      expect(state.hasError, isTrue);
    });

    test('doit reagir aux evenements de creation', () async {
      when(() => mockRepository.getByAcademicienId(academicienId))
          .thenAnswer((_) async => [testBilan]);

      await state.loadBilans(academicienId);
      when(() => mockRepository.getByAcademicienId(academicienId))
          .thenAnswer((_) async => [testBilan]);

      eventBus.emit(BilanMedicalMensuelCreatedEvent('bm-2', academicienId));

      await Future<void>.delayed(Duration.zero);

      expect(state.bilans, [testBilan]);
    });
  });
}
