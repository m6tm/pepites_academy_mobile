import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/activity.dart';

/// Source de donnees locale pour le journal d'activites.
/// Utilise SharedPreferences pour persister les activites en JSON.
class ActivityLocalDatasource {
  static const String _key = 'activities_data';
  final SharedPreferences _prefs;

  ActivityLocalDatasource(this._prefs);

  /// Recupere toutes les activites triees par date decroissante.
  List<Activity> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    final activities = list
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities;
  }

  /// Recupere les N dernieres activites.
  List<Activity> getRecent(int limit) {
    final all = getAll();
    return all.take(limit).toList();
  }

  /// Enregistre une nouvelle activite.
  Future<Activity> add(Activity activity) async {
    final list = getAll();
    list.insert(0, activity);
    await _saveAll(list);
    return activity;
  }

  /// Supprime les activites anterieures a une date donnee.
  Future<void> purgeOlderThan(DateTime date) async {
    final list = getAll();
    list.removeWhere((a) => a.date.isBefore(date));
    await _saveAll(list);
  }

  Future<void> _saveAll(List<Activity> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }
}
