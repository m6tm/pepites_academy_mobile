import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/presence.dart';

/// Source de donnees locale pour les presences (scans QR).
/// Utilise SharedPreferences pour persister les donnees en JSON.
class PresenceLocalDatasource {
  static const String _key = 'presences_data';
  final SharedPreferences _prefs;

  PresenceLocalDatasource(this._prefs);

  /// Recupere toutes les presences stockees localement.
  List<Presence> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Enregistre une nouvelle presence.
  Future<Presence> add(Presence presence) async {
    final list = getAll();
    list.add(presence);
    await _saveAll(list);
    return presence;
  }

  /// Recupere les presences d'une seance specifique.
  List<Presence> getBySeance(String seanceId) {
    return getAll().where((p) => p.seanceId == seanceId).toList();
  }

  /// Recupere l'historique de presence d'un profil.
  List<Presence> getByProfil(String profilId) {
    return getAll().where((p) => p.profilId == profilId).toList();
  }

  /// Verifie si un profil est deja present pour une seance donnee.
  bool isAlreadyPresent(String profilId, String seanceId) {
    return getAll().any(
      (p) => p.profilId == profilId && p.seanceId == seanceId,
    );
  }

  Future<void> _saveAll(List<Presence> list) async {
    final jsonList = list.map((e) => _toJson(e)).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }

  Map<String, dynamic> _toJson(Presence p) {
    return {
      'id': p.id,
      'horodateArrivee': p.horodateArrivee.toIso8601String(),
      'typeProfil': p.typeProfil.name,
      'profilId': p.profilId,
      'seanceId': p.seanceId,
    };
  }

  Presence _fromJson(Map<String, dynamic> json) {
    return Presence(
      id: json['id'] as String,
      horodateArrivee: DateTime.parse(json['horodateArrivee'] as String),
      typeProfil: ProfilType.values.firstWhere(
        (e) => e.name == json['typeProfil'],
      ),
      profilId: json['profilId'] as String,
      seanceId: json['seanceId'] as String,
    );
  }
}
