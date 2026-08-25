import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/l10n/app_localizations.dart';
import 'package:pepites_academy_mobile/src/domain/entities/seance.dart';
import 'package:pepites_academy_mobile/src/domain/entities/atelier.dart';
import 'package:pepites_academy_mobile/src/domain/entities/permission.dart';
import 'package:pepites_academy_mobile/src/domain/entities/role.dart';
import 'package:pepites_academy_mobile/src/application/services/role_service.dart';
import 'package:pepites_academy_mobile/src/presentation/state/atelier_state.dart';
import 'package:pepites_academy_mobile/src/presentation/state/exercice_state.dart';
import 'package:pepites_academy_mobile/src/presentation/state/annotation_state.dart';
import 'package:pepites_academy_mobile/src/injection_container.dart';
import 'package:pepites_academy_mobile/src/presentation/pages/ateliers/ateliers_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAtelierState extends Mock implements AtelierState {}

class MockExerciceState extends Mock implements ExerciceState {}

class MockAnnotationState extends Mock implements AnnotationState {}

class MockRoleService extends Mock implements RoleService {}

void main() {
  late MockAtelierState mockAtelierState;
  late MockExerciceState mockExerciceState;
  late MockAnnotationState mockAnnotationState;
  late MockRoleService mockRoleService;
  late Seance testSeance;

  setUpAll(() {
    mockAtelierState = MockAtelierState();
    mockExerciceState = MockExerciceState();
    mockAnnotationState = MockAnnotationState();
    mockRoleService = MockRoleService();

    // Inject mocks only once
    DependencyInjection.atelierState = mockAtelierState;
    DependencyInjection.exerciceState = mockExerciceState;
    DependencyInjection.annotationState = mockAnnotationState;
    DependencyInjection.roleService = mockRoleService;
  });

  setUp(() {
    reset(mockAtelierState);
    reset(mockExerciceState);
    reset(mockAnnotationState);
    reset(mockRoleService);

    // Default implementations
    when(() => mockAtelierState.isLoading).thenReturn(false);
    when(() => mockAtelierState.ateliers).thenReturn([]);
    when(
      () => mockAtelierState.chargerAteliers(any()),
    ).thenAnswer((_) async {});
    when(() => mockAtelierState.addListener(any())).thenReturn(null);
    when(() => mockAtelierState.removeListener(any())).thenReturn(null);

    when(() => mockExerciceState.addListener(any())).thenReturn(null);
    when(() => mockExerciceState.removeListener(any())).thenReturn(null);
    when(() => mockExerciceState.isLoading(any())).thenReturn(false);
    when(() => mockExerciceState.chargerExercices(any())).thenAnswer((_) async {});
    when(() => mockExerciceState.exercicesParAtelier).thenReturn({});

    when(
      () => mockRoleService.getCurrentUserRole(),
    ).thenAnswer((_) async => Role.admin);

    when(() => mockAtelierState.appliquerAtelier(any())).thenAnswer((_) async => true);
    when(() => mockAtelierState.isProcessingAtelier(any())).thenReturn(false);
    when(() => mockExerciceState.appliquerExercice(any(), any())).thenAnswer((_) async => true);

    testSeance = Seance(
      id: 's_1',
      titre: 'Seance Test',
      date: DateTime.now(),
      heureDebut: DateTime.now(),
      heureFin: DateTime.now().add(const Duration(hours: 2)),
      statut: SeanceStatus.ouverte,
      encadreurResponsableId: 'e_1',
    );
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      home: AteliersPage(seance: testSeance),
    );
  }

  group('AteliersPage Tests', () {
    testWidgets('Affiche le Loading State quand getAteliers est en cours', (
      WidgetTester tester,
    ) async {
      when(() => mockAtelierState.isLoading).thenReturn(true);

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Affiche le Empty State quand il n\'y a aucun atelier', (
      WidgetTester tester,
    ) async {
      when(() => mockAtelierState.isLoading).thenReturn(false);
      when(() => mockAtelierState.ateliers).thenReturn([]);

      await tester.pumpWidget(buildTestableWidget());
      // Attente de l'initstate et des microtasks
      await tester.pumpAndSettle();

      // Verification textuelle du empty state selon les traductions
      // L'icone sports_soccer_rounded est marquee pour le state empty
      expect(find.byIcon(Icons.sports_soccer_rounded), findsWidgets);
    });

    testWidgets('Ne doit pas afficher le bouton Appliquer si la seance est fermee', (
      WidgetTester tester,
    ) async {
      // Setup seance fermee
      testSeance = testSeance.copyWith(statut: SeanceStatus.fermee);
      
      final atelier = Atelier(
        id: 'at_1',
        nom: 'Atelier Test',
        icone: 'technique',
        ordre: 0,
        statut: AtelierStatut.valide,
        seanceId: testSeance.id,
      );

      when(() => mockAtelierState.isLoading).thenReturn(false);
      when(() => mockAtelierState.ateliers).thenReturn([atelier]);
      when(() => mockExerciceState.exercicesParAtelier).thenReturn({'at_1': []});
      when(() => mockRoleService.hasPermission(Permission.atelierApply)).thenReturn(true);
      when(() => mockRoleService.hasPermission(Permission.exerciceApply)).thenReturn(true);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // L'icone play_circle_outline_rounded ne doit pas etre presente
      expect(find.byIcon(Icons.play_circle_outline_rounded), findsNothing);
    });
  });
}
