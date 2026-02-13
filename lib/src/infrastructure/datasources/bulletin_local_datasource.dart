import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/bulletin.dart';

/// Source de donnees locale pour les bulletins de formation.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class BulletinLocalDatasource {
  static const String _key = 'bulletins_data';
  final SharedPreferences _prefs;

  BulletinLocalDatasource(this._prefs);

  /// Recupere tous les bulletins stockes localement.
  List<Bulletin> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => Bulletin.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Recupere un bulletin par son identifiant.
  Bulletin? getById(String id) {
    final list = getAll();
    final index = list.indexWhere((b) => b.id == id);
    return index != -1 ? list[index] : null;
  }

  /// Enregistre un nouveau bulletin.
  Future<Bulletin> add(Bulletin bulletin) async {
    final list = getAll();
    list.add(bulletin);
    await _saveAll(list);
    return bulletin;
  }

  /// Met a jour un bulletin existant.
  Future<Bulletin> update(Bulletin bulletin) async {
    final list = getAll();
    final index = list.indexWhere((b) => b.id == bulletin.id);
    if (index == -1) {
      throw Exception('Bulletin introuvable : ${bulletin.id}');
    }
    list[index] = bulletin;
    await _saveAll(list);
    return bulletin;
  }

  /// Supprime un bulletin par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((b) => b.id == id);
    await _saveAll(list);
  }

  /// Recupere les bulletins d'un academicien.
  List<Bulletin> getByAcademicien(String academicienId) {
    return getAll()
        .where((b) => b.academicienId == academicienId)
        .toList()
      ..sort((a, b) => b.dateGeneration.compareTo(a.dateGeneration));
  }

  Future<void> _saveAll(List<Bulletin> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }
}
