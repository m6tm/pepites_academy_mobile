import 'package:flutter/foundation.dart';
import '../../domain/entities/connectivity_status.dart';
import '../../domain/entities/sync_operation.dart';
import '../../application/services/sync_service.dart';
import 'connectivity_state.dart';

/// State reactif pour la synchronisation hors-ligne.
/// Gere le compteur d'operations en attente et les notifications
/// de synchronisation pour l'interface utilisateur.
class SyncState extends ChangeNotifier {
  final SyncService _syncService;
  final ConnectivityState _connectivityState;

  int _pendingCount = 0;
  SyncCycleResult? _lastSyncResult;
  bool _isSyncing = false;
  String? _lastSyncMessage;

  SyncState({
    required SyncService syncService,
    required ConnectivityState connectivityState,
  })  : _syncService = syncService,
        _connectivityState = connectivityState {
    _init();
  }

  /// Nombre d'operations en attente de synchronisation.
  int get pendingCount => _pendingCount;

  /// Resultat du dernier cycle de synchronisation.
  SyncCycleResult? get lastSyncResult => _lastSyncResult;

  /// Indique si une synchronisation est en cours.
  bool get isSyncing => _isSyncing;

  /// Dernier message de synchronisation pour affichage.
  String? get lastSyncMessage => _lastSyncMessage;

  /// Indique s'il y a des operations en attente.
  bool get hasPendingOperations => _pendingCount > 0;

  void _init() async {
    _pendingCount = await _syncService.getPendingCount();

    _syncService.onPendingCountChanged = (count) {
      _pendingCount = count;
      notifyListeners();
    };

    _syncService.onSyncCompleted = (result) {
      _lastSyncResult = result;
      _isSyncing = false;
      _connectivityState.updateStatus(ConnectivityStatus.connected);

      if (result.successCount > 0) {
        _lastSyncMessage = _buildSyncMessage(result);
      }
      notifyListeners();

      // Efface le message apres 5 secondes.
      Future.delayed(const Duration(seconds: 5), () {
        _lastSyncMessage = null;
        notifyListeners();
      });
    };

    _syncService.startAutoSync();
    notifyListeners();
  }

  /// Lance manuellement une synchronisation.
  Future<void> syncNow() async {
    _isSyncing = true;
    _connectivityState.updateStatus(ConnectivityStatus.syncing);
    notifyListeners();

    await _syncService.syncPendingOperations();
  }

  /// Recupere les operations en attente pour affichage.
  Future<List<SyncOperation>> getPendingOperations() {
    return _syncService.getPendingOperations();
  }

  /// Supprime toutes les operations en attente.
  Future<void> clearAll() async {
    await _syncService.clearAll();
    _pendingCount = 0;
    notifyListeners();
  }

  /// Efface le dernier message de synchronisation.
  void clearLastMessage() {
    _lastSyncMessage = null;
    notifyListeners();
  }

  String _buildSyncMessage(SyncCycleResult result) {
    final buffer = StringBuffer();
    if (result.successCount > 0) {
      buffer.write('${result.successCount} operation');
      if (result.successCount > 1) buffer.write('s');
      buffer.write(' synchronisee');
      if (result.successCount > 1) buffer.write('s');
    }
    if (result.failureCount > 0) {
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write('${result.failureCount} echec');
      if (result.failureCount > 1) buffer.write('s');
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}
