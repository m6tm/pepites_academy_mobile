import '../../domain/entities/bulletin.dart';
import '../../infrastructure/network/api_endpoints.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/repositories/bulletin_repository_impl.dart';
import 'activity_service.dart';

/// Service applicatif gerant la logique metier des bulletins de formation.
/// 
/// Le calcul des bulletins est desormais effectue cote backend. Ce service
/// ne fait qu'orchestrer les appels API et la persistance locale.
class BulletinService {
  final BulletinRepositoryImpl _bulletinRepository;
  final DioClient _dioClient;
  ActivityService? _activityService;

  BulletinService({
    required BulletinRepositoryImpl bulletinRepository,
    required DioClient dioClient,
  })  : _bulletinRepository = bulletinRepository,
        _dioClient = dioClient;

  /// Injecte le service d'activites.
  void setActivityService(ActivityService service) {
    _activityService = service;
  }

  /// Genere un bulletin via l'API backend.
  /// Le backend calcule automatiquement les competences depuis les annotations.
  Future<Bulletin> genererBulletin({
    required String academicienId,
    required String encadreurId,
    required PeriodeType typePeriode,
    required DateTime dateReference,
    String observationsGenerales = '',
  }) async {
    final response = await _dioClient.post<dynamic>(
      ApiEndpoints.bulletins,
      data: {
        'academicien_id': academicienId,
        'encadreur_id': encadreurId,
        'type_periode': typePeriode.name,
        'date_reference': dateReference.toIso8601String().split('T').first,
        'observations_generales': observationsGenerales,
      },
    );

    return response.fold(
      (failure) => throw Exception(
        'Erreur lors de la generation du bulletin: ${failure.message}',
      ),
      (data) {
        final map = data as Map<String, dynamic>;
        final bulletinMap = map['bulletin'] as Map<String, dynamic>;
        final bulletin = _parseBulletinFromApi(bulletinMap);
        
        // Persister localement sans re-synchroniser
        _bulletinRepository.saveLocal(bulletin);
        
        // Enregistrer l'activite
        _activityService?.enregistrerBulletinGenere(
          bulletin.periodeLabel,
          academicienId,
          bulletin.id,
        );
        
        return bulletin;
      },
    );
  }

  /// Recupere les bulletins d'un academicien depuis le backend.
  Future<List<Bulletin>> getBulletinsAcademicien(String academicienId) async {
    final response = await _dioClient.get<dynamic>(
      '${ApiEndpoints.bulletins}?academicien_id=$academicienId',
    );

    return response.fold(
      (failure) async {
        // Fallback sur le cache local
        return _bulletinRepository.getByAcademicien(academicienId);
      },
      (data) {
        final list = data as List<dynamic>;
        final bulletins = list
            .whereType<Map<String, dynamic>>()
            .map(_parseBulletinFromApi)
            .toList();
        
        // Synchroniser le cache local
        for (final b in bulletins) {
          _bulletinRepository.saveLocal(b);
        }
        
        return bulletins;
      },
    );
  }

  /// Recupere un bulletin par son ID.
  Future<Bulletin?> getBulletinById(String id) async {
    // Essayer d'abord le cache local
    final local = await _bulletinRepository.getById(id);
    if (local != null) return local;

    final response = await _dioClient.get<dynamic>(
      '${ApiEndpoints.bulletins}/$id',
    );

    return response.fold(
      (failure) => null,
      (data) {
        final map = data as Map<String, dynamic>;
        final bulletin = _parseBulletinFromApi(map);
        _bulletinRepository.saveLocal(bulletin);
        return bulletin;
      },
    );
  }

  /// Met a jour les observations generales d'un bulletin.
  Future<Bulletin> mettreAJourObservations(
    String bulletinId,
    String observations,
  ) async {
    final response = await _dioClient.put<dynamic>(
      '${ApiEndpoints.bulletins}/$bulletinId',
      data: {
        'observations_generales': observations,
      },
    );

    return response.fold(
      (failure) => throw Exception(
        'Erreur lors de la mise a jour du bulletin',
      ),
      (data) {
        final map = data as Map<String, dynamic>;
        final bulletin = _parseBulletinFromApi(map);
        _bulletinRepository.update(bulletin);
        return bulletin;
      },
    );
  }

  /// Supprime un bulletin.
  Future<void> supprimerBulletin(String id) async {
    final response = await _dioClient.delete<dynamic>(
      '${ApiEndpoints.bulletins}/$id',
    );

    return response.fold(
      (failure) => throw Exception(
        'Erreur lors de la suppression du bulletin',
      ),
      (_) async {
        await _bulletinRepository.delete(id);
      },
    );
  }

  /// Parse un bulletin depuis le format API.
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
      detailsAteliers: _parseDetailsAteliers(
        map['details_ateliers'] as List<dynamic>?,
      ),
    );
  }

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

  List<DetailAtelierBulletin> _parseDetailsAteliers(List<dynamic>? list) {
    if (list == null) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (map) => DetailAtelierBulletin(
            atelierId: (map['atelier_id'] as String?) ??
                (map['atelierId'] as String?) ??
                '',
            atelierNom: (map['atelier_nom'] as String?) ??
                (map['atelierNom'] as String?) ??
                '',
            scoreMoyen: (map['score_moyen'] as num?)?.toDouble() ??
                (map['scoreMoyen'] as num?)?.toDouble() ??
                0,
            nbAnnotations: (map['nb_annotations'] as int?) ??
                (map['nbAnnotations'] as int?) ??
                0,
            exercices: _parseDetailsExercices(
              map['exercices'] as List<dynamic>?,
            ),
          ),
        )
        .toList();
  }

  List<DetailExerciceBulletin> _parseDetailsExercices(List<dynamic>? list) {
    if (list == null) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (map) => DetailExerciceBulletin(
            exerciceId: (map['exercice_id'] as String?) ??
                (map['exerciceId'] as String?) ??
                '',
            exerciceNom: (map['exercice_nom'] as String?) ??
                (map['exerciceNom'] as String?) ??
                '',
            scoreMoyen: (map['score_moyen'] as num?)?.toDouble() ??
                (map['scoreMoyen'] as num?)?.toDouble() ??
                0,
            nbAnnotations: (map['nb_annotations'] as int?) ??
                (map['nbAnnotations'] as int?) ??
                0,
          ),
        )
        .toList();
  }
}
