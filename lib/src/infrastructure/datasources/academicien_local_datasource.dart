import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/academicien.dart';

/// Source de donnees locale pour les academiciens.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class AcademicienLocalDatasource {
  static const String _key = 'academiciens_data';
  final SharedPreferences _prefs;

  AcademicienLocalDatasource(this._prefs);

  Future<List<Academicien>> getAll() async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Academicien?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Academicien> create(Academicien academicien) async {
    final all = await getAll();
    all.add(academicien);
    await _saveAll(all);
    return academicien;
  }

  Future<Academicien> update(Academicien academicien) async {
    final all = await getAll();
    final index = all.indexWhere((e) => e.id == academicien.id);
    if (index != -1) {
      all[index] = academicien;
      await _saveAll(all);
    }
    return academicien;
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
  }

  Future<Academicien?> getByQrCode(String qrCode) async {
    final all = await getAll();
    try {
      return all.firstWhere((e) => e.codeQrUnique == qrCode);
    } catch (_) {
      return null;
    }
  }

  Future<List<Academicien>> search(String query) async {
    final all = await getAll();
    final q = query.toLowerCase();
    return all.where((e) {
      return e.nom.toLowerCase().contains(q) ||
          e.prenom.toLowerCase().contains(q) ||
          e.telephoneParent.contains(q);
    }).toList();
  }

  Future<void> _saveAll(List<Academicien> list) async {
    final jsonList = list.map((e) => _toJson(e)).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }

  Map<String, dynamic> _toJson(Academicien a) {
    return {
      'id': a.id,
      'nom': a.nom,
      'prenom': a.prenom,
      'dateNaissance': a.dateNaissance.toIso8601String(),
      'photoUrl': a.photoUrl,
      'telephoneParent': a.telephoneParent,
      'posteFootballId': a.posteFootballId,
      'niveauScolaireId': a.niveauScolaireId,
      'codeQrUnique': a.codeQrUnique,
      'piedFort': a.piedFort,
    };
  }

  Academicien _fromJson(Map<String, dynamic> json) {
    return Academicien(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: DateTime.parse(json['dateNaissance'] as String),
      photoUrl: json['photoUrl'] as String,
      telephoneParent: json['telephoneParent'] as String,
      posteFootballId: json['posteFootballId'] as String,
      niveauScolaireId: json['niveauScolaireId'] as String,
      codeQrUnique: json['codeQrUnique'] as String,
      piedFort: json['piedFort'] as String?,
    );
  }
}
