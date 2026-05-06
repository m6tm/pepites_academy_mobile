import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/atelier.dart';
import 'clearable_datasource.dart';

/// Source de donnees locale pour les ateliers d'entrainement.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class AtelierLocalDatasource implements ClearableDatasource {
  static const String _key = 'ateliers_data';
  final SharedPreferences _prefs;

  AtelierLocalDatasource(this._prefs);

  /// Recupere tous les ateliers stockes localement.
  List<Atelier> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Atelier.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Recupere tous les ateliers d'une seance, tries par ordre.
  List<Atelier> getBySeance(String seanceId) {
    final all = getAll();
    final filtered = all.where((a) => a.seanceId == seanceId).toList();
    filtered.sort((a, b) => a.ordre.compareTo(b.ordre));
    return filtered;
  }

  /// Recupere un atelier par son identifiant.
  Atelier? getById(String id) {
    final all = getAll();
    final matches = all.where((a) => a.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  /// Enregistre un nouvel atelier.
  Future<Atelier> add(Atelier atelier) async {
    final list = getAll();
    list.add(atelier);
    await _saveAll(list);
    return atelier;
  }

  /// Met a jour un atelier existant.
  Future<Atelier> update(Atelier atelier) async {
    final list = getAll();
    final index = list.indexWhere((a) => a.id == atelier.id);
    if (index == -1) {
      throw Exception('Atelier non trouve : ${atelier.id}');
    }
    list[index] = atelier;
    await _saveAll(list);
    return atelier;
  }

  /// Supprime un atelier par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((a) => a.id == id);
    await _saveAll(list);
  }

  /// Reordonne les ateliers d'une seance selon l'ordre des IDs fournis.
  /// Retourne la liste des ateliers reordonnes avec leurs nouveaux ordres.
  Future<List<Atelier>> reorder(
    String seanceId,
    List<String> atelierIds,
  ) async {
    final list = getAll();
    final autres = list.where((a) => a.seanceId != seanceId).toList();
    final ateliersSeance = {
      for (final a in list.where((a) => a.seanceId == seanceId)) a.id: a,
    };

    final reordered = <Atelier>[];
    for (int i = 0; i < atelierIds.length; i++) {
      final atelier = ateliersSeance[atelierIds[i]];
      if (atelier != null) {
        reordered.add(atelier.copyWith(ordre: i));
        ateliersSeance.remove(atelierIds[i]);
      }
    }

    // Ajouter les ateliers restants (non inclus dans atelierIds) a la fin
    int nextOrdre = reordered.length;
    for (final atelier in ateliersSeance.values) {
      reordered.add(atelier.copyWith(ordre: nextOrdre++));
    }

    await _saveAll([...autres, ...reordered]);
    return reordered;
  }

  /// Met a jour ou insere plusieurs ateliers (upsert).
  /// Utilise pour synchroniser les donnees depuis l'API.
  Future<void> upsertAll(List<Atelier> ateliers) async {
    final list = getAll();
    final existingIds = {for (final a in list) a.id};

    for (final atelier in ateliers) {
      if (existingIds.contains(atelier.id)) {
        // Mise a jour
        final index = list.indexWhere((a) => a.id == atelier.id);
        if (index != -1) {
          list[index] = atelier;
        }
      } else {
        // Insertion
        list.add(atelier);
      }
    }

    await _saveAll(list);
  }

  Future<void> _saveAll(List<Atelier> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_key);
  }
}
