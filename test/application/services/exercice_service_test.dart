import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/exercice_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/atelier_repository.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/exercice_repository.dart';

class MockExerciceRepository extends Mock implements ExerciceRepository {}
class MockAtelierRepository extends Mock implements AtelierRepository {}

void main() {
  late ExerciceService service;
  late MockExerciceRepository mockExerciceRepo;
  late MockAtelierRepository mockAtelierRepo;

  const tExercice = Exercice(
    id: '1',
    nom: 'Passement',
    description: 'Desc',
    ordre: 0,
    statut: ExerciceStatut.cree,
    atelierId: '10',
  );

  const tAtelier = Atelier(
    id: '10',
    nom: 'Dribble',
    description: 'Desc',
    type: AtelierType.dribble,
    ordre: 0,
    statut: AtelierStatut.valide,
    seanceId: '42',
  );

  setUp(() {
    mockExerciceRepo = MockExerciceRepository();
    mockAtelierRepo = MockAtelierRepository();
    service = ExerciceService(
      exerciceRepository: mockExerciceRepo,
      atelierRepository: mockAtelierRepo,
    );

    registerFallbackValue(tExercice);
    registerFallbackValue(tAtelier);
    registerFallbackValue(ExerciceStatut.cree);
  });

  group('getExercicesParAtelier', () {
    test('should return sorted exercices', () async {
      final exercices = [
        tExercice.copyWith(id: '2', ordre: 1),
        tExercice.copyWith(id: '1', ordre: 0),
      ];
      when(() => mockExerciceRepo.getByAtelierId(any())).thenAnswer((_) async => exercices);

      final result = await service.getExercicesParAtelier('10');

      expect(result.first.id, '1');
      expect(result.last.id, '2');
    });
  });

  group('fermerExercice', () {
    test('should throw exception if not applied', () async {
      when(() => mockExerciceRepo.getById(any())).thenAnswer((_) async => tExercice);

      expect(
        () => service.fermerExercice('1'),
        throwsException,
      );
    });

    test('should call close on repository if applied', () async {
      final appliedExercice = tExercice.copyWith(statut: ExerciceStatut.applique);
      when(() => mockExerciceRepo.getById(any())).thenAnswer((_) async => appliedExercice);
      when(() => mockExerciceRepo.close(any())).thenAnswer((_) async => true);
      when(() => mockExerciceRepo.getByAtelierId(any())).thenAnswer((_) async => [appliedExercice]);

      final result = await service.fermerExercice('1');

      expect(result, true);
      verify(() => mockExerciceRepo.close('1')).called(1);
    });
  });
}
