/// Strategies de resolution de conflits lors de la synchronisation.
/// Quand une meme donnee a ete modifiee localement et sur le serveur,
/// cette strategie determine quelle version est conservee.
enum ConflictResolutionStrategy {
  /// La derniere ecriture (par horodatage) est prioritaire.
  lastWriteWins,

  /// La version locale est toujours prioritaire.
  localWins,

  /// La version serveur est toujours prioritaire.
  serverWins,

  /// L'utilisateur est alerte et choisit manuellement.
  manual,
}

/// Represente un conflit detecte lors de la synchronisation.
class SyncConflict {
  final String entityId;
  final String entityType;
  final Map<String, dynamic> localVersion;
  final Map<String, dynamic> serverVersion;
  final DateTime localModifiedAt;
  final DateTime serverModifiedAt;

  SyncConflict({
    required this.entityId,
    required this.entityType,
    required this.localVersion,
    required this.serverVersion,
    required this.localModifiedAt,
    required this.serverModifiedAt,
  });
}
