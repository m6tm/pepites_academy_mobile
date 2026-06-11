import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/dossier_medical.dart';
import 'clearable_datasource.dart';

/// Source de donnees locale pour les dossiers medicaux.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class DossierMedicalLocalDatasource implements ClearableDatasource {
  static const String _key = 'dossiers_medicaux_data';
  final SharedPreferences _prefs;

  DossierMedicalLocalDatasource(this._prefs);

  Future<List<DossierMedical>> getAll() async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((e) => DossierMedical.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DossierMedical>> getByAcademicienId(String academicienId) async {
    final all = await getAll();
    return all.where((d) => d.academicienId == academicienId).toList();
  }

  Future<DossierMedical?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<DossierMedical> create(DossierMedical dossier) async {
    final all = await getAll();
    final index = all.indexWhere((d) => d.id == dossier.id);
    if (index != -1) {
      all[index] = dossier;
    } else {
      all.add(dossier);
    }
    await saveAll(all);
    return dossier;
  }

  Future<DossierMedical> update(DossierMedical dossier) async {
    final all = await getAll();
    final index = all.indexWhere((d) => d.id == dossier.id);
    if (index != -1) {
      all[index] = dossier;
      await saveAll(all);
    }
    return dossier;
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((d) => d.id == id);
    await saveAll(all);
  }

  Future<void> saveAll(List<DossierMedical> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  @override
  Future<void> clearCache() async {
    await clear();
  }
}
