import '../../../l10n/app_localizations.dart';
import '../../domain/entities/atelier.dart';
import '../../domain/repositories/atelier_repository.dart';
import '../../domain/repositories/seance_repository.dart';

/// Service applicatif gerant la logique metier des ateliers.
/// Gere la composition, la modification et la reorganisation des ateliers
/// au sein d'une seance d'entrainement.
class AtelierService {
  final AtelierRepository _atelierRepository;
  final SeanceRepository _seanceRepository;
  AppLocalizations? _l10n;

  AtelierService({
    required AtelierRepository atelierRepository,
    required SeanceRepository seanceRepository,
  }) : _atelierRepository = atelierRepository,
       _seanceRepository = seanceRepository;

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Recupere tous les ateliers d'une seance, tries par ordre.
  Future<List<Atelier>> getAteliersParSeance(String seanceId) async {
    return _atelierRepository.getBySeance(seanceId);
  }

  /// Ajoute un atelier a une seance ouverte.
  Future<Atelier> ajouterAtelier({
    required String seanceId,
    required String nom,
    required AtelierType type,
    String description = '',
  }) async {
    final seance = await _seanceRepository.getById(seanceId);
    if (seance == null) {
      throw Exception(
        _l10n?.serviceAtelierSeanceNotFound(seanceId) ??
            'Seance introuvable : $seanceId',
      );
    }

    final ateliersExistants = await _atelierRepository.getBySeance(seanceId);
    final ordre = ateliersExistants.length;

    final atelier = Atelier(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: nom,
      description: description,
      type: type,
      ordre: ordre,
      seanceId: seanceId,
    );

    final created = await _atelierRepository.create(atelier);

    // Mise a jour de la liste des atelierIds dans la seance
    final updatedIds = [...seance.atelierIds, created.id];
    await _seanceRepository.update(
      seance.copyWith(atelierIds: updatedIds, nbAteliers: updatedIds.length),
    );

    return created;
  }

  /// Met a jour un atelier existant.
  Future<Atelier> modifierAtelier(Atelier atelier) async {
    return _atelierRepository.update(atelier);
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

    await _atelierRepository.delete(atelierId);

    // Mise a jour de la seance
    final seance = await _seanceRepository.getById(atelier.seanceId);
    if (seance != null) {
      final updatedIds = seance.atelierIds
          .where((id) => id != atelierId)
          .toList();
      await _seanceRepository.update(
        seance.copyWith(atelierIds: updatedIds, nbAteliers: updatedIds.length),
      );
    }

    // Recalculer les ordres
    final restants = await _atelierRepository.getBySeance(atelier.seanceId);
    final ids = restants.map((a) => a.id).toList();
    if (ids.isNotEmpty) {
      await _atelierRepository.reorder(atelier.seanceId, ids);
    }
  }

  /// Reordonne les ateliers d'une seance.
  Future<void> reordonnerAteliers(
    String seanceId,
    List<String> atelierIds,
  ) async {
    await _atelierRepository.reorder(seanceId, atelierIds);
  }
}
