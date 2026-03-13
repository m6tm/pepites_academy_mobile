import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/exercice_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/atelier_repository.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/exercice_repository.dart';

class MockAtelierRepository extends Mock implements AtelierRepository {}
class MockExerciceRepository extends Mock implements ExerciceRepository {}

void main() {
  late ExerciceService service;
  late MockAtelierRepository mockAtelierRepo;
  late MockExerciceRepository mockExerciceRepo;

  setUp(() {
    mockAtelierRepo = MockAtelierRepository();
    mockExerciceRepo = MockExerciceRepository();
    service = ExerciceService(
      exerciceRepository: mockExerciceRepo,
      atelierRepository: mockAtelierRepo,
    );

    registerFallbackValue(Exercice(
      id: '',
      nom: '',
      description: '',
      ordre: 0,
      statut: ExerciceStatut.cree,
      atelierId: '',
    ));
  });

  group('ExerciceService', () {
    const atelierId = 'atelier-1';

    test('getExercicesParAtelier doit retourner les exercices tries', () async {
      final exercices = [
        Exercice(id: '1', nom: 'A', description: '', ordre: 2, statut: ExerciceStatut.cree, atelierId: atelierId),
        Exercice(id: '2', nom: 'B', description: '', ordre: 1, statut: ExerciceStatut.cree, atelierId: atelierId),
      ];
      
      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => exercices);

      final result = await service.getExercicesParAtelier(atelierId);

      expect(result.first.id, '2');
      verify(() => mockExerciceRepo.getByAtelierId(atelierId)).called(1);
    });

    test('ajouterExercice doit creer un exercice', () async {
      final atelier = Atelier(id: atelierId, nom: 'At1', description: '', type: AtelierType.dribble, ordre: 0, statut: AtelierStatut.cree, seanceId: 'S1');
      
      when(() => mockAtelierRepo.getById(atelierId)).thenAnswer((_) async => atelier);
      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => []);
      when(() => mockExerciceRepo.create(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Exercice);

      final result = await service.ajouterExercice(
        atelierId: atelierId,
        nom: 'Nouveau',
      );

      expect(result.nom, 'Nouveau');
      verify(() => mockExerciceRepo.create(any())).called(1);
    });
    
    test('reorderExercices doit appeler le repository', () async {
      final ids = ['3', '1'];
      when(() => mockExerciceRepo.reorder(atelierId, ids)).thenAnswer((_) async {});
      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => []);

      await service.reorderExercices(atelierId, ids);

      verify(() => mockExerciceRepo.reorder(atelierId, ids)).called(1);
    });

    test('exercicesStream doit emettre les nouveaux exercices apres recuperation', () async {
      final exercices = [
        Exercice(id: '1', nom: 'A', description: '', ordre: 1, statut: ExerciceStatut.cree, atelierId: atelierId),
      ];
      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => exercices);

      expect(service.exercicesStream, emits(exercices));

      await service.getExercicesParAtelier(atelierId);
    });

    test('modifierExercice doit mettre a jour et rafraichir', () async {
      final exercice = Exercice(id: '1', nom: 'Old', description: '', ordre: 1, statut: ExerciceStatut.cree, atelierId: atelierId);
      final updatedExercice = exercice.copyWith(nom: 'New');

      when(() => mockExerciceRepo.update(any())).thenAnswer((_) async => updatedExercice);
      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => [updatedExercice]);

      final result = await service.modifierExercice(updatedExercice);

      expect(result.nom, 'New');
      verify(() => mockExerciceRepo.update(any())).called(1);
      verify(() => mockExerciceRepo.getByAtelierId(atelierId)).called(1);
    });

    test('supprimerExercice doit supprimer et reordonner', () async {
      final exercice = Exercice(id: '1', nom: 'A', description: '', ordre: 1, statut: ExerciceStatut.cree, atelierId: atelierId);

      when(() => mockExerciceRepo.getById('1')).thenAnswer((_) async => exercice);
      when(() => mockExerciceRepo.delete('1')).thenAnswer((_) async => {});
      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => []);

      await service.supprimerExercice('1');

      verify(() => mockExerciceRepo.delete('1')).called(1);
    });

    test('refreshExercices doit appeler le repository', () async {
      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => []);

      await service.refreshExercices(atelierId);

      verify(() => mockExerciceRepo.getByAtelierId(atelierId)).called(1);
    });

  });
}
