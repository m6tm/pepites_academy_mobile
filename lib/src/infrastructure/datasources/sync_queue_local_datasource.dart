import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/sync_operation.dart';

/// Source de donnees locale pour la file d'attente de synchronisation.
/// Utilise SQLite via sqflite pour une persistance robuste des operations
/// en attente, meme en cas de fermeture brutale de l'application.
class SyncQueueLocalDatasource {
  static const String _dbName = 'pepites_sync_queue.db';
  static const String _tableName = 'sync_operations';
  static const int _dbVersion = 1;

  Database? _database;

  /// Retourne l'instance de la base de donnees, en la creant si necessaire.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        operationType TEXT NOT NULL,
        payload TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        lastAttemptAt TEXT,
        retryCount INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending',
        errorMessage TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_status ON $_tableName (status)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_created ON $_tableName (createdAt)
    ''');
  }

  /// Ajoute une operation a la file d'attente.
  Future<void> insert(SyncOperation operation) async {
    final db = await database;
    await db.insert(
      _tableName,
      operation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Recupere toutes les operations en attente, triees par date de creation.
  Future<List<SyncOperation>> getPending() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [SyncOperationStatus.pending.name],
      orderBy: 'createdAt ASC',
    );
    return maps.map((m) => SyncOperation.fromMap(m)).toList();
  }

  /// Met a jour le statut d'une operation.
  Future<void> updateStatus(
    String operationId,
    SyncOperationStatus status, {
    String? errorMessage,
  }) async {
    final db = await database;
    final values = <String, dynamic>{
      'status': status.name,
      'lastAttemptAt': DateTime.now().toIso8601String(),
    };
    if (errorMessage != null) {
      values['errorMessage'] = errorMessage;
    }
    await db.update(
      _tableName,
      values,
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  /// Incremente le compteur de tentatives.
  Future<void> incrementRetryCount(String operationId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $_tableName SET retryCount = retryCount + 1, '
      'lastAttemptAt = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), operationId],
    );
  }

  /// Supprime une operation de la file.
  Future<void> delete(String operationId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  /// Recupere le nombre d'operations en attente.
  Future<int> getPendingCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE status = ?',
      [SyncOperationStatus.pending.name],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Supprime toutes les operations terminees.
  Future<void> clearCompleted() async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'status = ?',
      whereArgs: [SyncOperationStatus.completed.name],
    );
  }

  /// Supprime toutes les operations.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Ferme la base de donnees.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
