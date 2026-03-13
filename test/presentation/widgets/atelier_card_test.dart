import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/atelier_card.dart';

void main() {
  late Atelier testAtelier;
  late Exercice testExercice;

  setUp(() {
    testAtelier = Atelier(
      id: 'at_1',
      seanceId: 'seance_1',
      nom: 'Test Atelier',
      description: 'Description du test atelier',
      type: AtelierType.dribble,
      statut: AtelierStatut.cree,
      ordre: 1,
    );

    testExercice = Exercice(
      id: 'ex_1',
      atelierId: 'at_1',
      nom: 'Test Exercice',
      description: 'Description du test exercice',
      statut: ExerciceStatut.cree,
      ordre: 1,
    );
  });

  Widget buildTestableWidget({
    required bool isEditable,
    List<Exercice>? exercicesOverride,
    Function(Exercice)? onCloseExercice,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AtelierCard(
          atelier: testAtelier,
          exercices: exercicesOverride ?? [testExercice],
          isEditable: isEditable,
          onEdit: () {},
          onDelete: () {},
          onAddExercice: () {},
          onAnnotate: () {},
          onEditExercice: (ex) {},
          onDeleteExercice: (ex) {},
          onCloseExercice: onCloseExercice,
        ),
      ),
    );
  }

  testWidgets('AtelierCard displays basic information', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(isEditable: false));

    // Vérifie le nom de l'atelier
    expect(find.text('Test Atelier'), findsOneWidget);
    // Vérifie le nombre d'exercices affiché
    expect(find.text('1 exercices'), findsOneWidget);
    
    // Les boutons d'édition ne doivent pas être visibles en mode lecture seule
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
  });

  testWidgets('AtelierCard shows edit buttons in edit mode', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(isEditable: true));

    // Les boutons d'édition doivent être visibles
    expect(find.byIcon(Icons.edit_outlined), findsWidgets); // 1 pour edit atelier, 1 pour exercice
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets); // 1 pour delete atelier, 1 pour exercice
  });

  testWidgets('AtelierCard expands and shows exercises when tapped', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(isEditable: true));

    // L'exercice ne devrait pas être visible au début (ou alors dans une AnimatedCrossFade cachée)
    // Tester exactement dans un tree nécessite de vérifier la crossFadeState, on va vérifier le nom
    
    // Tap sur la carte pour l'étendre
    await tester.tap(find.text('Test Atelier'));
    await tester.pumpAndSettle(); // Attend l'animation
    
    // Après expansion, l'exercice devrait être interactif/visible
    expect(find.text('Test Exercice'), findsOneWidget);
    expect(find.text('Description du test exercice'), findsOneWidget);
    
    // Bouton ajouter un exercice
    expect(find.text('Ajouter un exercice'), findsOneWidget);
  });

  testWidgets('AtelierCard triggers onCloseExercice when the close button is tapped', (WidgetTester tester) async {
    Exercice? closedExercice;
    
    // On met l'exercice en statut appliqué pour que le bouton Fermer apparaisse
    final appliqueExercice = testExercice.copyWith(statut: ExerciceStatut.applique);

    await tester.pumpWidget(buildTestableWidget(
      isEditable: true,
      exercicesOverride: [appliqueExercice],
      onCloseExercice: (ex) {
        closedExercice = ex;
      },
    ));

    // Tap sur la carte pour l'étendre
    await tester.tap(find.text('Test Atelier'));
    await tester.pumpAndSettle(); // Attend l'animation

    // Vérifier que le bouton de fermeture est apparu
    final closeButtonFinder = find.byTooltip('Fermer l\'exercice');
    expect(closeButtonFinder, findsOneWidget);

    // Tap sur le bouton de fermeture
    await tester.tap(closeButtonFinder);
    await tester.pumpAndSettle();

    // Vérifier que la callback a été appelée avec le bon exercice
    expect(closedExercice, isNotNull);
    expect(closedExercice?.id, appliqueExercice.id);
  });
}
