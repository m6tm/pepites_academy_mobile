import '../../../l10n/app_localizations.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/entities/bulletin.dart';
import '../../infrastructure/repositories/annotation_repository_impl.dart';
import '../../infrastructure/repositories/bulletin_repository_impl.dart';
import '../../infrastructure/repositories/seance_repository_impl.dart';
import 'activity_service.dart';

/// Service applicatif gerant la logique metier des bulletins de formation.
/// Agrege les annotations sur une periode pour produire un bilan
/// synthetique des competences d'un academicien.
class BulletinService {
  final BulletinRepositoryImpl _bulletinRepository;
  final AnnotationRepositoryImpl _annotationRepository;
  final SeanceRepositoryImpl _seanceRepository;
  ActivityService? _activityService;
  AppLocalizations? _l10n;

  BulletinService({
    required BulletinRepositoryImpl bulletinRepository,
    required AnnotationRepositoryImpl annotationRepository,
    required SeanceRepositoryImpl seanceRepository,
  }) : _bulletinRepository = bulletinRepository,
       _annotationRepository = annotationRepository,
       _seanceRepository = seanceRepository;

  /// Injecte le service d'activites.
  void setActivityService(ActivityService service) {
    _activityService = service;
  }

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Genere un bulletin pour un academicien sur une periode donnee.
  /// Agrege les annotations et calcule les competences moyennes.
  Future<Bulletin> genererBulletin({
    required String academicienId,
    required String encadreurId,
    required PeriodeType typePeriode,
    required DateTime dateDebut,
    required DateTime dateFin,
    String observationsGenerales = '',
  }) async {
    final annotations = await _annotationRepository.getByAcademicien(
      academicienId,
    );

    final annotationsPeriode = annotations.where((a) {
      return !a.horodate.isBefore(dateDebut) && !a.horodate.isAfter(dateFin);
    }).toList();

    final seances = await _seanceRepository.getAll();
    final seancesPeriode = seances.where((s) {
      return !s.date.isBefore(dateDebut) && !s.date.isAfter(dateFin);
    }).toList();

    final seancesPresent = seancesPeriode
        .where((s) => s.academicienIds.contains(academicienId))
        .length;

    final competences = _calculerCompetences(annotationsPeriode);
    final appreciations = _genererAppreciations(annotationsPeriode);

    final bulletin = Bulletin(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateDebutPeriode: dateDebut,
      dateFinPeriode: dateFin,
      typePeriode: typePeriode,
      academicienId: academicienId,
      encadreurId: encadreurId,
      observationsGenerales: observationsGenerales,
      competences: competences,
      appreciations: appreciations,
      nbSeancesTotal: seancesPeriode.length,
      nbSeancesPresent: seancesPresent,
      nbAnnotationsTotal: annotationsPeriode.length,
      dateGeneration: DateTime.now(),
    );

    final created = await _bulletinRepository.create(bulletin);
    await _activityService?.enregistrerBulletinGenere(
      created.periodeLabel,
      academicienId,
      created.id,
    );
    return created;
  }

  /// Calcule les competences moyennes a partir des annotations.
  /// Mappe les tags des annotations aux domaines de competences.
  Competences _calculerCompetences(List<Annotation> annotations) {
    if (annotations.isEmpty) return const Competences();

    double technique = 0, physique = 0, tactique = 0, mental = 0, esprit = 0;
    int cTech = 0, cPhys = 0, cTact = 0, cMent = 0, cEspr = 0;

    for (final annotation in annotations) {
      final note = annotation.note ?? 5.0;
      for (final tag in annotation.tags) {
        final tagLower = tag.toLowerCase();
        if (_estTagTechnique(tagLower)) {
          technique += note;
          cTech++;
        } else if (_estTagPhysique(tagLower)) {
          physique += note;
          cPhys++;
        } else if (_estTagTactique(tagLower)) {
          tactique += note;
          cTact++;
        } else if (_estTagMental(tagLower)) {
          mental += note;
          cMent++;
        } else if (_estTagEspritEquipe(tagLower)) {
          esprit += note;
          cEspr++;
        }
      }

      if (annotation.tags.isEmpty && annotation.note != null) {
        technique += note;
        cTech++;
      }
    }

    return Competences(
      technique: cTech > 0 ? (technique / cTech).clamp(0, 10) : 0,
      physique: cPhys > 0 ? (physique / cPhys).clamp(0, 10) : 0,
      tactique: cTact > 0 ? (tactique / cTact).clamp(0, 10) : 0,
      mental: cMent > 0 ? (mental / cMent).clamp(0, 10) : 0,
      espritEquipe: cEspr > 0 ? (esprit / cEspr).clamp(0, 10) : 0,
    );
  }

  bool _estTagTechnique(String tag) {
    return tag.contains('technique') ||
        tag.contains('dribble') ||
        tag.contains('passe') ||
        tag.contains('finition') ||
        tag.contains('controle') ||
        tag.contains('tir');
  }

