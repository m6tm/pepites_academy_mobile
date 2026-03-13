import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/atelier_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/domain/entities/seance.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/atelier_repository.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/seance_repository.dart';
import 'package:pepites_academy_mobile/src/domain/repositories/exercice_repository.dart';

class MockAtelierRepository extends Mock implements AtelierRepository {}
class MockSeanceRepository extends Mock implements SeanceRepository {}
class MockExerciceRepository extends Mock implements ExerciceRepository {}

void main() {
  late AtelierService service;
  late MockAtelierRepository mockAtelierRepo;
  late MockSeanceRepository mockSeanceRepo;
  late MockExerciceRepository mockExerciceRepo;

  setUp(() {
    mockAtelierRepo = MockAtelierRepository();
    mockSeanceRepo = MockSeanceRepository();
    mockExerciceRepo = MockExerciceRepository();
    service = AtelierService(
      atelierRepository: mockAtelierRepo,
      seanceRepository: mockSeanceRepo,
      exerciceRepository: mockExerciceRepo,
    );
    
    // Fallback for mocktail any()
    registerFallbackValue(Atelier(
      id: '',
      nom: '',
      description: '',
      type: AtelierType.dribble,
      ordre: 0,
      statut: AtelierStatut.cree,
      seanceId: '',
    ));
    registerFallbackValue(Seance(
      id: '',
      titre: '',
      date: DateTime.now(),
      heureDebut: DateTime.now(),
      heureFin: DateTime.now(),
      statut: SeanceStatus.ouverte,
      encadreurResponsableId: '',
    ));
  });

  group('AtelierService', () {
    const seanceId = 'seance-1';
    const atelierId = 'atelier-1';

    test('getAteliersParSeance doit retourner les ateliers tries par ordre', () async {
      final ateliers = [
        Atelier(id: '1', nom: 'A', description: '', type: AtelierType.physique, ordre: 2, statut: AtelierStatut.cree, seanceId: seanceId),
        Atelier(id: '2', nom: 'B', description: '', type: AtelierType.physique, ordre: 1, statut: AtelierStatut.cree, seanceId: seanceId),
      ];
      
      when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => ateliers);

      final result = await service.getAteliersParSeance(seanceId);

      expect(result.first.id, '2');
      expect(result.last.id, '1');
      verify(() => mockAtelierRepo.getBySeanceId(seanceId)).called(1);
    });

    test('ajouterAtelier doit creer un atelier et mettre a jour la seance', () async {
      final seance = Seance(
        id: seanceId,
        titre: 'S1',
        date: DateTime.now(),
        heureDebut: DateTime.now(),
        heureFin: DateTime.now(),
        statut: SeanceStatus.ouverte,
        encadreurResponsableId: 'E1',
        atelierIds: [],
      );
      
      when(() => mockSeanceRepo.getById(seanceId)).thenAnswer((_) async => seance);
      when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => []);
      when(() => mockAtelierRepo.create(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Atelier);
      when(() => mockSeanceRepo.update(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Seance);

      final result = await service.ajouterAtelier(
        seanceId: seanceId,
        nom: 'Nouvel Atelier',
        type: AtelierType.dribble,
      );

      expect(result.nom, 'Nouvel Atelier');
      expect(result.seanceId, seanceId);
      verify(() => mockAtelierRepo.create(any())).called(1);
      verify(() => mockSeanceRepo.update(any())).called(1);
    });

    test('reorderAteliers doit appeler le repository et rafraichir', () async {
      final ids = ['3', '1', '2'];
      when(() => mockAtelierRepo.reorder(seanceId, ids)).thenAnswer((_) async {});
      when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => []);

      await service.reorderAteliers(seanceId, ids);

      verify(() => mockAtelierRepo.reorder(seanceId, ids)).called(1);
    });

    test('checkAutoClose doit fermer l atelier si tous les exercices sont fermes', () async {
      final exercices = [
        Exercice(id: 'e1', nom: 'Ex1', description: '', ordre: 0, statut: ExerciceStatut.ferme, atelierId: atelierId),
        Exercice(id: 'e2', nom: 'Ex2', description: '', ordre: 1, statut: ExerciceStatut.ferme, atelierId: atelierId),
      ];
      final atelier = Atelier(id: atelierId, nom: 'At1', description: '', type: AtelierType.dribble, ordre: 0, statut: AtelierStatut.cree, seanceId: seanceId);

      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => exercices);
      when(() => mockAtelierRepo.getById(atelierId)).thenAnswer((_) async => atelier);
      when(() => mockAtelierRepo.update(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Atelier);
      when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => [atelier]);

      final result = await service.checkAutoClose(atelierId);

      expect(result, isTrue);
      verify(() => mockAtelierRepo.update(any(that: predicate<Atelier>((a) => a.statut == AtelierStatut.ferme)))).called(1);
    });
    
    test('checkAutoClose ne doit pas fermer si un exercice est encore ouvert', () async {
       final exercices = [
        Exercice(id: 'e1', nom: 'Ex1', description: '', ordre: 0, statut: ExerciceStatut.ferme, atelierId: atelierId),
        Exercice(id: 'e2', nom: 'Ex2', description: '', ordre: 1, statut: ExerciceStatut.cree, atelierId: atelierId),
      ];

      when(() => mockExerciceRepo.getByAtelierId(atelierId)).thenAnswer((_) async => exercices);

      final result = await service.checkAutoClose(atelierId);

      expect(result, isFalse);
      verifyNever(() => mockAtelierRepo.update(any()));
    });

    test('ateliersStream doit emettre les nouveaux ateliers apres recuperation', () async {
      final ateliers = [
        Atelier(id: '1', nom: 'A', description: '', type: AtelierType.physique, ordre: 1, statut: AtelierStatut.cree, seanceId: seanceId),
      ];
      when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => ateliers);

      expect(service.ateliersStream, emits(ateliers));

      await service.getAteliersParSeance(seanceId);
    });

    test('modifierAtelier doit mettre a jour et rafraichir', () async {
      final atelier = Atelier(id: '1', nom: 'Old', description: '', type: AtelierType.physique, ordre: 1, statut: AtelierStatut.cree, seanceId: seanceId);
      final updatedAtelier = atelier.copyWith(nom: 'New');

      when(() => mockAtelierRepo.update(any())).thenAnswer((_) async => updatedAtelier);
      when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => [updatedAtelier]);

      final result = await service.modifierAtelier(updatedAtelier);

      expect(result.nom, 'New');
      verify(() => mockAtelierRepo.update(any())).called(1);
      verify(() => mockAtelierRepo.getBySeanceId(seanceId)).called(1);
    });

    test('supprimerAtelier doit supprimer et reordonner', () async {
      final atelier = Atelier(id: '1', nom: 'A', description: '', type: AtelierType.physique, ordre: 1, statut: AtelierStatut.cree, seanceId: seanceId);
      final seance = Seance(id: seanceId, titre: 'S1', date: DateTime.now(), heureDebut: DateTime.now(), heureFin: DateTime.now(), statut: SeanceStatus.ouverte, encadreurResponsableId: 'E1', atelierIds: ['1']);

      when(() => mockAtelierRepo.getById('1')).thenAnswer((_) async => atelier);
      when(() => mockAtelierRepo.delete('1')).thenAnswer((_) async => {});
      when(() => mockSeanceRepo.getById(seanceId)).thenAnswer((_) async => seance);
      when(() => mockSeanceRepo.update(any())).thenAnswer((_) async => seance);
      when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => []);

      await service.supprimerAtelier('1');

      verify(() => mockAtelierRepo.delete('1')).called(1);
      verify(() => mockSeanceRepo.update(any())).called(1);
    });

    test('refreshAteliers doit appeler le repository', () async {
      when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => []);

      await service.refreshAteliers(seanceId);

      verify(() => mockAtelierRepo.getBySeanceId(seanceId)).called(1);
    });

    group('appliquerAtelier', () {
      test('doit passer le statut a applique si valide et seance ouverte', () async {
        final atelier = Atelier(
          id: atelierId,
          nom: 'At1',
          description: '',
          type: AtelierType.dribble,
          ordre: 0,
          statut: AtelierStatut.valide,
          seanceId: seanceId,
        );
        final seance = Seance(
          id: seanceId,
          titre: 'S1',
          date: DateTime.now(),
          heureDebut: DateTime.now(),
          heureFin: DateTime.now(),
          statut: SeanceStatus.ouverte,
          encadreurResponsableId: 'E1',
        );

        when(() => mockAtelierRepo.getById(atelierId)).thenAnswer((_) async => atelier);
        when(() => mockSeanceRepo.getById(seanceId)).thenAnswer((_) async => seance);
        when(() => mockAtelierRepo.update(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Atelier);
        when(() => mockAtelierRepo.getBySeanceId(seanceId)).thenAnswer((_) async => []);

        final result = await service.appliquerAtelier(atelierId);

        expect(result.statut, AtelierStatut.applique);
        verify(() => mockAtelierRepo.update(any(that: predicate<Atelier>((a) => a.statut == AtelierStatut.applique)))).called(1);
      });

      test('doit lever une exception si l atelier n est pas au statut valide', () async {
        final atelier = Atelier(
          id: atelierId,
          nom: 'At1',
          description: '',
          type: AtelierType.dribble,
          ordre: 0,
          statut: AtelierStatut.cree,
          seanceId: seanceId,
        );

        when(() => mockAtelierRepo.getById(atelierId)).thenAnswer((_) async => atelier);

        expect(
          () => service.appliquerAtelier(atelierId),
          throwsA(isA<Exception>()),
        );
        verifyNever(() => mockAtelierRepo.update(any()));
      });

      test('doit lever une exception si la seance est fermee', () async {
        final atelier = Atelier(
          id: atelierId,
          nom: 'At1',
          description: '',
          type: AtelierType.dribble,
          ordre: 0,
          statut: AtelierStatut.valide,
          seanceId: seanceId,
        );
        final seance = Seance(
          id: seanceId,
          titre: 'S1',
          date: DateTime.now(),
          heureDebut: DateTime.now(),
          heureFin: DateTime.now(),
          statut: SeanceStatus.fermee,
          encadreurResponsableId: 'E1',
        );

        when(() => mockAtelierRepo.getById(atelierId)).thenAnswer((_) async => atelier);
        when(() => mockSeanceRepo.getById(seanceId)).thenAnswer((_) async => seance);

        expect(
          () => service.appliquerAtelier(atelierId),
          throwsA(isA<Exception>()),
        );
        verifyNever(() => mockAtelierRepo.update(any()));
      });
    });
  });
}
