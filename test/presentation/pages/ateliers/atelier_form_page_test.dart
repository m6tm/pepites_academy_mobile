import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/role.dart';
import 'package:pepites_academy_mobile/src/application/services/role_service.dart';
import 'package:pepites_academy_mobile/src/presentation/state/atelier_state.dart';
import 'package:pepites_academy_mobile/src/injection_container.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/ateliers/atelier_form_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAtelierState extends Mock implements AtelierState {}
class MockRoleService extends Mock implements RoleService {}

void main() {
  late MockAtelierState mockAtelierState;
  late MockRoleService mockRoleService;

  setUpAll(() {
    mockAtelierState = MockAtelierState();
    mockRoleService = MockRoleService();
    DependencyInjection.atelierState = mockAtelierState;
    DependencyInjection.roleService = mockRoleService;
    
    registerFallbackValue(Atelier(
      id: 'dummy', 
      nom: 'dummy', 
      description: 'dummy', 
      type: AtelierType.dribble, 
      ordre: 0, 
      statut: AtelierStatut.cree, 
      seanceId: 'dummy'
    ));
    registerFallbackValue(AtelierType.dribble);
  });

  setUp(() {
    reset(mockAtelierState);
    reset(mockRoleService);
    
    when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.admin);
  });

  Widget buildTestableWidget({Atelier? atelier}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      home: AtelierFormPage(
        seanceId: 's_1',
        atelier: atelier,
        atelierState: mockAtelierState,
      ),
    );
  }

  group('AtelierFormPage Tests', () {
    testWidgets('Affiche "Créer un atelier" en mode création', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      expect(find.text('Créer un atelier'), findsOneWidget);
    });

    testWidgets('Affiche "Modifier l\'atelier" en mode édition', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testAtelier = Atelier(
        id: 'a_1', nom: 'Test', description: '', type: AtelierType.dribble,
        ordre: 0, statut: AtelierStatut.cree, seanceId: 's_1'
      );
      await tester.pumpWidget(buildTestableWidget(atelier: testAtelier));
      await tester.pumpAndSettle();
      expect(find.text('Modifier l\'atelier'), findsOneWidget);
    });

    testWidgets('Validation bloquante si le nom est vide', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      
      await tester.ensureVisible(find.text('VALIDER L\'ATELIER'));
      await tester.tap(find.text('VALIDER L\'ATELIER'));
      await tester.pump();
      
      expect(find.text('Le nom est obligatoire'), findsOneWidget);
      verifyNever(() => mockAtelierState.ajouterAtelier(
        nom: any(named: 'nom'),
        type: any(named: 'type'),
        description: any(named: 'description'),
        icone: any(named: 'icone'),
      ));
    });

    testWidgets('Appelle ajouterAtelier lors de la soumission en création', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockAtelierState.ajouterAtelier(
        nom: any(named: 'nom'),
        type: any(named: 'type'),
        description: any(named: 'description'),
        icone: any(named: 'icone'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'Nouvel Atelier');
      await tester.ensureVisible(find.text('VALIDER L\'ATELIER'));
      await tester.tap(find.text('VALIDER L\'ATELIER'));
      await tester.pump();
      
      verify(() => mockAtelierState.ajouterAtelier(
        nom: 'Nouvel Atelier',
        type: any(named: 'type'),
        description: any(named: 'description'),
        icone: any(named: 'icone'),
      )).called(1);
    });

    testWidgets('Pop la page si l\'utilisateur n\'a pas la permission', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Mock du rôle sans les permissions nécessaires
      when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.visiteur);
      
      // On utilise un Navigator pour observer le pop
      await tester.pumpWidget(buildTestableWidget());
      
      // On attend l'exécution de initState et du microtask de permission
      await tester.pumpAndSettle();
      
      // On vérifie que le widget n'est plus présent (le pop a eu lieu)
      expect(find.byType(AtelierFormPage), findsNothing);
    });

    testWidgets('Affiche un toast d\'erreur si la soumission échoue', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockAtelierState.ajouterAtelier(
        nom: any(named: 'nom'),
        type: any(named: 'type'),
        description: any(named: 'description'),
        icone: any(named: 'icone'),
      )).thenAnswer((_) async => false);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'Atelier Erreur');
      await tester.ensureVisible(find.text('VALIDER L\'ATELIER'));
      await tester.tap(find.text('VALIDER L\'ATELIER'));
      
      // Attente du traitement asynchrone et de l'affichage du toast
      await tester.pumpAndSettle();
      
      expect(find.text('Erreur lors de la création'), findsOneWidget);
    });
  });
}
