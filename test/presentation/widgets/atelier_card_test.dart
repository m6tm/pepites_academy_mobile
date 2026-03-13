import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/atelier_card.dart';

void main() {
  const tAtelier = Atelier(
    id: '1',
    nom: 'Dribble',
    description: 'Description test',
    type: AtelierType.dribble,
    ordre: 0,
    statut: AtelierStatut.valide,
    seanceId: '42',
  );

  const tExercices = [
    Exercice(id: 'e1', nom: 'Ex 1', description: '', ordre: 0, statut: ExerciceStatut.cree, atelierId: '1'),
  ];

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('should display atelier name and number of exercices', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(
      const AtelierCard(
        atelier: tAtelier,
        exercices: tExercices,
        index: 0,
      ),
    ));

    expect(find.text('Dribble'), findsOneWidget);
    expect(find.text('1 exercices'), findsOneWidget);
  });

  testWidgets('should expand and show description when tapped', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(
      const AtelierCard(
        atelier: tAtelier,
        exercices: tExercices,
        index: 0,
      ),
    ));

    // Description should be hidden initially (it's in the second child of AnimatedCrossFade)
    // But RenderBox might still find it if it's in the tree. 
    // Usually CrossFade hides it.
    
    await tester.tap(find.text('Dribble'));
    await tester.pumpAndSettle();

    expect(find.text('Description test'), findsOneWidget);
    expect(find.text('Ex 1'), findsOneWidget);
  });

  testWidgets('should call onEdit when edit button is pressed', (WidgetTester tester) async {
    bool editCalled = false;
    await tester.pumpWidget(makeTestableWidget(
      AtelierCard(
        atelier: tAtelier,
        exercices: tExercices,
        index: 0,
        isEditable: true,
        onEdit: () => editCalled = true,
      ),
    ));

    await tester.tap(find.byIcon(Icons.edit_outlined));
    expect(editCalled, isTrue);
  });
}
