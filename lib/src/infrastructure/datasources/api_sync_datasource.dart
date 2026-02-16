import '../../domain/entities/sync_operation.dart';

/// Resultat d'une tentative de synchronisation vers le backend.
class SyncResult {
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? serverResponse;

  SyncResult({
    required this.success,
    this.errorMessage,
    this.serverResponse,
  });
}

/// Contrat abstrait pour l'envoi des operations vers le backend.
/// Cette classe doit etre implementee lorsque le backend sera disponible.
/// Pour l'instant, une implementation stub est fournie.
abstract class ApiSyncDatasource {
  /// Envoie une operation de synchronisation vers le serveur.
  Future<SyncResult> pushOperation(SyncOperation operation);

  /// Recupere les donnees du serveur pour une entite donnee.
  Future<Map<String, dynamic>?> fetchEntity(
    String entityType,
    String entityId,
  );

  /// Verifie si le serveur est accessible.
  Future<bool> isServerReachable();
}

/// Implementation stub utilisee tant que le backend n'est pas connecte.
/// Toutes les operations reussissent immediatement.
/// Remplacer par l'implementation reelle lors de l'integration backend.
class StubApiSyncDatasource implements ApiSyncDatasource {
  @override
  Future<SyncResult> pushOperation(SyncOperation operation) async {
    // Simule un succes immediat en mode local uniquement.
    return SyncResult(success: true);
  }

  @override
  Future<Map<String, dynamic>?> fetchEntity(
    String entityType,
    String entityId,
  ) async {
    // Pas de serveur disponible, retourne null.
    return null;
  }

  @override
  Future<bool> isServerReachable() async {
    // Pas de serveur configure, retourne toujours false.
    return false;
  }
}
