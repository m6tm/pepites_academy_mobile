import 'dart:async';
import '../../../l10n/app_localizations.dart';
import '../../domain/entities/atelier.dart';
import '../../domain/entities/exercice.dart';
import '../../domain/repositories/atelier_repository.dart';
import '../../domain/repositories/seance_repository.dart';
import '../../domain/repositories/exercice_repository.dart';

/// Service applicatif gerant la logique metier des ateliers.
/// Gere la composition, la modification et la reorganisation des ateliers
/// au sein d'une seance d'entrainement.
class AtelierService {
  final AtelierRepository _atelierRepository;
  final SeanceRepository _seanceRepository;
  final ExerciceRepository _exerciceRepository;
  AppLocalizations? _l10n;

  // Controllers pour la reactivite UI
  final _ateliersController = StreamController<List<Atelier>>.broadcast();

  AtelierService({
    required AtelierRepository atelierRepository,
    required SeanceRepository seanceRepository,
    required ExerciceRepository exerciceRepository,
  }) : _atelierRepository = atelierRepository,
       _seanceRepository = seanceRepository,
       _exerciceRepository = exerciceRepository;

  /// Flux de donnees pour les ateliers.
  Stream<List<Atelier>> get ateliersStream => _ateliersController.stream;

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Recupere tous les ateliers d'une seance, tries par ordre.
  Future<List<Atelier>> getAteliersParSeance(String seanceId) async {
    final ateliers = await _atelierRepository.getBySeanceId(seanceId);
    ateliers.sort((a, b) => a.ordre.compareTo(b.ordre));
    _ateliersController.add(ateliers);
    return ateliers;
  }

  /// Force le rafraichissement des donnees depuis le cache/repository.
  Future<void> refreshAteliers(String seanceId) async {
    await getAteliersParSeance(seanceId);
  }

  /// Recupere un atelier par son ID.
  Future<Atelier?> getAtelierById(String id) async {
    return _atelierRepository.getById(id);
  }

  /// Ajoute un atelier a une seance ouverte.
  Future<Atelier> ajouterAtelier({
    required String seanceId,
    required String nom,
    required AtelierType type,
    String? typeCustom,
    String description = '',
    String? icone,
  }) async {
    final seance = await _seanceRepository.getById(seanceId);
    if (seance == null) {
      throw Exception(
        _l10n?.serviceAtelierSeanceNotFound(seanceId) ??
            'Seance introuvable : $seanceId',
      );
    }

    final ateliersExistants = await _atelierRepository.getBySeanceId(seanceId);
    final ordre = ateliersExistants.length;

    final atelier = Atelier(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: nom,
      description: description,
      type: type,
      typeCustom: typeCustom,
      icone: icone,
      ordre: ordre,
      statut: AtelierStatut.valide,
      seanceId: seanceId,
    );

    final created = await _atelierRepository.create(atelier);

    // Mise a jour de la liste des atelierIds dans la seance
    final updatedIds = [...seance.atelierIds, created.id];
    await _seanceRepository.update(
      seance.copyWith(atelierIds: updatedIds, nbAteliers: updatedIds.length),
    );

    await refreshAteliers(seanceId);
    return created;
  }

  /// Met a jour un atelier existant.
  Future<Atelier> modifierAtelier(Atelier atelier) async {
    final updated = await _atelierRepository.update(atelier);
    await refreshAteliers(atelier.seanceId);
    return updated;
  }

  /// Applique un atelier (statut 'valide' -> 'applique').
  Future<Atelier> appliquerAtelier(String atelierId) async {
    final atelier = await _atelierRepository.getById(atelierId);
    if (atelier == null) {
      throw Exception(
        _l10n?.serviceAtelierNotFound(atelierId) ??
            'Atelier introuvable : $atelierId',
      );
    }

    if (atelier.statut != AtelierStatut.valide) {
      throw Exception(
        _l10n?.serviceAtelierOnlyValidatedCanApply ??
            'Seul un atelier validé peut être appliqué.',
      );
    }

    final seance = await _seanceRepository.getById(atelier.seanceId);
    if (seance == null || !seance.estOuverte) {
      throw Exception(
        _l10n?.serviceAtelierOnlyInOpenSeance ??
            'L\'application d\'un atelier ne peut se faire que sur une séance ouverte.',
      );
    }

    final updated = atelier.copyWith(statut: AtelierStatut.applique);
    return modifierAtelier(updated);
  }

  /// Supprime un atelier et met a jour la seance.
  Future<void> supprimerAtelier(String atelierId) async {
    final atelier = await _atelierRepository.getById(atelierId);
    if (atelier == null) {
      throw Exception(
        _l10n?.serviceAtelierNotFound(atelierId) ??
            'Atelier introuvable : $atelierId',
      );
    }

    final seanceId = atelier.seanceId;
    await _atelierRepository.delete(atelierId);

    // Mise a jour de la seance
    final seance = await _seanceRepository.getById(seanceId);
    if (seance != null) {
      final updatedIds = seance.atelierIds
          .where((id) => id != atelierId)
          .toList();
      await _seanceRepository.update(
        seance.copyWith(atelierIds: updatedIds, nbAteliers: updatedIds.length),
      );
    }

    // Recalculer les ordres
    final restants = await _atelierRepository.getBySeanceId(seanceId);
    final ids = restants.map((a) => a.id).toList();
    if (ids.isNotEmpty) {
      await _atelierRepository.reorder(seanceId, ids);
    }

    await refreshAteliers(seanceId);
  }

  /// Reordonne les ateliers d'une seance.
  Future<void> reorderAteliers(String seanceId, List<String> atelierIds) async {
    await _atelierRepository.reorder(seanceId, atelierIds);
    await refreshAteliers(seanceId);
  }

  /// Alias pour compatibilite avec l'ancienne signature si necessaire.
  Future<void> reordonnerAteliers(String seanceId, List<String> atelierIds) =>
      reorderAteliers(seanceId, atelierIds);

  /// Verifie si l'atelier peut etre ferme automatiquement.
  /// Un atelier est ferme automatiquement si tous ses exercices sont fermes.
  Future<bool> checkAutoClose(String atelierId) async {
    final exercices = await _exerciceRepository.getByAtelierId(atelierId);
    if (exercices.isEmpty) return false;

    final tousFermes = exercices.every((e) => e.statut == ExerciceStatut.ferme);
    
    if (tousFermes) {
      final atelier = await _atelierRepository.getById(atelierId);
      if (atelier != null && atelier.statut != AtelierStatut.ferme) {
        await modifierAtelier(atelier.copyWith(statut: AtelierStatut.ferme));
        return true;
      }
    }
    
    return false;
  }

  /// Libere les ressources.
  void dispose() {
    _ateliersController.close();
  }
}
