import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/exercice_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/atelier_repository.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/exercice_repository.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/seance_repository.dart';
import 'package:pepites_academy_mobile/src/presentation/state/exercice_state.dart';

class MockAtelierRepository extends Mock implements AtelierRepository {}
class MockExerciceRepository extends Mock implements ExerciceRepository {}
class MockSeanceRepository extends Mock implements SeanceRepository {}

void main() {
  late ExerciceState state;
  late ExerciceService service;
  late MockExerciceRepository mockExerciceRepo;
  late MockAtelierRepository mockAtelierRepo;
  late MockSeanceRepository mockSeanceRepo;

  const atelierId = 'atelier-1';
  const exerciceId = 'ex-1';
  const exerciceNom = 'Passe au mur';

  final exerciceApplique = Exercice(
    id: exerciceId,
    nom: exerciceNom,
    description: 'Desc',
    ordre: 0,
    statut: ExerciceStatut.applique,
    atelierId: atelierId,
  );

  setUp(() {
    mockExerciceRepo = MockExerciceRepository();
    mockAtelierRepo = MockAtelierRepository();
    mockSeanceRepo = MockSeanceRepository();
    service = ExerciceService(
      exerciceRepository: mockExerciceRepo,
      atelierRepository: mockAtelierRepo,
      seanceRepository: mockSeanceRepo,
    );
    state = ExerciceState(service);

    registerFallbackValue(Exercice(
      id: '',
      nom: '',
      description: '',
      ordre: 0,
      statut: ExerciceStatut.cree,
      atelierId: '',
    ));
  });

  group('ExerciceState - fermerExercice', () {
    test('doit retourner false et afficher un succes si atelier non ferme', () async {
      // Arrange
      when(() => mockExerciceRepo.getById(exerciceId))
          .thenAnswer((_) async => exerciceApplique);
      when(() => mockExerciceRepo.close(exerciceId))
          .thenAnswer((_) async => false);
      when(() => mockExerciceRepo.getByAtelierId(atelierId))
          .thenAnswer((_) async => []);

      // Act
      final result = await state.fermerExercice(exerciceId, atelierId, exerciceNom);

      // Assert
      expect(result, false);
      expect(state.successMessage, isNotNull);
      expect(state.successMessage, contains(exerciceNom));
      expect(state.errorMessage, isNull);
    });

    test('doit retourner true et afficher un succes avec mention atelier si atelier ferme', () async {
      // Arrange
      when(() => mockExerciceRepo.getById(exerciceId))
          .thenAnswer((_) async => exerciceApplique);
      when(() => mockExerciceRepo.close(exerciceId))
          .thenAnswer((_) async => true);
      when(() => mockExerciceRepo.getByAtelierId(atelierId))
          .thenAnswer((_) async => []);

      // Act
      final result = await state.fermerExercice(exerciceId, atelierId, exerciceNom);

      // Assert
      expect(result, true);
      expect(state.successMessage, isNotNull);
      // Le message doit inclure la notification de fermeture de l'atelier
      expect(state.successMessage, contains(exerciceNom));
      expect(state.successMessage, contains('atelier'));
      expect(state.errorMessage, isNull);
    });

    test('doit afficher un message d erreur si le service leve une exception', () async {
      // Arrange : exercice introuvable dans le service
      when(() => mockExerciceRepo.getById(exerciceId))
          .thenAnswer((_) async => null);

      // Act
      final result = await state.fermerExercice(exerciceId, atelierId, exerciceNom);

      // Assert
      expect(result, false);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('Erreur'));
      expect(state.successMessage, isNull);
    });

    test('doit gerer le loading state correctement', () async {
      // Arrange
      when(() => mockExerciceRepo.getById(exerciceId))
          .thenAnswer((_) async => exerciceApplique);
      when(() => mockExerciceRepo.close(exerciceId))
          .thenAnswer((_) async => false);
      when(() => mockExerciceRepo.getByAtelierId(atelierId))
          .thenAnswer((_) async => []);

      // Verifier que le loading state est mis a true au debut
      bool loadingDuringExecution = false;
      state.addListener(() {
        if (state.isLoading(atelierId)) {
          loadingDuringExecution = true;
        }
      });

      // Act
      await state.fermerExercice(exerciceId, atelierId, exerciceNom);

      // Assert
      expect(loadingDuringExecution, isTrue);
      // Apres l'execution, le loading doit etre false
      expect(state.isLoading(atelierId), isFalse);
    });

    test('doit mettre le loading a false meme en cas d erreur', () async {
      // Arrange
      when(() => mockExerciceRepo.getById(exerciceId))
          .thenAnswer((_) async => null);

      // Act
      await state.fermerExercice(exerciceId, atelierId, exerciceNom);

      // Assert
      expect(state.isLoading(atelierId), isFalse);
    });

    test('doit recharger les exercices apres fermeture reussie', () async {
      // Arrange
      final exerciceFerme = exerciceApplique.copyWith(statut: ExerciceStatut.ferme);
      when(() => mockExerciceRepo.getById(exerciceId))
          .thenAnswer((_) async => exerciceApplique);
      when(() => mockExerciceRepo.close(exerciceId))
          .thenAnswer((_) async => false);
      when(() => mockExerciceRepo.getByAtelierId(atelierId))
          .thenAnswer((_) async => [exerciceFerme]);

      // Act
      await state.fermerExercice(exerciceId, atelierId, exerciceNom);

      // Assert
      expect(state.exercicesParAtelier[atelierId], isNotNull);
      expect(state.exercicesParAtelier[atelierId]!.length, 1);
      expect(state.exercicesParAtelier[atelierId]!.first.statut, ExerciceStatut.ferme);
    });

    test('doit notifier les listeners lors de la fermeture', () async {
      // Arrange
      when(() => mockExerciceRepo.getById(exerciceId))
          .thenAnswer((_) async => exerciceApplique);
      when(() => mockExerciceRepo.close(exerciceId))
          .thenAnswer((_) async => false);
      when(() => mockExerciceRepo.getByAtelierId(atelierId))
          .thenAnswer((_) async => []);

      int notificationCount = 0;
      state.addListener(() {
        notificationCount++;
      });

      // Act
      await state.fermerExercice(exerciceId, atelierId, exerciceNom);

      // Assert - doit notifier au moins 2 fois (debut loading + fin)
      expect(notificationCount, greaterThanOrEqualTo(2));
    });
  });

  group('ExerciceState - clearMessages', () {
    test('doit effacer les messages et notifier', () async {
      // Arrange : creer un etat avec un message d'erreur
      when(() => mockExerciceRepo.getById(exerciceId))
          .thenAnswer((_) async => null);
      await state.fermerExercice(exerciceId, atelierId, exerciceNom);
      expect(state.errorMessage, isNotNull);

      // Act
      state.clearMessages();

      // Assert
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
    });
  });
}
