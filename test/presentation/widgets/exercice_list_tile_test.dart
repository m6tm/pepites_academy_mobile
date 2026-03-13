import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/exercice_list_tile.dart';

void main() {
  late Exercice testExercice;

  setUp(() {
    testExercice = Exercice(
      id: 'ex_1',
      atelierId: 'at_1',
      nom: 'Passe et suit',
      description: 'Travailler le jeu en mouvement',
      statut: ExerciceStatut.cree,
      ordre: 1,
    );
  });

  Widget buildTestableWidget({
    required Exercice exercice,
    bool isEditable = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ExerciceListTile(
          exercice: exercice,
          isEditable: isEditable,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }

  group('ExerciceListTile Tests', () {
    testWidgets('Affiche le nom et la description de l\'exercice', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(exercice: testExercice));

      expect(find.text('Passe et suit'), findsOneWidget);
      expect(find.text('Travailler le jeu en mouvement'), findsOneWidget);
    });

    testWidgets('Affiche l\'indicateur de statut', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(exercice: testExercice));

      // L'indicateur de statut devrait contenir l'icône de création (add_circle_outline_rounded pour cree)
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('Ne montre pas les boutons d\'édition si isEditable est false', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        exercice: testExercice,
        isEditable: false,
      ));

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('Montre les boutons d\'édition si isEditable est true', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        exercice: testExercice,
        isEditable: true,
        onEdit: () {},
        onDelete: () {},
      ));

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('Appelle les callbacks lors du clic sur les boutons d\'édition', (WidgetTester tester) async {
      bool editCalled = false;
      bool deleteCalled = false;

      await tester.pumpWidget(buildTestableWidget(
        exercice: testExercice,
        isEditable: true,
        onEdit: () {
          editCalled = true;
        },
        onDelete: () {
          deleteCalled = true;
        },
      ));

      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(editCalled, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      expect(deleteCalled, isTrue);
    });

    testWidgets('Gère un exercice sans description', (WidgetTester tester) async {
      final exerciceSansDesc = testExercice.copyWith(description: '');
      
      await tester.pumpWidget(buildTestableWidget(exercice: exerciceSansDesc));

      expect(find.text('Passe et suit'), findsOneWidget);
      // Ne devrait pas crasher et ne pas afficher de description vide
    });
  });
}
