import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/niveau_scolaire.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'clearable_datasource.dart';

/// Source de donnees locale pour les niveaux scolaires.
/// Utilise SharedPreferences pour persister les donnees en JSON.
/// Les donnees sont synchronisees depuis le backend.
class NiveauScolaireLocalDatasource implements ClearableDatasource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'niveaux_scolaires_data';
  static const String _initializedKey = 'niveaux_scolaires_initialized';

  NiveauScolaireLocalDatasource(this._prefs);

  /// Verifie si les donnees ont deja ete synchronisees depuis le backend.
  bool get isInitialized => _prefs.getBool(_initializedKey) ?? false;

  /// Methode de compatibilite - ne fait rien car la sync est geree par syncFromApi.
  Future<void> ensureInitialized() async {
    // Les donnees sont synchronisees depuis le backend via syncFromApi()
  }

  /// Recupere tous les niveaux stockes localement.
  List<NiveauScolaire> getAll() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => NiveauScolaire.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarde la liste complete des niveaux.
  Future<void> saveAll(List<NiveauScolaire> niveaux) async {
    final jsonString = json.encode(niveaux.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, jsonString);
  }

  /// Ajoute un niveau a la liste existante.
  Future<NiveauScolaire> add(NiveauScolaire niveau) async {
    final list = getAll();
    list.add(niveau);
    await saveAll(list);
    return niveau;
  }

  /// Met a jour un niveau existant.
  Future<NiveauScolaire> update(NiveauScolaire niveau) async {
    final list = getAll();
    final index = list.indexWhere((e) => e.id == niveau.id);
    if (index == -1) {
      throw Exception('Niveau non trouve : ${niveau.id}');
    }
    list[index] = niveau;
    await saveAll(list);
    return niveau;
  }

  /// Supprime un niveau par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  /// Recupere un niveau par son identifiant.
  NiveauScolaire? getById(String id) {
    final list = getAll();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Synchronise les niveaux scolaires depuis le backend.
  /// Remplace les donnees locales par celles du serveur.
  Future<bool> syncFromApi(DioClient dioClient) async {
    try {
      final result = await dioClient.get<List<dynamic>>(
        ApiEndpoints.niveauxScolaires,
      );
      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[NiveauScolaire] Sync failed: ${failure.message}');
          return false;
        },
        (data) async {
          final niveaux = data.map((json) {
            final map = json as Map<String, dynamic>;
            return NiveauScolaire(
              id: map['id'] as String,
              nom: map['nom'] as String,
              ordre: map['ordre'] as int? ?? 0,
              createdAt: map['created_at'] != null
                  ? DateTime.parse(map['created_at'] as String)
                  : null,
              updatedAt: map['updated_at'] != null
                  ? DateTime.parse(map['updated_at'] as String)
                  : null,
            );
          }).toList();
          await saveAll(niveaux);
          await _prefs.setBool(_initializedKey, true);
          // ignore: avoid_print
          print('[NiveauScolaire] Synced ${niveaux.length} items from backend');
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[NiveauScolaire] Sync exception: $e');
      return false;
    }
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_storageKey);
    await _prefs.remove(_initializedKey);
  }
}
