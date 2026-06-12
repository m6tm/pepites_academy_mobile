import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/bilan_medical_mensuel.dart';
import 'clearable_datasource.dart';

/// Source de donnees locale pour les bilans medicaux mensuels.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class BilanMedicalMensuelLocalDatasource implements ClearableDatasource {
  static const String _key = 'bilans_medicaux_mensuels_data';
  final SharedPreferences _prefs;

  BilanMedicalMensuelLocalDatasource(this._prefs);

  Future<List<BilanMedicalMensuel>> getAll() async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list
        .map((e) => BilanMedicalMensuel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BilanMedicalMensuel>> getByAcademicienId(String academicienId) async {
    final all = await getAll();
    return all.where((b) => b.academicienId == academicienId).toList();
  }

  Future<BilanMedicalMensuel?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<BilanMedicalMensuel> create(BilanMedicalMensuel bilan) async {
    final all = await getAll();
    final index = all.indexWhere((b) => b.id == bilan.id);
    if (index != -1) {
      all[index] = bilan;
    } else {
      all.add(bilan);
    }
    await saveAll(all);
    return bilan;
  }

  Future<BilanMedicalMensuel> update(BilanMedicalMensuel bilan) async {
    final all = await getAll();
    final index = all.indexWhere((b) => b.id == bilan.id);
    if (index != -1) {
      all[index] = bilan;
      await saveAll(all);
    }
    return bilan;
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((b) => b.id == id);
    await saveAll(all);
  }

  Future<void> saveAll(List<BilanMedicalMensuel> list) async {
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
