import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepites_academy_mobile/src/presentation/widgets/icon_selector.dart';
import 'package:pepites_academy_mobile/src/presentation/theme/app_colors.dart';

void main() {
  group('IconSelector Tests', () {
    testWidgets('Affiche tous les icônes disponibles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelector(
              onIconSelected: (_) {},
            ),
          ),
        ),
      );

      // Vérifie la présence de quelques icônes clés par leur icône Material
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('Appelle onIconSelected quand une icône est tapée', (tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelector(
              onIconSelected: (val) => selectedValue = val,
            ),
          ),
        ),
      );

      // Tape sur l'icône "Physique" (directions_run)
      await tester.tap(find.byIcon(Icons.directions_run));
      await tester.pump();

      expect(selectedValue, 'directions_run');
    });

    testWidgets('Met en évidence l\'icône sélectionnée', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Scaffold(
            body: IconSelector(
              selectedIcon: 'timer',
              onIconSelected: (_) {},
            ),
          ),
        ),
      );

      // On cherche le container qui a la couleur primaire (sélection)
      final animatedContainerFinder = find.byType(AnimatedContainer);
      
      // On vérifie que l'un des containers a la couleur primary
      bool foundSelected = false;
      for (final element in tester.elementList(animatedContainerFinder)) {
        final container = element.widget as AnimatedContainer;
        final decoration = container.decoration as BoxDecoration?;
        if (decoration?.color == AppColors.primary) {
          foundSelected = true;
          break;
        }
      }
      
      expect(foundSelected, isTrue);
    });
  });
}
