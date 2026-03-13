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
import 'package:pepites_academy_mobile/src/presentation/pages/seance/atelier_composition_page.dart';
import 'package:pepites_academy_mobile/src/presentation/state/connectivity_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockAtelierState extends Mock implements AtelierState {}
class MockExerciceState extends Mock implements ExerciceState {}
class MockAnnotationState extends Mock implements AnnotationState {}
class MockRoleService extends Mock implements RoleService {}
class MockConnectivityState extends Mock implements ConnectivityState {}

void main() {
  late MockAtelierState mockAtelierState;
  late MockExerciceState mockExerciceState;
  late MockAnnotationState mockAnnotationState;
  late MockRoleService mockRoleService;
  late MockConnectivityState mockConnectivityState;
  late Seance testSeance;

  setUpAll(() {
    mockAtelierState = MockAtelierState();
    mockExerciceState = MockExerciceState();
    mockAnnotationState = MockAnnotationState();
    mockRoleService = MockRoleService();
    mockConnectivityState = MockConnectivityState();

    DependencyInjection.atelierState = mockAtelierState;
    DependencyInjection.exerciceState = mockExerciceState;
    DependencyInjection.annotationState = mockAnnotationState;
    DependencyInjection.roleService = mockRoleService;
    DependencyInjection.connectivityState = mockConnectivityState;

    registerFallbackValue(Permission.atelierCreate);
  });

  setUp(() {
    reset(mockAtelierState);
    reset(mockExerciceState);
    reset(mockAnnotationState);
    reset(mockRoleService);
    reset(mockConnectivityState);

    when(() => mockConnectivityState.isConnected).thenReturn(false);

    when(() => mockAtelierState.isLoading).thenReturn(false);
    when(() => mockAtelierState.ateliers).thenReturn([]);
    when(() => mockAtelierState.addListener(any())).thenReturn(null);
    when(() => mockAtelierState.removeListener(any())).thenReturn(null);
    when(() => mockAtelierState.chargerAteliers(any())).thenAnswer((_) async {});

    when(() => mockExerciceState.isLoading(any())).thenReturn(false);
    when(() => mockExerciceState.exercicesParAtelier).thenReturn({});
    when(() => mockExerciceState.addListener(any())).thenReturn(null);
    when(() => mockExerciceState.removeListener(any())).thenReturn(null);
    when(() => mockExerciceState.chargerExercices(any())).thenAnswer((_) async {});

    when(() => mockRoleService.getCurrentUserRole()).thenAnswer((_) async => Role.admin);
    when(() => mockRoleService.hasPermission(any())).thenReturn(true);

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
      home: AtelierCompositionPage(
        seance: testSeance,
        atelierState: mockAtelierState,
        exerciceState: mockExerciceState,
      ),
    );
  }

  group('AtelierCompositionPage Tests', () {
    testWidgets('Ne doit pas afficher le bouton Appliquer si la seance est fermee', (tester) async {
      testSeance = testSeance.copyWith(statut: SeanceStatus.fermee);
      
      final atelier = Atelier(
        id: 'at_1',
        nom: 'Atelier Test',
        description: '',
        type: AtelierType.dribble,
        ordre: 0,
        statut: AtelierStatut.valide,
        seanceId: testSeance.id,
      );

      when(() => mockAtelierState.ateliers).thenReturn([atelier]);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // On verifie que le bouton Appliquer (play_circle_outline_rounded) n'est pas la
      expect(find.byIcon(Icons.play_circle_outline_rounded), findsNothing);
    });

    testWidgets('Doit afficher le bouton Appliquer si la seance est ouverte et utilisateur a permission', (tester) async {
      final atelier = Atelier(
        id: 'at_1',
        nom: 'Atelier Test',
        description: '',
        type: AtelierType.dribble,
        ordre: 0,
        statut: AtelierStatut.valide,
        seanceId: testSeance.id,
      );

      when(() => mockAtelierState.ateliers).thenReturn([atelier]);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_circle_outline_rounded), findsOneWidget);
    });
  });
}
