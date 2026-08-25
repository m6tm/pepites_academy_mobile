import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:pepites_academy_mobile/src/core/events/domain_event_bus.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/role.dart';
import 'package:pepites_academy_mobile/src/application/services/role_service.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/evaluation_referentiel_local_datasource.dart';
import 'package:pepites_academy_mobile/src/infrastructure/repositories/evaluation_referentiel_repository_impl.dart';
import 'package:pepites_academy_mobile/src/presentation/state/atelier_state.dart';
import 'package:pepites_academy_mobile/src/injection_container.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/ateliers/atelier_form_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAtelierState extends Mock implements AtelierState {}
class MockRoleService extends Mock implements RoleService {}

void main() {
  late MockAtelierState mockAtelierState;
  late MockRoleService mockRoleService;

  setUpAll(() async {
    mockAtelierState = MockAtelierState();
    mockRoleService = MockRoleService();
    DependencyInjection.atelierState = mockAtelierState;
    DependencyInjection.roleService = mockRoleService;
    DependencyInjection.domainEventBus = DomainEventBus();

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    DependencyInjection.evaluationReferentielRepository =
        EvaluationReferentielRepositoryImpl(
      EvaluationReferentielLocalDatasource(prefs),
    );

    registerFallbackValue(Atelier(
      id: 'dummy',
      nom: 'dummy',
      icone: 'technique',
      ordre: 0,
      statut: AtelierStatut.cree,
      seanceId: 'dummy'
    ));
  });

  setUp(() {
    reset(mockAtelierState);
    reset(mockRoleService);
    
    when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.encadreurChef);
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
        id: 'a_1', nom: 'Test', icone: 'technique',
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
        theme: any(named: 'theme'),
        objectifs: any(named: 'objectifs'),
        dureeMinutes: any(named: 'dureeMinutes'),
        categorieIds: any(named: 'categorieIds'),
        icone: any(named: 'icone'),
        configurationEvaluation: any(named: 'configurationEvaluation'),
        seanceId: any(named: 'seanceId'),
      ));
    });

    testWidgets('Appelle ajouterAtelier lors de la soumission en création', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockAtelierState.ajouterAtelier(
        nom: any(named: 'nom'),
        theme: any(named: 'theme'),
        objectifs: any(named: 'objectifs'),
        dureeMinutes: any(named: 'dureeMinutes'),
        categorieIds: any(named: 'categorieIds'),
        icone: any(named: 'icone'),
        configurationEvaluation: any(named: 'configurationEvaluation'),
        seanceId: any(named: 'seanceId'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'Nouvel Atelier');
      await tester.ensureVisible(find.text('VALIDER L\'ATELIER'));
      await tester.tap(find.text('VALIDER L\'ATELIER'));
      await tester.pump();
      
      verify(() => mockAtelierState.ajouterAtelier(
        nom: 'Nouvel Atelier',
        theme: any(named: 'theme'),
        objectifs: any(named: 'objectifs'),
        dureeMinutes: any(named: 'dureeMinutes'),
        categorieIds: any(named: 'categorieIds'),
        icone: any(named: 'icone'),
        configurationEvaluation: any(named: 'configurationEvaluation'),
        seanceId: any(named: 'seanceId'),
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
        theme: any(named: 'theme'),
        objectifs: any(named: 'objectifs'),
        dureeMinutes: any(named: 'dureeMinutes'),
        categorieIds: any(named: 'categorieIds'),
        icone: any(named: 'icone'),
        configurationEvaluation: any(named: 'configurationEvaluation'),
        seanceId: any(named: 'seanceId'),
      )).thenAnswer((_) async => false);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'Atelier Erreur');
      await tester.ensureVisible(find.text('VALIDER L\'ATELIER'));
      await tester.tap(find.text('VALIDER L\'ATELIER'));
      
      // Attente du traitement asynchrone et de l'affichage du toast
      await tester.pumpAndSettle();
      
      expect(find.text('Erreur lors de la creation'), findsOneWidget);
    });
  });
}
