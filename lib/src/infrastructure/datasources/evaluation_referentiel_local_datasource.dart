import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/critere_evaluation.dart';
import '../../domain/entities/referentiel_evaluation_data.dart';
import 'clearable_datasource.dart';

/// Source de donnees locale pour le referentiel d'evaluation multicritere.
/// Gere le seed initial et les mises a jour idempotentes du referentiel.
class EvaluationReferentielLocalDatasource implements ClearableDatasource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'evaluation_referentiel_data';
  static const String _versionKey = 'evaluation_referentiel_version';
  static const int _currentVersion = 3;

  EvaluationReferentielLocalDatasource(this._prefs);

  /// Verifie si le referentiel a ete initialise et est a jour.
  bool get isInitialized {
    final version = _prefs.getInt(_versionKey) ?? 0;
    return version >= _currentVersion;
  }

  /// Seed initial ou mise a jour du referentiel.
  /// Idempotent : une re-execution ne cree pas de doublons (upsert sur id).
  Future<void> seed() async {
    final storedVersion = _prefs.getInt(_versionKey) ?? 0;
    final criteres = ReferentielEvaluationData.criteres;
    final existing = getAll();

    if (storedVersion < _currentVersion) {
      await clearCache();
      await _saveAll(criteres);
    } else if (existing.isEmpty) {
      await _saveAll(criteres);
    } else {
      await _upsertAll(criteres, existing);
    }

    await _prefs.setInt(_versionKey, _currentVersion);
  }

  /// Recupere tous les criteres avec leurs elements.
  List<CritereEvaluation> getAll() {
    final jsonStr = _prefs.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => CritereEvaluation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Recupere un critere par son identifiant.
  CritereEvaluation? getById(String id) {
    final all = getAll();
    final matches = all.where((c) => c.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  /// Recupere les elements d'un critere donne.
  List<ElementEvaluation> getElementsByCritereId(String critereId) {
    final critere = getById(critereId);
    return critere?.elements ?? [];
  }

  /// Recupere un element par son identifiant.
  ElementEvaluation? getElementById(String elementId) {
    final all = getAll();
    for (final critere in all) {
      final matches = critere.elements.where((e) => e.id == elementId);
      if (matches.isNotEmpty) return matches.first;
    }
    return null;
  }

  /// Upsert : met a jour les criteres existants et insere les nouveaux.
  Future<void> _upsertAll(
    List<CritereEvaluation> source,
    List<CritereEvaluation> existing,
  ) async {
    final existingMap = {for (final c in existing) c.id: c};

    for (final critere in source) {
      existingMap[critere.id] = critere;
    }

    await _saveAll(existingMap.values.toList());
  }

  Future<void> _saveAll(List<CritereEvaluation> criteres) async {
    final jsonList = criteres.map((c) => c.toJson()).toList();
    await _prefs.setString(_storageKey, json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_storageKey);
    await _prefs.remove(_versionKey);
  }
}
