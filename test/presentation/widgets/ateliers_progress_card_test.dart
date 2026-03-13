import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/ateliers_progress_card.dart';

void main() {
  Widget createWidgetUnderTest(List<Atelier> ateliers) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: AteliersProgressCard(ateliers: ateliers),
      ),
    );
  }

  group('AteliersProgressCard', () {
    testWidgets('displays counts correctly for various statuses', (WidgetTester tester) async {
      final ateliers = [
        const Atelier(
          id: '1', nom: 'A1', description: '', type: AtelierType.dribble, ordre: 1,
          statut: AtelierStatut.cree, seanceId: 's1',
        ),
        const Atelier(
          id: '2', nom: 'A2', description: '', type: AtelierType.passes, ordre: 2,
          statut: AtelierStatut.modifie, seanceId: 's1',
        ),
        const Atelier(
          id: '3', nom: 'A3', description: '', type: AtelierType.passes, ordre: 3,
          statut: AtelierStatut.modifie, seanceId: 's1',
        ),
        const Atelier(
          id: '4', nom: 'A4', description: '', type: AtelierType.finition, ordre: 4,
          statut: AtelierStatut.valide, seanceId: 's1',
        ),
        const Atelier(
          id: '5', nom: 'A5', description: '', type: AtelierType.finition, ordre: 5,
          statut: AtelierStatut.applique, seanceId: 's1',
        ),
        const Atelier(
          id: '6', nom: 'A6', description: '', type: AtelierType.finition, ordre: 6,
          statut: AtelierStatut.ferme, seanceId: 's1',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(ateliers));

      expect(find.text('Total: 6 ateliers'), findsOneWidget);
      expect(find.text('Créés: 1'), findsOneWidget);
      expect(find.text('Modifiés: 2'), findsOneWidget);
      expect(find.text('Validés: 1'), findsOneWidget);
      expect(find.text('Appliqués: 1'), findsOneWidget);
      expect(find.text('Fermés: 1'), findsOneWidget);
      
      // Progress calculation: (applique + ferme) / total = (1+1)/6 = 33.33% -> 33%
      expect(find.text('33%'), findsOneWidget);
    });

    testWidgets('displays 100% when all are closed or applied', (WidgetTester tester) async {
      final ateliers = [
        const Atelier(
          id: '1', nom: 'A1', description: '', type: AtelierType.dribble, ordre: 1,
          statut: AtelierStatut.ferme, seanceId: 's1',
        ),
        const Atelier(
          id: '2', nom: 'A2', description: '', type: AtelierType.passes, ordre: 2,
          statut: AtelierStatut.applique, seanceId: 's1',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(ateliers));

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('displays 0% when none are progressed', (WidgetTester tester) async {
      final ateliers = [
        const Atelier(
          id: '1', nom: 'A1', description: '', type: AtelierType.dribble, ordre: 1,
          statut: AtelierStatut.cree, seanceId: 's1',
        ),
        const Atelier(
          id: '2', nom: 'A2', description: '', type: AtelierType.passes, ordre: 2,
          statut: AtelierStatut.valide, seanceId: 's1',
        ),
      ];
      await tester.pumpWidget(createWidgetUnderTest(ateliers));

      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Créés: 1'), findsOneWidget);
      expect(find.text('Validés: 1'), findsOneWidget);
      
      // Chips with 0 count should not be displayed
      expect(find.textContaining('Modifiés:'), findsNothing);
      expect(find.textContaining('Appliqués:'), findsNothing);
      expect(find.textContaining('Fermés:'), findsNothing);
    });

    testWidgets('handles empty list correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest([]));

      expect(find.text('Total: 0 ateliers'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      
      // No chips should be visible
      expect(find.textContaining('Créés:'), findsNothing);
    });

    testWidgets('handles large number of ateliers correctly', (WidgetTester tester) async {
      final ateliers = List.generate(100, (i) => Atelier(
        id: '$i', nom: 'A$i', description: '', type: AtelierType.dribble, ordre: i,
        statut: i < 75 ? AtelierStatut.ferme : AtelierStatut.cree, seanceId: 's1',
      ));

      await tester.pumpWidget(createWidgetUnderTest(ateliers));

      expect(find.text('Total: 100 ateliers'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Fermés: 75'), findsOneWidget);
      expect(find.text('Créés: 25'), findsOneWidget);
    });
  });
}
