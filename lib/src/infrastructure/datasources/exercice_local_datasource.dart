import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/exercice.dart';

/// Source de données locale pour les exercices des ateliers.
/// Utilise SharedPreferences pour persister les données en JSON.
class ExerciceLocalDatasource {
  static const String _key = 'exercices_data';
  final SharedPreferences _prefs;

  ExerciceLocalDatasource(this._prefs);

  /// Récupère tous les exercices stockés localement.
  List<Exercice> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Exercice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Récupère tous les exercices d'un atelier, triés par ordre.
  List<Exercice> getByAtelier(String atelierId) {
    final all = getAll();
    final filtered = all.where((e) => e.atelierId == atelierId).toList();
    filtered.sort((a, b) => a.ordre.compareTo(b.ordre));
    return filtered;
  }

  /// Récupère un exercice par son identifiant.
  Exercice? getById(String id) {
    final all = getAll();
    final matches = all.where((e) => e.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  /// Enregistre un nouvel exercice.
  Future<Exercice> add(Exercice exercice) async {
    final list = getAll();
    list.add(exercice);
    await _saveAll(list);
    return exercice;
  }

  /// Met à jour un exercice existant.
  Future<Exercice> update(Exercice exercice) async {
    final list = getAll();
    final index = list.indexWhere((e) => e.id == exercice.id);
    if (index == -1) {
      throw Exception('Exercice non trouvé : ${exercice.id}');
    }
    list[index] = exercice;
    await _saveAll(list);
    return exercice;
  }

  /// Supprime un exercice par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((e) => e.id == id);
    await _saveAll(list);
  }

  /// Réordonne les exercices d'un atelier selon l'ordre des IDs fournis.
  Future<List<Exercice>> reorder(
    String atelierId,
    List<String> exerciceIds,
  ) async {
    final list = getAll();
    final autres = list.where((e) => e.atelierId != atelierId).toList();
    final exercicesAtelier = {
      for (final e in list.where((e) => e.atelierId == atelierId)) e.id: e,
    };

    final reordered = <Exercice>[];
    for (int i = 0; i < exerciceIds.length; i++) {
      final exercice = exercicesAtelier[exerciceIds[i]];
      if (exercice != null) {
        reordered.add(exercice.copyWith(ordre: i));
        exercicesAtelier.remove(exerciceIds[i]);
      }
    }

    // Ajouter les exercices restants
    int nextOrdre = reordered.length;
    for (final exercice in exercicesAtelier.values) {
      reordered.add(exercice.copyWith(ordre: nextOrdre++));
    }

    await _saveAll([...autres, ...reordered]);
    return reordered;
  }

  /// Met à jour ou insère plusieurs exercices (upsert).
  Future<void> upsertAll(List<Exercice> exercices) async {
    final list = getAll();
    final existingMap = {for (final e in list) e.id: e};

    for (final exercice in exercices) {
      existingMap[exercice.id] = exercice;
    }

    await _saveAll(existingMap.values.toList());
  }

  Future<void> _saveAll(List<Exercice> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }
}