  bool _estTagPhysique(String tag) {
    return tag.contains('physique') ||
        tag.contains('vitesse') ||
        tag.contains('endurance') ||
        tag.contains('force') ||
        tag.contains('agilite');
  }

  bool _estTagTactique(String tag) {
    return tag.contains('tactique') ||
        tag.contains('placement') ||
        tag.contains('vision') ||
        tag.contains('strategie') ||
        tag.contains('jeu');
  }

  bool _estTagMental(String tag) {
    return tag.contains('mental') ||
        tag.contains('concentration') ||
        tag.contains('motivation') ||
        tag.contains('discipline') ||
        tag.contains('attitude');
  }

  bool _estTagEspritEquipe(String tag) {
    return tag.contains('equipe') ||
        tag.contains('collectif') ||
        tag.contains('communication') ||
        tag.contains('solidarite') ||
        tag.contains('leadership');
  }

  /// Genere les appreciations par domaine a partir des annotations.
  List<AppreciationDomaine> _genererAppreciations(
    List<Annotation> annotations,
  ) {
    final domaines = <String, List<Annotation>>{};

    for (final annotation in annotations) {
      for (final tag in annotation.tags) {
        final domaine = _tagVersDomaine(tag.toLowerCase());
        domaines.putIfAbsent(domaine, () => []).add(annotation);
      }
    }

    return domaines.entries.map((entry) {
      final notes = entry.value
          .where((a) => a.note != null)
          .map((a) => a.note!)
          .toList();
      final moyenne = notes.isNotEmpty
          ? notes.reduce((a, b) => a + b) / notes.length
          : 0.0;

      return AppreciationDomaine(
        domaine: entry.key,
        note: double.parse(moyenne.toStringAsFixed(1)),
        commentaire: _resumeAnnotations(entry.value),
      );
    }).toList();
  }

  String _tagVersDomaine(String tag) {
    if (_estTagTechnique(tag)) return _l10n?.domaineTechnique ?? 'Technique';
    if (_estTagPhysique(tag)) return _l10n?.domainePhysique ?? 'Physique';
    if (_estTagTactique(tag)) return _l10n?.domaineTactique ?? 'Tactique';
    if (_estTagMental(tag)) return _l10n?.domaineMental ?? 'Mental';
    if (_estTagEspritEquipe(tag)) {
      return _l10n?.domaineEspritEquipe ?? 'Esprit d\'equipe';
    }
    return _l10n?.domaineGeneral ?? 'General';
  }

  String _resumeAnnotations(List<Annotation> annotations) {
    if (annotations.isEmpty) return '';
    final derniere = annotations.first;
    if (annotations.length == 1) return derniere.contenu;
    return _l10n?.bulletinObservationsResume(
          annotations.length,
          derniere.contenu,
        ) ??
        '${annotations.length} observations. Derniere : ${derniere.contenu}';
  }

  /// Recupere les bulletins d'un academicien.
  Future<List<Bulletin>> getBulletinsAcademicien(String academicienId) async {
    return _bulletinRepository.getByAcademicien(academicienId);
  }

  /// Recupere un bulletin par son identifiant.
  Future<Bulletin?> getBulletinById(String id) async {
    return _bulletinRepository.getById(id);
  }

  /// Met a jour les observations generales d'un bulletin.
  Future<Bulletin> mettreAJourObservations(
    String bulletinId,
    String observations,
  ) async {
    final bulletin = await _bulletinRepository.getById(bulletinId);
    if (bulletin == null) {
      throw Exception(
        _l10n?.serviceBulletinNotFound(bulletinId) ??
            'Bulletin introuvable : $bulletinId',
      );
    }
    return _bulletinRepository.update(
      bulletin.copyWith(observationsGenerales: observations),
    );
  }

  /// Supprime un bulletin.
  Future<void> supprimerBulletin(String id) async {
    return _bulletinRepository.delete(id);
  }

  /// Calcule les dates de debut et fin pour un type de periode donne.
  static ({DateTime debut, DateTime fin}) calculerDatesPeriode(
    PeriodeType type, {
    DateTime? reference,
  }) {
    final ref = reference ?? DateTime.now();
    switch (type) {
      case PeriodeType.mois:
        final debut = DateTime(ref.year, ref.month, 1);
        final fin = DateTime(ref.year, ref.month + 1, 0, 23, 59, 59);
        return (debut: debut, fin: fin);
      case PeriodeType.trimestre:
        final trimestreDebut = ((ref.month - 1) ~/ 3) * 3 + 1;
        final debut = DateTime(ref.year, trimestreDebut, 1);
        final fin = DateTime(ref.year, trimestreDebut + 3, 0, 23, 59, 59);
        return (debut: debut, fin: fin);
      case PeriodeType.saison:
        final anneeDebut = ref.month >= 9 ? ref.year : ref.year - 1;
        final debut = DateTime(anneeDebut, 9, 1);
        final fin = DateTime(anneeDebut + 1, 6, 30, 23, 59, 59);
        return (debut: debut, fin: fin);
    }
  }
}
