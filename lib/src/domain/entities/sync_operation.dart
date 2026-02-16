/// Types d'operations pouvant etre mises en file d'attente de synchronisation.
enum SyncOperationType {
  create,
  update,
  delete,
}

/// Types d'entites concernees par la synchronisation.
enum SyncEntityType {
  annotation,
  presence,
  atelier,
  seance,
}

/// Statuts possibles d'une operation de synchronisation.
enum SyncOperationStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// Represente une operation en attente de synchronisation vers le backend.
/// Chaque modification locale (creation, mise a jour, suppression) genere
/// une entree dans la file d'attente qui sera envoyee au serveur
/// des que la connexion sera retablie.
class SyncOperation {
  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operationType;
  final String payload;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final int retryCount;
  final SyncOperationStatus status;
  final String? errorMessage;

  SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    required this.createdAt,
    this.lastAttemptAt,
    this.retryCount = 0,
    this.status = SyncOperationStatus.pending,
    this.errorMessage,
  });

  /// Cree une copie de l'operation avec des champs modifies.
  SyncOperation copyWith({
    String? id,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperationType? operationType,
    String? payload,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    int? retryCount,
    SyncOperationStatus? status,
    String? errorMessage,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Serialise l'operation en Map pour stockage SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityType': entityType.name,
      'entityId': entityId,
      'operationType': operationType.name,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'retryCount': retryCount,
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  /// Deserialise une operation depuis un Map SQLite.
  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'] as String,
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == map['entityType'],
      ),
      entityId: map['entityId'] as String,
      operationType: SyncOperationType.values.firstWhere(
        (e) => e.name == map['operationType'],
      ),
      payload: map['payload'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastAttemptAt: map['lastAttemptAt'] != null
          ? DateTime.parse(map['lastAttemptAt'] as String)
          : null,
      retryCount: map['retryCount'] as int? ?? 0,
      status: SyncOperationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SyncOperationStatus.pending,
      ),
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
