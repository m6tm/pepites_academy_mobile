import '../../domain/entities/poste_football.dart';
import '../../domain/entities/niveau_scolaire.dart';
import '../../domain/repositories/poste_football_repository.dart';
import '../../domain/repositories/niveau_scolaire_repository.dart';

/// Resultat d'une operation sur un referentiel.
class ReferentielResult {
  final bool success;
  final String message;

  const ReferentielResult({required this.success, required this.message});
}

/// Service applicatif gerant la logique metier des referentiels.
/// Centralise les operations CRUD sur les postes de football et niveaux scolaires.
class ReferentielService {
  final PosteFootballRepository _posteRepository;
  final NiveauScolaireRepository _niveauRepository;

  ReferentielService({
    required PosteFootballRepository posteRepository,
    required NiveauScolaireRepository niveauRepository,
  })  : _posteRepository = posteRepository,
        _niveauRepository = niveauRepository;

  // --- Postes de football ---

  /// Recupere tous les postes de football.
  Future<List<PosteFootball>> getAllPostes() async {
    return _posteRepository.getAll();
  }

  /// Cree un nouveau poste de football.
  Future<ReferentielResult> creerPoste({
    required String nom,
    String? description,
  }) async {
    final postes = await _posteRepository.getAll();
    final existe = postes.any(
      (p) => p.nom.toLowerCase() == nom.toLowerCase(),
    );
    if (existe) {
      return const ReferentielResult(
        success: false,
        message: 'Un poste avec ce nom existe deja.',
      );
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final poste = PosteFootball(
      id: id,
      nom: nom,
      description: description,
    );
    await _posteRepository.create(poste);
    return ReferentielResult(
      success: true,
      message: 'Poste "$nom" cree avec succes.',
    );
  }

  /// Met a jour un poste de football existant.
  Future<ReferentielResult> modifierPoste(PosteFootball poste) async {
    final postes = await _posteRepository.getAll();
    final doublon = postes.any(
      (p) => p.id != poste.id && p.nom.toLowerCase() == poste.nom.toLowerCase(),
    );
    if (doublon) {
      return const ReferentielResult(
        success: false,
        message: 'Un autre poste avec ce nom existe deja.',
      );
    }

    await _posteRepository.update(poste);
    return ReferentielResult(
      success: true,
      message: 'Poste "${poste.nom}" modifie avec succes.',
    );
  }

  /// Supprime un poste apres verification des academiciens rattaches.
  Future<ReferentielResult> supprimerPoste(String id) async {
    final count = await _posteRepository.countAcademiciens(id);
    if (count > 0) {
      return ReferentielResult(
        success: false,
        message: 'Impossible de supprimer ce poste : $count academicien(s) rattache(s).',
      );
    }

    await _posteRepository.delete(id);
    return const ReferentielResult(
      success: true,
      message: 'Poste supprime avec succes.',
    );
  }

  // --- Niveaux scolaires ---

  /// Recupere tous les niveaux scolaires tries par ordre.
  Future<List<NiveauScolaire>> getAllNiveaux() async {
    return _niveauRepository.getAll();
  }

  /// Cree un nouveau niveau scolaire.
  Future<ReferentielResult> creerNiveau({
    required String nom,
    required int ordre,
  }) async {
    final niveaux = await _niveauRepository.getAll();
    final existe = niveaux.any(
      (n) => n.nom.toLowerCase() == nom.toLowerCase(),
    );
    if (existe) {
      return const ReferentielResult(
        success: false,
        message: 'Un niveau avec ce nom existe deja.',
      );
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final niveau = NiveauScolaire(id: id, nom: nom, ordre: ordre);
    await _niveauRepository.create(niveau);
    return ReferentielResult(
      success: true,
      message: 'Niveau "$nom" cree avec succes.',
    );
  }

  /// Met a jour un niveau scolaire existant.
  Future<ReferentielResult> modifierNiveau(NiveauScolaire niveau) async {
    final niveaux = await _niveauRepository.getAll();
    final doublon = niveaux.any(
      (n) => n.id != niveau.id && n.nom.toLowerCase() == niveau.nom.toLowerCase(),
    );
    if (doublon) {
      return const ReferentielResult(
        success: false,
        message: 'Un autre niveau avec ce nom existe deja.',
      );
    }

    await _niveauRepository.update(niveau);
    return ReferentielResult(
      success: true,
      message: 'Niveau "${niveau.nom}" modifie avec succes.',
    );
  }

  /// Supprime un niveau apres verification des academiciens rattaches.
  Future<ReferentielResult> supprimerNiveau(String id) async {
    final count = await _niveauRepository.countAcademiciens(id);
    if (count > 0) {
      return ReferentielResult(
        success: false,
        message: 'Impossible de supprimer ce niveau : $count academicien(s) rattache(s).',
      );
    }

    await _niveauRepository.delete(id);
    return const ReferentielResult(
      success: true,
      message: 'Niveau supprime avec succes.',
    );
  }
}
