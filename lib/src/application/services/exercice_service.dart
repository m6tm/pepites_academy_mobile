import 'dart:async';
import '../../../l10n/app_localizations.dart';
import '../../domain/entities/exercice.dart';
import '../../domain/repositories/exercice_repository.dart';
import '../../domain/repositories/atelier_repository.dart';
import '../../domain/repositories/seance_repository.dart';

/// Service applicatif gerant la logique metier des exercices.
class ExerciceService {
  final ExerciceRepository _exerciceRepository;
  final AtelierRepository _atelierRepository;
  final SeanceRepository _seanceRepository;
  AppLocalizations? _l10n;

  // Controllers pour la reactivite UI
  final _exercicesController = StreamController<List<Exercice>>.broadcast();

  ExerciceService({
    required ExerciceRepository exerciceRepository,
    required AtelierRepository atelierRepository,
    required SeanceRepository seanceRepository,
  }) : _exerciceRepository = exerciceRepository,
       _atelierRepository = atelierRepository,
       _seanceRepository = seanceRepository;

  /// Flux de donnees pour les exercices.
  Stream<List<Exercice>> get exercicesStream => _exercicesController.stream;

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Recupere tous les exercices d'un atelier.
  Future<List<Exercice>> getExercicesParAtelier(String atelierId) async {
    final exercices = await _exerciceRepository.getByAtelierId(atelierId);
    exercices.sort((a, b) => a.ordre.compareTo(b.ordre));
    _exercicesController.add(exercices);
    return exercices;
  }

  /// Force le rafraichissement des exercices pour un atelier.
  Future<void> refreshExercices(String atelierId) async {
    await getExercicesParAtelier(atelierId);
  }

  /// Recupere un exercice par son ID.
  Future<Exercice?> getExerciceById(String id) async {
    return _exerciceRepository.getById(id);
  }

  /// Cree un nouvel exercice dans un atelier.
  Future<Exercice> ajouterExercice({
    required String atelierId,
    required String nom,
    String description = '',
    ExerciceStatut statut = ExerciceStatut.cree,
  }) async {
    final atelier = await _atelierRepository.getById(atelierId);
    if (atelier == null) {
      throw Exception(
        _l10n?.serviceExerciceAtelierNotFound(atelierId) ??
            'Atelier introuvable : $atelierId',
      );
    }

    final exercicesExistants = await _exerciceRepository.getByAtelierId(atelierId);
    final ordre = exercicesExistants.length;

    final exercice = Exercice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: nom,
      description: description,
      ordre: ordre,
      statut: statut,
      atelierId: atelierId,
    );

    final created = await _exerciceRepository.create(exercice);
    await refreshExercices(atelierId);
    return created;
  }

  /// Met a jour un exercice existant.
  Future<Exercice> modifierExercice(Exercice exercice) async {
    final updated = await _exerciceRepository.update(exercice);
    await refreshExercices(exercice.atelierId);
    return updated;
  }

  /// Applique un exercice (statut 'valide' -> 'applique').
  Future<Exercice> appliquerExercice(String exerciceId) async {
    final exercice = await _exerciceRepository.getById(exerciceId);
    if (exercice == null) {
      throw Exception(
        _l10n?.serviceExerciceNotFound(exerciceId) ??
            'Exercice introuvable : $exerciceId',
      );
    }

    if (exercice.statut != ExerciceStatut.valide) {
      throw Exception(
        _l10n?.serviceExerciceOnlyValidatedCanApply ??
            'Seul un exercice validé peut être appliqué.',
      );
    }

    final atelier = await _atelierRepository.getById(exercice.atelierId);
    if (atelier == null) {
      throw Exception(
        _l10n?.serviceExerciceAtelierNotFound(exercice.atelierId) ??
            'Atelier introuvable : ${exercice.atelierId}',
      );
    }

    final seance = await _seanceRepository.getById(atelier.seanceId);
    if (seance == null || !seance.estOuverte) {
      throw Exception(
        _l10n?.serviceExerciceOnlyInOpenSeance ??
            'L\'application d\'un exercice ne peut se faire que sur une séance ouverte.',
      );
    }
    
    final updated = exercice.copyWith(statut: ExerciceStatut.applique);
    return modifierExercice(updated);
  }

  /// Supprime un exercice d'un atelier.
  Future<void> supprimerExercice(String exerciceId) async {
    final exercice = await _exerciceRepository.getById(exerciceId);
    if (exercice == null) {
      throw Exception(
        _l10n?.serviceExerciceNotFound(exerciceId) ??
            'Exercice introuvable : $exerciceId',
      );
    }

    final atelierId = exercice.atelierId;
    await _exerciceRepository.delete(exerciceId);

    // Recalculer les ordres
    final restants = await _exerciceRepository.getByAtelierId(atelierId);
    final ids = restants.map((e) => e.id).toList();
    if (ids.isNotEmpty) {
      await _exerciceRepository.reorder(atelierId, ids);
    }

    await refreshExercices(atelierId);
  }

  /// Reordonne les exercices d'un atelier.
  Future<void> reorderExercices(String atelierId, List<String> exerciceIds) async {
    await _exerciceRepository.reorder(atelierId, exerciceIds);
    await refreshExercices(atelierId);
  }

  /// Libere les ressources.
  void dispose() {
    _exercicesController.close();
  }
}
