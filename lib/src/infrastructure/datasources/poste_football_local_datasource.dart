import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/poste_football.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Source de donnees locale pour les postes de football.
/// Utilise SharedPreferences pour persister les donnees en JSON.
/// Les donnees sont synchronisees depuis le backend.
class PosteFootballLocalDatasource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'postes_football_data';
  static const String _initializedKey = 'postes_football_initialized';

  PosteFootballLocalDatasource(this._prefs);

  /// Verifie si les donnees ont deja ete synchronisees depuis le backend.
  bool get isInitialized => _prefs.getBool(_initializedKey) ?? false;

  /// Methode de compatibilite - ne fait rien car la sync est geree par syncFromApi.
  Future<void> ensureInitialized() async {
    // Les donnees sont synchronisees depuis le backend via syncFromApi()
  }

  /// Recupere tous les postes stockes localement.
  List<PosteFootball> getAll() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => PosteFootball.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarde la liste complete des postes.
  Future<void> saveAll(List<PosteFootball> postes) async {
    final jsonString = json.encode(postes.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, jsonString);
  }

  /// Ajoute un poste a la liste existante.
  Future<PosteFootball> add(PosteFootball poste) async {
    final list = getAll();
    list.add(poste);
    await saveAll(list);
    return poste;
  }

  /// Met a jour un poste existant.
  Future<PosteFootball> update(PosteFootball poste) async {
    final list = getAll();
    final index = list.indexWhere((e) => e.id == poste.id);
    if (index == -1) {
      throw Exception('Poste non trouve : ${poste.id}');
    }
    list[index] = poste;
    await saveAll(list);
    return poste;
  }

  /// Supprime un poste par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  /// Recupere un poste par son identifiant.
  PosteFootball? getById(String id) {
    final list = getAll();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Synchronise les postes de football depuis le backend.
  /// Remplace les donnees locales par celles du serveur.
  Future<bool> syncFromApi(DioClient dioClient) async {
    try {
      final result = await dioClient.get<List<dynamic>>(
        ApiEndpoints.postesFootball,
      );
      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[PosteFootball] Sync failed: ${failure.message}');
          return false;
        },
        (data) async {
          final postes = data.map((json) {
            final map = json as Map<String, dynamic>;
            return PosteFootball(
              id: map['id'] as String,
              nom: map['nom'] as String,
              description: map['description'] as String?,
              iconeCodePoint: map['icone_code_point'] as String?,
              createdAt: map['created_at'] != null
                  ? DateTime.parse(map['created_at'] as String)
                  : null,
              updatedAt: map['updated_at'] != null
                  ? DateTime.parse(map['updated_at'] as String)
                  : null,
            );
          }).toList();
          await saveAll(postes);
          await _prefs.setBool(_initializedKey, true);
          // ignore: avoid_print
          print('[PosteFootball] Synced ${postes.length} items from backend');
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[PosteFootball] Sync exception: $e');
      return false;
    }
  }
}
