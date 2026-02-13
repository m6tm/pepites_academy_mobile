import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/seance.dart';

/// Source de donnees locale pour les seances d'entrainement.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class SeanceLocalDatasource {
  static const String _key = 'seances_data';
  final SharedPreferences _prefs;

  SeanceLocalDatasource(this._prefs);

  /// Recupere toutes les seances stockees localement.
  List<Seance> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Seance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Recupere une seance par son identifiant.
  Seance? getById(String id) {
    final all = getAll();
    final matches = all.where((s) => s.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  /// Recupere la seance actuellement ouverte.
  Seance? getSeanceOuverte() {
    final all = getAll();
    final ouvertes = all.where((s) => s.statut == SeanceStatus.ouverte);
    return ouvertes.isEmpty ? null : ouvertes.first;
  }

  /// Enregistre une nouvelle seance.
  Future<Seance> add(Seance seance) async {
    final list = getAll();
    list.add(seance);
    await _saveAll(list);
    return seance;
  }

  /// Met a jour une seance existante.
  Future<Seance> update(Seance seance) async {
    final list = getAll();
    final index = list.indexWhere((s) => s.id == seance.id);
    if (index == -1) {
      throw Exception('Seance non trouvee : ${seance.id}');
    }
    list[index] = seance;
    await _saveAll(list);
    return seance;
  }

  /// Supprime une seance par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((s) => s.id == id);
    await _saveAll(list);
  }

  Future<void> _saveAll(List<Seance> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }
}
