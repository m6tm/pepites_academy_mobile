import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/annotation_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/annotation.dart';
import 'package:pepites_academy_mobile/src/presentation/state/annotation_state.dart';

class MockAnnotationService extends Mock implements AnnotationService {}

void main() {
  late AnnotationState state;
  late MockAnnotationService mockService;

  setUp(() {
    mockService = MockAnnotationService();
    state = AnnotationState(mockService);
  });

  final testAnnotation = Annotation(
    id: '1',
    contenu: 'Test',
    tags: [],
    academicienId: 'acad-1',
    atelierId: 'at-1',
    seanceId: 'se-1',
    encadreurId: 'enc-1',
    horodate: DateTime.now(),
  );

  final testAnnotationEx = Annotation(
    id: '2',
    contenu: 'Test Ex',
    tags: [],
    academicienId: 'acad-1',
    atelierId: 'at-1',
    exerciceId: 'ex-1',
    seanceId: 'se-1',
    encadreurId: 'enc-1',
    horodate: DateTime.now().add(const Duration(minutes: 1)),
  );

  test('initialiserContexte définit exerciceId et charge les annotations', () async {
    when(() => mockService.getAnnotationsAtelier(any()))
        .thenAnswer((_) async => [testAnnotation]);

    await state.initialiserContexte(
      atelierId: 'at-1',
      seanceId: 'se-1',
      exerciceId: 'ex-1',
    );

    expect(state.atelierId, 'at-1');
    expect(state.seanceId, 'se-1');
    expect(state.exerciceId, 'ex-1');
    expect(state.annotationsAtelier.length, 1);
    verify(() => mockService.getAnnotationsAtelier('at-1')).called(1);
  });

  test('selectionnerAcademicien trie l\'historique avec l\'exercice actuel en priorité', () async {
    state.initialiserContexte(atelierId: 'at-1', seanceId: 'se-1', exerciceId: 'ex-1');
    
    when(() => mockService.getAnnotationsAcademicien(any()))
        .thenAnswer((_) async => [testAnnotation, testAnnotationEx]);

    await state.selectionnerAcademicien('acad-1');

    expect(state.historiqueAcademicien.length, 2);
    // L'annotation avec exerciceId 'ex-1' doit être en première position suite au tri
    expect(state.historiqueAcademicien.first.exerciceId, 'ex-1');
    expect(state.historiqueAcademicien.first.id, '2');
  });

  test('creerAnnotation passe exerciceId au service', () async {
    await state.initialiserContexte(
      atelierId: 'at-1',
      seanceId: 'se-1',
      exerciceId: 'ex-1',
    );
    await state.selectionnerAcademicien('acad-1');

    when(() => mockService.creerAnnotation(
          contenu: any(named: 'contenu'),
          tags: any(named: 'tags'),
          note: any(named: 'note'),
          academicienId: any(named: 'academicienId'),
          atelierId: any(named: 'atelierId'),
          exerciceId: any(named: 'exerciceId'),
          seanceId: any(named: 'seanceId'),
          encadreurId: any(named: 'encadreurId'),
        )).thenAnswer((_) async => testAnnotationEx);

    final success = await state.creerAnnotation(
      contenu: 'Nouveau',
      tags: ['T1'],
      note: 8.0,
      encadreurId: 'enc-1',
    );

    expect(success, true);
    verify(() => mockService.creerAnnotation(
          contenu: 'Nouveau',
          tags: ['T1'],
          note: 8.0,
          academicienId: 'acad-1',
          atelierId: 'at-1',
          exerciceId: 'ex-1',
          seanceId: 'se-1',
          encadreurId: 'enc-1',
        )).called(1);
  });
}
