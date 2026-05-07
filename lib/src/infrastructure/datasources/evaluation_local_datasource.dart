import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/evaluation.dart';
import 'clearable_datasource.dart';

/// Source de donnees locale pour les evaluations multicriteres.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class EvaluationLocalDatasource implements ClearableDatasource {
  static const String _key = 'evaluations_data';
  final SharedPreferences _prefs;

  EvaluationLocalDatasource(this._prefs);

  List<Evaluation> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Evaluation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertAll(List<Evaluation> remoteList) async {
    final local = getAll();
    final merged = <String, Evaluation>{for (final e in local) e.id: e};
    for (final remote in remoteList) {
      merged[remote.id] = remote;
    }
    await _saveAll(merged.values.toList());
  }

  Future<Evaluation> add(Evaluation evaluation) async {
    final list = getAll();
    list.add(evaluation);
    await _saveAll(list);
    return evaluation;
  }

  Future<Evaluation> update(Evaluation evaluation) async {
    final list = getAll();
    final index = list.indexWhere((e) => e.id == evaluation.id);
    if (index == -1) {
      throw Exception('Evaluation introuvable : ${evaluation.id}');
    }
    list[index] = evaluation;
    await _saveAll(list);
    return evaluation;
  }

  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((e) => e.id == id);
    await _saveAll(list);
  }

  Evaluation? getById(String id) {
    final all = getAll();
    final matches = all.where((e) => e.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  List<Evaluation> getByAcademicien(String academicienId) {
    return getAll().where((e) => e.academicienId == academicienId).toList()
      ..sort((a, b) => b.horodate.compareTo(a.horodate));
  }

  List<Evaluation> getByAtelier(String atelierId) {
    return getAll().where((e) => e.atelierId == atelierId).toList()
      ..sort((a, b) => b.horodate.compareTo(a.horodate));
  }

  List<Evaluation> getBySeance(String seanceId) {
    return getAll().where((e) => e.seanceId == seanceId).toList()
      ..sort((a, b) => b.horodate.compareTo(a.horodate));
  }

  List<Evaluation> getByAcademicienAndAtelier(
    String academicienId,
    String atelierId,
  ) {
    return getAll()
        .where(
          (e) => e.academicienId == academicienId && e.atelierId == atelierId,
        )
        .toList()
      ..sort((a, b) => b.horodate.compareTo(a.horodate));
  }

  Future<void> _saveAll(List<Evaluation> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_key);
  }
}
