import '../../domain/entities/academicien.dart';
import '../../domain/entities/encadreur.dart';
import '../../domain/entities/seance.dart';
import '../../domain/repositories/academicien_repository.dart';
import '../../domain/repositories/encadreur_repository.dart';
import '../../domain/repositories/seance_repository.dart';

/// Categories de recherche disponibles.
enum SearchCategory { tous, academiciens, encadreurs, seances }

/// Represente un resultat de recherche unifie.
class SearchResult {
  final String id;
  final String titre;
  final String sousTitre;
  final SearchCategory categorie;
  final dynamic entite;

  const SearchResult({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.categorie,
    required this.entite,
  });
}

/// Service de recherche universelle.
/// Permet de rechercher simultanement dans les academiciens, encadreurs et seances.
class SearchService {
  final AcademicienRepository _academicienRepository;
  final EncadreurRepository _encadreurRepository;
  final SeanceRepository _seanceRepository;

  SearchService({
    required AcademicienRepository academicienRepository,
    required EncadreurRepository encadreurRepository,
    required SeanceRepository seanceRepository,
  })  : _academicienRepository = academicienRepository,
        _encadreurRepository = encadreurRepository,
        _seanceRepository = seanceRepository;

  /// Recherche globale dans toutes les categories.
  Future<List<SearchResult>> rechercher(
    String query, {
    SearchCategory categorie = SearchCategory.tous,
  }) async {
    if (query.trim().isEmpty) return [];

    final resultats = <SearchResult>[];
    final queryLower = query.toLowerCase().trim();

    if (categorie == SearchCategory.tous ||
        categorie == SearchCategory.academiciens) {
      final academiciens = await _rechercherAcademiciens(queryLower);
      resultats.addAll(academiciens);
    }

    if (categorie == SearchCategory.tous ||
        categorie == SearchCategory.encadreurs) {
      final encadreurs = await _rechercherEncadreurs(queryLower);
      resultats.addAll(encadreurs);
    }

    if (categorie == SearchCategory.tous ||
        categorie == SearchCategory.seances) {
      final seances = await _rechercherSeances(queryLower);
      resultats.addAll(seances);
    }

    return resultats;
  }

  /// Recherche dans les academiciens par nom ou prenom.
  Future<List<SearchResult>> _rechercherAcademiciens(String query) async {
    final academiciens = await _academicienRepository.search(query);
    return academiciens
        .map(
          (a) => SearchResult(
            id: a.id,
            titre: '${a.prenom} ${a.nom}',
            sousTitre: 'Academicien',
            categorie: SearchCategory.academiciens,
            entite: a,
          ),
        )
        .toList();
  }

  /// Recherche dans les encadreurs par nom ou prenom.
  Future<List<SearchResult>> _rechercherEncadreurs(String query) async {
    final encadreurs = await _encadreurRepository.search(query);
    return encadreurs
        .map(
          (e) => SearchResult(
            id: e.id,
            titre: '${e.prenom} ${e.nom}',
            sousTitre: 'Encadreur - ${e.specialite}',
            categorie: SearchCategory.encadreurs,
            entite: e,
          ),
        )
        .toList();
  }

  /// Recherche dans les seances par titre ou date.
  Future<List<SearchResult>> _rechercherSeances(String query) async {
    final toutes = await _seanceRepository.getAll();
    return toutes
        .where(
          (s) =>
              s.titre.toLowerCase().contains(query) ||
              s.dateFormatee.toLowerCase().contains(query),
        )
        .map(
          (s) => SearchResult(
            id: s.id,
            titre: s.titre,
            sousTitre: '${s.dateFormatee} - ${s.dureeFormatee}',
            categorie: SearchCategory.seances,
            entite: s,
          ),
        )
        .toList();
  }

  /// Recupere un academicien par son identifiant.
  Future<Academicien?> getAcademicienById(String id) {
    return _academicienRepository.getById(id);
  }

  /// Recupere un encadreur par son identifiant.
  Future<Encadreur?> getEncadreurById(String id) {
    return _encadreurRepository.getById(id);
  }

  /// Recupere une seance par son identifiant.
  Future<Seance?> getSeanceById(String id) {
    return _seanceRepository.getById(id);
  }
}
