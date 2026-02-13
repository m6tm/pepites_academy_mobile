import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/annotation.dart';

/// Source de donnees locale pour les annotations.
/// Utilise SharedPreferences pour persister les donnees en JSON.
class AnnotationLocalDatasource {
  static const String _key = 'annotations_data';
  final SharedPreferences _prefs;

  AnnotationLocalDatasource(this._prefs);

  /// Recupere toutes les annotations stockees localement.
  List<Annotation> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list.map((e) => Annotation.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Enregistre une nouvelle annotation.
  Future<Annotation> add(Annotation annotation) async {
    final list = getAll();
    list.add(annotation);
    await _saveAll(list);
    return annotation;
  }

  /// Met a jour une annotation existante.
  Future<Annotation> update(Annotation annotation) async {
    final list = getAll();
    final index = list.indexWhere((a) => a.id == annotation.id);
    if (index == -1) {
      throw Exception('Annotation introuvable : ${annotation.id}');
    }
    list[index] = annotation;
    await _saveAll(list);
    return annotation;
  }

  /// Supprime une annotation par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((a) => a.id == id);
    await _saveAll(list);
  }

  /// Recupere les annotations d'un academicien.
  List<Annotation> getByAcademicien(String academicienId) {
    return getAll()
        .where((a) => a.academicienId == academicienId)
        .toList()
      ..sort((a, b) => b.horodate.compareTo(a.horodate));
  }

  /// Recupere les annotations d'un atelier.
  List<Annotation> getByAtelier(String atelierId) {
    return getAll()
        .where((a) => a.atelierId == atelierId)
        .toList()
      ..sort((a, b) => b.horodate.compareTo(a.horodate));
  }

  /// Recupere les annotations d'une seance.
  List<Annotation> getBySeance(String seanceId) {
    return getAll()
        .where((a) => a.seanceId == seanceId)
        .toList()
      ..sort((a, b) => b.horodate.compareTo(a.horodate));
  }

  /// Recupere les annotations d'un academicien pour un atelier specifique.
  List<Annotation> getByAcademicienAndAtelier(
    String academicienId,
    String atelierId,
  ) {
    return getAll()
        .where((a) => a.academicienId == academicienId && a.atelierId == atelierId)
        .toList()
      ..sort((a, b) => b.horodate.compareTo(a.horodate));
  }

  Future<void> _saveAll(List<Annotation> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }
}
