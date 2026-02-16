import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/poste_football.dart';

/// Source de donnees locale pour les postes de football.
/// Utilise SharedPreferences pour persister les donnees en JSON.
/// Pre-remplit les postes par defaut lors du premier acces.
class PosteFootballLocalDatasource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'postes_football_data';
  static const String _initializedKey = 'postes_football_initialized';

  PosteFootballLocalDatasource(this._prefs);

  /// Postes par defaut pre-remplis a la premiere installation.
  static List<PosteFootball> get defaultPostes => [
    PosteFootball(id: '1', nom: 'Gardien', description: 'Dernier rempart de l\'equipe'),
    PosteFootball(id: '2', nom: 'Defenseur central', description: 'Pilier de la defense'),
    PosteFootball(id: '3', nom: 'Lateral droit', description: 'Defenseur sur le flanc droit'),
    PosteFootball(id: '4', nom: 'Lateral gauche', description: 'Defenseur sur le flanc gauche'),
    PosteFootball(id: '5', nom: 'Milieu defensif', description: 'Sentinelle devant la defense'),
    PosteFootball(id: '6', nom: 'Milieu offensif', description: 'Meneur de jeu'),
    PosteFootball(id: '7', nom: 'Ailier droit', description: 'Attaquant sur le flanc droit'),
    PosteFootball(id: '8', nom: 'Ailier gauche', description: 'Attaquant sur le flanc gauche'),
    PosteFootball(id: '9', nom: 'Avant-centre', description: 'Buteur principal'),
    PosteFootball(id: '10', nom: 'Piston', description: 'Lateral offensif polyvalent'),
  ];

  /// Initialise les postes par defaut si c'est le premier lancement.
  Future<void> ensureInitialized() async {
    final initialized = _prefs.getBool(_initializedKey) ?? false;
    if (!initialized) {
      await saveAll(defaultPostes);
      await _prefs.setBool(_initializedKey, true);
    }
  }

  /// Recupere tous les postes stockes localement.
  List<PosteFootball> getAll() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => PosteFootball.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarde la liste complete des postes.
  Future<void> saveAll(List<PosteFootball> postes) async {
    final jsonString = json.encode(
      postes.map((e) => e.toJson()).toList(),
    );
    await _prefs.setString(_storageKey, jsonString);
  }

  /// Ajoute un poste a la liste existante.
  Future<PosteFootball> add(PosteFootball poste) async {
    final list = getAll();
    list.add(poste);
    await saveAll(list);
    return poste;
  }

  /// Met a jour un poste existant.
  Future<PosteFootball> update(PosteFootball poste) async {
    final list = getAll();
    final index = list.indexWhere((e) => e.id == poste.id);
    if (index == -1) {
      throw Exception('Poste non trouve : ${poste.id}');
    }
    list[index] = poste;
    await saveAll(list);
    return poste;
  }

  /// Supprime un poste par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  /// Recupere un poste par son identifiant.
  PosteFootball? getById(String id) {
    final list = getAll();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
