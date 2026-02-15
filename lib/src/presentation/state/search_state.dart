import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/services/search_service.dart';

/// Cle de stockage pour l'historique des recherches recentes.
const String _kHistoriqueKey = 'search_history';

/// Nombre maximum d'elements dans l'historique.
const int _kMaxHistorique = 10;

/// State management pour la recherche universelle.
/// Gere la recherche en temps reel, les filtres et l'historique.
class SearchState extends ChangeNotifier {
  final SearchService _searchService;
  final SharedPreferences _prefs;

  SearchState({
    required SearchService searchService,
    required SharedPreferences prefs,
  })  : _searchService = searchService,
        _prefs = prefs {
    _chargerHistorique();
  }

  List<SearchResult> _resultats = [];
  List<SearchResult> get resultats => _resultats;

  SearchCategory _categorieActive = SearchCategory.tous;
  SearchCategory get categorieActive => _categorieActive;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _query = '';
  String get query => _query;

  List<String> _historique = [];
  List<String> get historique => _historique;

  Timer? _debounceTimer;

  /// Effectue une recherche avec debounce pour les suggestions en temps reel.
  void rechercher(String query) {
    _query = query;
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _resultats = [];
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executerRecherche(query);
    });
  }

  /// Execute la recherche effective via le service.
  Future<void> _executerRecherche(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _resultats = await _searchService.rechercher(
        query,
        categorie: _categorieActive,
      );
    } catch (e) {
      _resultats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change la categorie de filtre active et relance la recherche.
  void setCategorie(SearchCategory categorie) {
    _categorieActive = categorie;
    if (_query.isNotEmpty) {
      _executerRecherche(_query);
    }
    notifyListeners();
  }

  /// Ajoute une requete a l'historique des recherches recentes.
  void ajouterAHistorique(String query) {
    if (query.trim().isEmpty) return;

    _historique.remove(query);
    _historique.insert(0, query);

    if (_historique.length > _kMaxHistorique) {
      _historique = _historique.sublist(0, _kMaxHistorique);
    }

    _sauvegarderHistorique();
    notifyListeners();
  }

  /// Supprime un element de l'historique.
  void supprimerDeHistorique(String query) {
    _historique.remove(query);
    _sauvegarderHistorique();
    notifyListeners();
  }

  /// Vide l'historique complet.
  void viderHistorique() {
    _historique.clear();
    _sauvegarderHistorique();
    notifyListeners();
  }

  /// Reinitialise la recherche.
  void reinitialiser() {
    _query = '';
    _resultats = [];
    _categorieActive = SearchCategory.tous;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  /// Charge l'historique depuis le stockage local.
  void _chargerHistorique() {
    final data = _prefs.getString(_kHistoriqueKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _historique = decoded.cast<String>();
    }
  }

  /// Sauvegarde l'historique dans le stockage local.
  void _sauvegarderHistorique() {
    _prefs.setString(_kHistoriqueKey, jsonEncode(_historique));
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
