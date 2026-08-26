import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pepites_academy_mobile/src/application/services/sync_service.dart';
import 'package:pepites_academy_mobile/src/core/network/connectivity_guard.dart';
import 'package:pepites_academy_mobile/src/core/resilience/mutation_resilience_handler.dart';
import 'package:pepites_academy_mobile/src/core/resilience/resilience_result.dart';
import 'package:pepites_academy_mobile/src/domain/entities/sync_operation.dart';
import 'package:pepites_academy_mobile/src/infrastructure/datasources/api_sync_datasource.dart';

class MockSyncService extends Mock implements SyncService {}

class MockApiSyncDatasource extends Mock implements ApiSyncDatasource {}

class MockConnectivityGuard extends Mock implements ConnectivityGuard {}

void main() {
  late MutationResilienceHandler handler;
  late MockSyncService mockSyncService;
  late MockApiSyncDatasource mockApiSyncDatasource;
  late MockConnectivityGuard mockConnectivityGuard;

  setUpAll(() {
    registerFallbackValue(SyncEntityType.atelier);
    registerFallbackValue(SyncOperationType.delete);
    registerFallbackValue(
      SyncOperation(
        id: 'fallback',
        entityType: SyncEntityType.atelier,
        entityId: 'fallback',
        operationType: SyncOperationType.delete,
        payload: '{}',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockSyncService = MockSyncService();
    mockApiSyncDatasource = MockApiSyncDatasource();
    mockConnectivityGuard = MockConnectivityGuard();
    handler = MutationResilienceHandler(
      syncService: mockSyncService,
      apiSyncDatasource: mockApiSyncDatasource,
      connectivityGuard: mockConnectivityGuard,
    );
  });

  group('MutationResilienceHandler', () {
    test('doit executer la requete en ligne si un payload est reconstruit depuis la file', () async {
      // Arrange
      when(() => mockConnectivityGuard.isOnline).thenAnswer((_) async => true);
      when(() => mockSyncService.rebuildPayload(
            SyncEntityType.exercice,
            'local-id',
          )).thenAnswer((_) async => {'nom': 'Exercice recupere', 'atelier_id': 'atelier-1'});
      when(() => mockApiSyncDatasource.pushOperationWithPayload(
            any(),
            any(),
          )).thenAnswer(
        (_) async => SyncResult(
          success: true,
          serverResponse: {'id': 'server-uuid', 'nom': 'Exercice recupere'},
        ),
      );

      // Act
      final result = await handler.recover(
        entityType: SyncEntityType.exercice,
        entityId: 'local-id',
        operationType: SyncOperationType.create,
      );

      // Assert
      expect(result, isA<ResilienceSuccess<Map<String, dynamic>>>());
      final success = result as ResilienceSuccess<Map<String, dynamic>>;
      expect(success.wasRebuilt, isTrue);
      expect(success.data['id'], 'server-uuid');

      final captured = verify(
        () => mockApiSyncDatasource.pushOperationWithPayload(
          captureAny(),
          captureAny(),
        ),
      ).captured;
      final payload = captured[1] as Map<String, dynamic>;
      expect(payload.containsKey('id'), isFalse);
      expect(payload['nom'], 'Exercice recupere');
    });

    test('doit enfiler l operation si l appareil est hors ligne', () async {
      // Arrange
      when(() => mockConnectivityGuard.isOnline).thenAnswer((_) async => false);
      when(() => mockSyncService.rebuildPayload(
            SyncEntityType.atelier,
            'atelier-id',
          )).thenAnswer((_) async => {'nom': 'Atelier recupere'});
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Future<void>.value());

      // Act
      final result = await handler.recover(
        entityType: SyncEntityType.atelier,
        entityId: 'atelier-id',
        operationType: SyncOperationType.update,
      );

      // Assert
      expect(result, isA<ResilienceEnqueued<Map<String, dynamic>>>());
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.atelier,
            entityId: 'atelier-id',
            operationType: SyncOperationType.update,
            data: any(named: 'data', that: containsPair('id', 'atelier-id')),
          )).called(1);
      verifyNever(() => mockApiSyncDatasource.pushOperationWithPayload(any(), any()));
    });

    test('doit utiliser le fallback payload si la file est vide', () async {
      // Arrange
      when(() => mockConnectivityGuard.isOnline).thenAnswer((_) async => true);
      when(() => mockSyncService.rebuildPayload(any(), any())).thenAnswer((_) async => null);
      when(() => mockApiSyncDatasource.pushOperationWithPayload(
            any(),
            any(),
          )).thenAnswer(
        (_) async => SyncResult(success: true, serverResponse: {'ok': true}),
      );

      // Act
      final result = await handler.recover(
        entityType: SyncEntityType.exercice,
        entityId: 'exercice-id',
        operationType: SyncOperationType.update,
        fallbackPayload: {'nom': 'Fallback'},
      );

      // Assert
      expect(result, isA<ResilienceSuccess<Map<String, dynamic>>>());
      final captured = verify(
        () => mockApiSyncDatasource.pushOperationWithPayload(any(), captureAny()),
      ).captured;
      expect((captured.first as Map<String, dynamic>)['nom'], 'Fallback');
    });

    test('doit retourner un echec si aucune donnée source n est disponible', () async {
      // Arrange
      when(() => mockConnectivityGuard.isOnline).thenAnswer((_) async => true);
      when(() => mockSyncService.rebuildPayload(any(), any())).thenAnswer((_) async => null);

      // Act
      final result = await handler.recover(
        entityType: SyncEntityType.atelier,
        entityId: 'atelier-id',
        operationType: SyncOperationType.update,
      );

      // Assert
      expect(result, isA<ResilienceFailure<Map<String, dynamic>>>());
      verifyNever(() => mockApiSyncDatasource.pushOperationWithPayload(any(), any()));
    });

    test('doit remettre en file d attente si le serveur retourne une erreur autre que 404', () async {
      // Arrange
      when(() => mockConnectivityGuard.isOnline).thenAnswer((_) async => true);
      when(() => mockSyncService.rebuildPayload(any(), any())).thenAnswer(
        (_) async => {'nom': 'Exercice'},
      );
      when(() => mockApiSyncDatasource.pushOperationWithPayload(any(), any())).thenAnswer(
        (_) async => SyncResult(
          success: false,
          errorMessage: 'Server error',
          statusCode: 500,
        ),
      );
      when(() => mockSyncService.enqueueOperation(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operationType: any(named: 'operationType'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Future<void>.value());

      // Act
      final result = await handler.recover(
        entityType: SyncEntityType.exercice,
        entityId: 'exercice-id',
        operationType: SyncOperationType.update,
      );

      // Assert
      expect(result, isA<ResilienceEnqueued<Map<String, dynamic>>>());
      verify(() => mockSyncService.enqueueOperation(
            entityType: SyncEntityType.exercice,
            entityId: 'exercice-id',
            operationType: SyncOperationType.update,
            data: any(named: 'data'),
          )).called(1);
    });

    test('doit renvoyer un payload minimal delete si aucune donnée source', () async {
      // Arrange
      when(() => mockConnectivityGuard.isOnline).thenAnswer((_) async => true);
      when(() => mockSyncService.rebuildPayload(any(), any())).thenAnswer((_) async => null);
      when(() => mockApiSyncDatasource.pushOperationWithPayload(any(), any())).thenAnswer(
        (_) async => SyncResult(success: true),
      );

      // Act
      final result = await handler.recover(
        entityType: SyncEntityType.atelier,
        entityId: 'atelier-id',
        operationType: SyncOperationType.delete,
      );

      // Assert
      expect(result, isA<ResilienceSuccess<Map<String, dynamic>>>());
      final captured = verify(
        () => mockApiSyncDatasource.pushOperationWithPayload(any(), captureAny()),
      ).captured;
      expect((captured.first as Map<String, dynamic>)['id'], 'atelier-id');
    });
  });
}
