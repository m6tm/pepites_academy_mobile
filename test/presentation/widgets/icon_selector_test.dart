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

      // Vérifie la présence des 6 icônes d'atelier par leur icône Material
      expect(find.byIcon(Icons.build_rounded), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
      expect(find.byIcon(Icons.map_rounded), findsOneWidget);
      expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);
      expect(find.byIcon(Icons.rule_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_rounded), findsOneWidget);
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

      // Tape sur l'icône "Physique" (fitness_center_rounded)
      await tester.tap(find.byIcon(Icons.fitness_center_rounded));
      await tester.pump();

      expect(selectedValue, 'physique');
    });

    testWidgets('Met en évidence l\'icône sélectionnée', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Scaffold(
            body: IconSelector(
              selectedIcon: 'technique',
              onIconSelected: (_) {},
            ),
          ),
        ),
      );

      // On cherche le container qui a la couleur de l'icône sélectionnée
      final animatedContainerFinder = find.byType(AnimatedContainer);
      final selectedColor = AtelierIconeMapper.getColor('technique');

      bool foundSelected = false;
      for (final element in tester.elementList(animatedContainerFinder)) {
        final container = element.widget as AnimatedContainer;
        final decoration = container.decoration as BoxDecoration?;
        if (decoration?.color == selectedColor) {
          foundSelected = true;
          break;
        }
      }

      expect(foundSelected, isTrue);
    });
  });
}
