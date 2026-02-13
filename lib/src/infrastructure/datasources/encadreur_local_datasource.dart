import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/encadreur.dart';

/// Source de données locale pour les encadreurs.
/// Utilise SharedPreferences pour persister les données en JSON.
class EncadreurLocalDatasource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'encadreurs_data';

  EncadreurLocalDatasource(this._prefs);

  /// Récupère tous les encadreurs stockés localement.
  List<Encadreur> getAll() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => Encadreur.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarde la liste complète des encadreurs.
  Future<void> saveAll(List<Encadreur> encadreurs) async {
    final jsonString = json.encode(
      encadreurs.map((e) => e.toJson()).toList(),
    );
    await _prefs.setString(_storageKey, jsonString);
  }

  /// Ajoute un encadreur à la liste existante.
  Future<Encadreur> add(Encadreur encadreur) async {
    final list = getAll();
    list.add(encadreur);
    await saveAll(list);
    return encadreur;
  }

  /// Met à jour un encadreur existant.
  Future<Encadreur> update(Encadreur encadreur) async {
    final list = getAll();
    final index = list.indexWhere((e) => e.id == encadreur.id);
    if (index == -1) {
      throw Exception('Encadreur non trouvé : ${encadreur.id}');
    }
    list[index] = encadreur;
    await saveAll(list);
    return encadreur;
  }

  /// Supprime un encadreur par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  /// Récupère un encadreur par son identifiant.
  Encadreur? getById(String id) {
    final list = getAll();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Récupère un encadreur par son code QR.
  Encadreur? getByQrCode(String qrCode) {
    final list = getAll();
    try {
      return list.firstWhere((e) => e.codeQrUnique == qrCode);
    } catch (_) {
      return null;
    }
  }
}
