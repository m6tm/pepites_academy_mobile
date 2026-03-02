import '../../application/services/sync_service.dart';
import '../../domain/entities/bulletin.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/bulletin_repository.dart';
import '../datasources/bulletin_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Implementation locale du repository de bulletins de formation.
/// Delegue les operations au datasource local.
class BulletinRepositoryImpl implements BulletinRepository {
  final BulletinLocalDatasource _datasource;
  SyncService? _syncService;
  DioClient? _dioClient;

  BulletinRepositoryImpl(this._datasource);

  /// Injecte le service de synchronisation.
  void setSyncService(SyncService service) {
    _syncService = service;
  }

  /// Injecte le client HTTP.
  void setDioClient(DioClient client) {
    _dioClient = client;
  }

  @override
  Future<Bulletin> create(Bulletin bulletin) async {
    final created = await _datasource.add(bulletin);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: created.id,
      operationType: SyncOperationType.create,
      data: created.toJson(),
    );
    return created;
  }

  @override
  Future<Bulletin> update(Bulletin bulletin) async {
    final updated = await _datasource.update(bulletin);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: updated.id,
      operationType: SyncOperationType.update,
      data: updated.toJson(),
    );
    return updated;
  }

  @override
  Future<Bulletin?> getById(String id) async {
    return _datasource.getById(id);
  }

  @override
  Future<List<Bulletin>> getByAcademicien(String academicienId) async {
    return _datasource.getByAcademicien(academicienId);
  }

  @override
  Future<List<Bulletin>> getAll() async {
    return _datasource.getAll();
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
    await _syncService?.enqueueOperation(
      entityType: SyncEntityType.bulletin,
      entityId: id,
      operationType: SyncOperationType.delete,
      data: {'id': id},
    );
  }

  /// Synchronise les bulletins depuis le backend.
  /// Fusionne les donnees distantes dans le cache local.
  /// Retourne false si le serveur est inaccessible ou en cas d'erreur.
  Future<bool> syncFromApi() async {
    if (_dioClient == null) return false;

    try {
      final result = await _dioClient!.get<dynamic>(ApiEndpoints.bulletins);

      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[Bulletin] Sync failed: ${failure.message}');
          return false;
        },
        (data) async {
          final List<dynamic> rawList;
          if (data is List) {
            rawList = data;
          } else if (data is Map<String, dynamic>) {
            // Peut etre enveloppe dans un champ 'bulletins' ou 'data'
            rawList = data.values.whereType<List>().expand((e) => e).toList();
          } else {
            return false;
          }

          final remote = rawList
              .whereType<Map<String, dynamic>>()
              .map((map) => _parseBulletinFromApi(map))
              .where((b) => b.id.isNotEmpty)
              .toList();

          await _datasource.upsertAll(remote);
          // ignore: avoid_print
          print('[Bulletin] Synced ${remote.length} items from backend');
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Bulletin] Sync exception: $e');
      return false;
    }
  }

  /// Parse un bulletin depuis le format API (snake_case).
  Bulletin _parseBulletinFromApi(Map<String, dynamic> map) {
    return Bulletin(
      id: map['id'] as String,
      dateDebutPeriode: DateTime.parse(
        (map['date_debut_periode'] as String?) ??
            (map['dateDebutPeriode'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
      dateFinPeriode: DateTime.parse(
        (map['date_fin_periode'] as String?) ??
            (map['dateFinPeriode'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
      typePeriode: _parsePeriodeType(map['type_periode'] as String?),
      academicienId:
          (map['academicien_id'] as String?) ??
          (map['academicienId'] as String?) ??
          '',
      encadreurId:
          (map['encadreur_id'] as String?) ??
          (map['encadreurId'] as String?) ??
          '',
      observationsGenerales:
          (map['observations_generales'] as String?) ??
          (map['observationsGenerales'] as String?) ??
          '',
      competences: _parseCompetences(
        map['competences'] as Map<String, dynamic>?,
      ),
      appreciations: _parseAppreciations(
        map['appreciations'] as List<dynamic>?,
      ),
      nbSeancesTotal:
          (map['nb_seances_total'] as int?) ??
          (map['nbSeancesTotal'] as int?) ??
          0,
      nbSeancesPresent:
          (map['nb_seances_present'] as int?) ??
          (map['nbSeancesPresent'] as int?) ??
          0,
      nbAnnotationsTotal:
          (map['nb_annotations_total'] as int?) ??
          (map['nbAnnotationsTotal'] as int?) ??
          0,
      dateGeneration: DateTime.parse(
        (map['date_generation'] as String?) ??
            (map['dateGeneration'] as String?) ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Parse le type de periode.
  PeriodeType _parsePeriodeType(String? type) {
    switch (type?.toLowerCase()) {
      case 'mois':
        return PeriodeType.mois;
      case 'trimestre':
        return PeriodeType.trimestre;
      case 'saison':
        return PeriodeType.saison;
      default:
        return PeriodeType.mois;
    }
  }

  /// Parse les competences depuis le format API.
  Competences _parseCompetences(Map<String, dynamic>? json) {
    if (json == null) return const Competences();
    return Competences(
      technique:
          (json['technique'] as num?)?.toDouble() ??
          (json['comp_technique'] as num?)?.toDouble() ??
          0,
      physique:
          (json['physique'] as num?)?.toDouble() ??
          (json['comp_physique'] as num?)?.toDouble() ??
          0,
      tactique:
          (json['tactique'] as num?)?.toDouble() ??
          (json['comp_tactique'] as num?)?.toDouble() ??
          0,
      mental:
          (json['mental'] as num?)?.toDouble() ??
          (json['comp_mental'] as num?)?.toDouble() ??
          0,
      espritEquipe:
          (json['espritEquipe'] as num?)?.toDouble() ??
          (json['comp_esprit_equipe'] as num?)?.toDouble() ??
          (json['esprit_equipe'] as num?)?.toDouble() ??
          0,
    );
  }

  /// Parse les appreciations depuis le format API.
  List<AppreciationDomaine> _parseAppreciations(List<dynamic>? list) {
    if (list == null) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (map) => AppreciationDomaine(
            domaine: (map['domaine'] as String?) ?? '',
            note: (map['note'] as num?)?.toDouble() ?? 0,
            commentaire: (map['commentaire'] as String?) ?? '',
          ),
        )
        .toList();
  }
}
