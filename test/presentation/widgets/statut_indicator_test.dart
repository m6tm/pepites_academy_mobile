import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/enums/atelier_statut.dart';
import 'package:pepites_academy_mobile/src/domain/entities/enums/exercice_statut.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/statut_indicator.dart';

void main() {
  Widget buildTestableWidget(Enum statut) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: StatutIndicator(statut: statut),
        ),
      ),
    );
  }

  group('StatutIndicator Tests avec AtelierStatut', () {
    testWidgets('Affiche bleu et add_circle pour cree', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AtelierStatut.cree));

      final iconFinder = find.byIcon(Icons.add_circle_outline_rounded);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, Colors.blue);
    });

    testWidgets('Affiche orange et edit_note pour modifie', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AtelierStatut.modifie));

      final iconFinder = find.byIcon(Icons.edit_note_rounded);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, Colors.orange);
    });

    testWidgets('Affiche vert et check_circle pour valide', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AtelierStatut.valide));

      final iconFinder = find.byIcon(Icons.check_circle_outline_rounded);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, Colors.green);
    });

    testWidgets('Affiche gris et lock pour ferme', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(AtelierStatut.ferme));

      final iconFinder = find.byIcon(Icons.lock_outline_rounded);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, Colors.grey);
    });
  });

  group('StatutIndicator Tests avec ExerciceStatut', () {
    testWidgets('Affiche violet et play_circle pour applique', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ExerciceStatut.applique));

      final iconFinder = find.byIcon(Icons.play_circle_outline_rounded);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, Colors.purple);
    });

    testWidgets('Affiche bleu et add_circle pour cree', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ExerciceStatut.cree));

      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
    });
  });
}
