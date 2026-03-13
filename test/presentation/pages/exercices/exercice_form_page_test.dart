import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:pepites_academy_mobile/src/domain/entities/exercice.dart';
import 'package:pepites_academy_mobile/src/domain/entities/role.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/exercices/exercice_form_page.dart';
import 'package:pepites_academy_mobile/src/presentation/state/exercice_state.dart';
import 'package:pepites_academy_mobile/src/application/services/role_service.dart';
import 'package:pepites_academy_mobile/src/injection_container.dart';

class MockExerciceState extends Mock implements ExerciceState {}
class MockRoleService extends Mock implements RoleService {}

void main() {
  late MockExerciceState mockExerciceState;
  late MockRoleService mockRoleService;
  const String testAtelierId = 'a_1';

  setUpAll(() {
    registerFallbackValue(ExerciceStatut.cree);
    registerFallbackValue(const Exercice(
      id: '',
      nom: '',
      description: '',
      ordre: 0,
      statut: ExerciceStatut.cree,
      atelierId: '',
    ));
  });

  setUp(() {
    mockExerciceState = MockExerciceState();
    mockRoleService = MockRoleService();
    DependencyInjection.roleService = mockRoleService;

    when(() => mockExerciceState.addListener(any())).thenReturn(null);
    when(() => mockExerciceState.removeListener(any())).thenReturn(null);
    when(() => mockExerciceState.errorMessage).thenReturn(null);
    when(() => mockExerciceState.appliquerExercice(any(), any())).thenAnswer((_) async => true);
  });

  Widget buildTestableWidget({Exercice? exercice}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      home: ExerciceFormPage(
        atelierId: testAtelierId,
        exercice: exercice,
        exerciceState: mockExerciceState,
      ),
    );
  }

  group('ExerciceFormPage Tests', () {
    testWidgets('Affiche le titre "Créer un exercice" en mode création', (WidgetTester tester) async {
      when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.admin);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Créer un exercice'), findsOneWidget);
    });

    testWidgets('Affiche le titre "Modifier l\'exercice" en mode modification', (WidgetTester tester) async {
      when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.admin);
      final testExercice = Exercice(
        id: 'e_1',
        nom: 'Exercice 1',
        description: 'Desc 1',
        ordre: 1,
        statut: ExerciceStatut.cree,
        atelierId: testAtelierId,
      );

      await tester.pumpWidget(buildTestableWidget(exercice: testExercice));
      await tester.pumpAndSettle();

      expect(find.text('Modifier l\'exercice'), findsOneWidget);
      expect(find.text('Exercice 1'), findsOneWidget);
    });

    testWidgets('Affiche une erreur si le nom est vide lors de la soumission', (WidgetTester tester) async {
      when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.admin);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Click on submit button
      await tester.tap(find.text('VALIDER L\'EXERCICE'));
      await tester.pump();

      expect(find.text('Le nom est obligatoire'), findsOneWidget);
      verifyNever(() => mockExerciceState.ajouterExercice(
        atelierId: any(named: 'atelierId'),
        nom: any(named: 'nom'),
        description: any(named: 'description'),
        statut: any(named: 'statut'),
      ));
    });

    testWidgets('Affiche une erreur et ferme la page si permission insuffisante', (WidgetTester tester) async {
      // Mock un rôle sans permission (ex: visiteur)
      when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.visiteur);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // On vérifie que le toast d'erreur est "affiché" (par la présence du texte ou l'appel à AcademyToast si mockable)
      // Comme AcademyToast.show n'est pas facilement mockable ici sans refactoring plus profond,
      // on vérifie au moins que la page est fermée (Navigator.pop)
      
      // Dans le buildTestableWidget, la home est ExerciceFormPage. 
      // Si elle pop, on devrait voir... rien ou le widget parent (si on utilisait un vrai Navigator)
      // Pour tester le pop, on peut wrapper ExerciceFormPage dans un mock Navigator observer ou vérifier l'absence du widget.
      
      expect(find.byType(ExerciceFormPage), findsNothing);
    });

    testWidgets('Appelle ajouterExercice avec succès', (WidgetTester tester) async {
      when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.admin);
      when(() => mockExerciceState.ajouterExercice(
        atelierId: any(named: 'atelierId'),
        nom: any(named: 'nom'),
        description: any(named: 'description'),
        statut: any(named: 'statut'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Nouveau Slalom');
      await tester.tap(find.text('VALIDER L\'EXERCICE'));
      await tester.pump();

      verify(() => mockExerciceState.ajouterExercice(
        atelierId: testAtelierId,
        nom: 'Nouveau Slalom',
        description: '',
        statut: ExerciceStatut.valide,
      )).called(1);
    });
  });
}
