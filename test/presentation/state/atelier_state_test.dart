import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/atelier_service.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event_bus.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/presentation/state/atelier_state.dart';

class MockAtelierService extends Mock implements AtelierService {}

void main() {
  late AtelierState state;
  late MockAtelierService mockService;
  late DomainEventBus eventBus;

  const seanceId = 'seance-1';
  const atelierId = 'atelier-1';

  final atelier = Atelier(
    id: atelierId,
    nom: 'Atelier test',
    ordre: 0,
    statut: AtelierStatut.cree,
    seanceId: seanceId,
  );

  setUp(() {
    mockService = MockAtelierService();
    eventBus = DomainEventBus();
    state = AtelierState(mockService, eventBus);
  });

  group('AtelierState - supprimerAtelier', () {
    test('doit retirer l atelier de la liste apres suppression reussie', () async {
      // Arrange
      state.ateliers.add(atelier);
      when(() => mockService.supprimerAtelier(atelierId))
          .thenAnswer((_) async {});

      // Act
      final result = await state.supprimerAtelier(atelierId);

      // Assert
      expect(result, isTrue);
      expect(state.ateliers, isEmpty);
      expect(state.successMessage, isNotNull);
      expect(state.isLoading, isFalse);
    });

    test('doit garder l atelier en cas d erreur', () async {
      // Arrange
      state.ateliers.add(atelier);
      when(() => mockService.supprimerAtelier(atelierId))
          .thenThrow(Exception('Erreur'));

      // Act
      final result = await state.supprimerAtelier(atelierId);

      // Assert
      expect(result, isFalse);
      expect(state.ateliers.length, 1);
      expect(state.errorMessage, isNotNull);
      expect(state.isLoading, isFalse);
    });
  });
}
