import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/niveau_scolaire.dart';

/// Source de donnees locale pour les niveaux scolaires.
/// Utilise SharedPreferences pour persister les donnees en JSON.
/// Pre-remplit les niveaux par defaut lors du premier acces.
class NiveauScolaireLocalDatasource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'niveaux_scolaires_data';
  static const String _initializedKey = 'niveaux_scolaires_initialized';

  NiveauScolaireLocalDatasource(this._prefs);

  /// Niveaux par defaut pre-remplis a la premiere installation.
  static List<NiveauScolaire> get defaultNiveaux => [
    NiveauScolaire(id: '1', nom: 'CP', ordre: 1),
    NiveauScolaire(id: '2', nom: 'CE1', ordre: 2),
    NiveauScolaire(id: '3', nom: 'CE2', ordre: 3),
    NiveauScolaire(id: '4', nom: 'CM1', ordre: 4),
    NiveauScolaire(id: '5', nom: 'CM2', ordre: 5),
    NiveauScolaire(id: '6', nom: '6eme', ordre: 6),
    NiveauScolaire(id: '7', nom: '5eme', ordre: 7),
    NiveauScolaire(id: '8', nom: '4eme', ordre: 8),
    NiveauScolaire(id: '9', nom: '3eme', ordre: 9),
    NiveauScolaire(id: '10', nom: '2nde', ordre: 10),
    NiveauScolaire(id: '11', nom: '1ere', ordre: 11),
    NiveauScolaire(id: '12', nom: 'Terminale', ordre: 12),
    NiveauScolaire(id: '13', nom: 'Universite', ordre: 13),
  ];

  /// Initialise les niveaux par defaut si c'est le premier lancement.
  Future<void> ensureInitialized() async {
    final initialized = _prefs.getBool(_initializedKey) ?? false;
    if (!initialized) {
      await saveAll(defaultNiveaux);
      await _prefs.setBool(_initializedKey, true);
    }
  }

  /// Recupere tous les niveaux stockes localement.
  List<NiveauScolaire> getAll() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => NiveauScolaire.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarde la liste complete des niveaux.
  Future<void> saveAll(List<NiveauScolaire> niveaux) async {
    final jsonString = json.encode(
      niveaux.map((e) => e.toJson()).toList(),
    );
    await _prefs.setString(_storageKey, jsonString);
  }

  /// Ajoute un niveau a la liste existante.
  Future<NiveauScolaire> add(NiveauScolaire niveau) async {
    final list = getAll();
    list.add(niveau);
    await saveAll(list);
    return niveau;
  }

  /// Met a jour un niveau existant.
  Future<NiveauScolaire> update(NiveauScolaire niveau) async {
    final list = getAll();
    final index = list.indexWhere((e) => e.id == niveau.id);
    if (index == -1) {
      throw Exception('Niveau non trouve : ${niveau.id}');
    }
    list[index] = niveau;
    await saveAll(list);
    return niveau;
  }

  /// Supprime un niveau par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  /// Recupere un niveau par son identifiant.
  NiveauScolaire? getById(String id) {
    final list = getAll();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
