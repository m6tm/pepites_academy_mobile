import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/annotation_service.dart';
import 'package:pepites_academy_mobile/src/domain/entities/annotation.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event_bus.dart';
import 'package:pepites_academy_mobile/src/presentation/state/annotation_state.dart';

class MockAnnotationService extends Mock implements AnnotationService {}

void main() {
  late AnnotationState state;
  late MockAnnotationService mockService;
  late DomainEventBus eventBus;

  setUp(() {
    mockService = MockAnnotationService();
    eventBus = DomainEventBus();
    state = AnnotationState(mockService, eventBus);
  });

  final testScore = ScoreAnnotation(
    critereId: 'crite-1',
    element1Id: 'elem-1',
    noteElement1: 3.0,
    element2Id: 'elem-2',
    noteElement2: 4.0,
  );

  final testAnnotation = Annotation(
    id: '1',
    academicienId: 'acad-1',
    atelierId: 'at-1',
    seanceId: 'se-1',
    encadreurId: 'enc-1',
    horodate: DateTime.now(),
    scores: [testScore],
    commentaire: 'Test',
  );

  final testAnnotationEx = Annotation(
    id: '2',
    academicienId: 'acad-1',
    atelierId: 'at-1',
    exerciceId: 'ex-1',
    seanceId: 'se-1',
    encadreurId: 'enc-1',
    horodate: DateTime.now().add(const Duration(minutes: 1)),
    scores: [testScore],
    commentaire: 'Test Ex',
  );

  test('initialiserContexte definit exerciceId et charge les annotations', () async {
    when(() => mockService.getAnnotationsAtelier(any(), forceRefresh: any(named: 'forceRefresh')))
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
    verify(() => mockService.getAnnotationsAtelier('at-1', forceRefresh: true)).called(1);
  });

  test('selectionnerAcademicien trie l\'historique avec l\'exercice actuel en priorite', () async {
    state.initialiserContexte(atelierId: 'at-1', seanceId: 'se-1', exerciceId: 'ex-1');
    
    when(() => mockService.getAnnotationsAcademicien(any()))
        .thenAnswer((_) async => [testAnnotation, testAnnotationEx]);

    await state.selectionnerAcademicien('acad-1');

    expect(state.historiqueAcademicien.length, 2);
    expect(state.historiqueAcademicien.first.exerciceId, 'ex-1');
    expect(state.historiqueAcademicien.first.id, '2');
  });

  test('creerAnnotation passe les scores au service', () async {
    await state.initialiserContexte(
      atelierId: 'at-1',
      seanceId: 'se-1',
      exerciceId: 'ex-1',
    );
    await state.selectionnerAcademicien('acad-1');

    when(() => mockService.creerAnnotation(
          scores: any(named: 'scores'),
          commentaire: any(named: 'commentaire'),
          academicienId: any(named: 'academicienId'),
          atelierId: any(named: 'atelierId'),
          exerciceId: any(named: 'exerciceId'),
          seanceId: any(named: 'seanceId'),
          encadreurId: any(named: 'encadreurId'),
        )).thenAnswer((_) async => testAnnotationEx);

    final success = await state.creerAnnotation(
      scores: [testScore],
      commentaire: 'Nouveau',
      encadreurId: 'enc-1',
    );

    expect(success, true);
    verify(() => mockService.creerAnnotation(
          scores: [testScore],
          commentaire: 'Nouveau',
          academicienId: 'acad-1',
          atelierId: 'at-1',
          exerciceId: 'ex-1',
          seanceId: 'se-1',
          encadreurId: 'enc-1',
        )).called(1);
  });
}