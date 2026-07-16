import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/categorie_joueur.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'clearable_datasource.dart';

/// Source de donnees locale pour les categories de joueurs.
/// Utilise SharedPreferences pour persister les donnees en JSON.
/// Les donnees sont synchronisees depuis le backend.
class CategorieJoueurLocalDatasource implements ClearableDatasource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'categories_joueurs_data';
  static const String _initializedKey = 'categories_joueurs_initialized';

  CategorieJoueurLocalDatasource(this._prefs);

  /// Verifie si les donnees ont deja ete synchronisees depuis le backend.
  bool get isInitialized => _prefs.getBool(_initializedKey) ?? false;

  /// Methode de compatibilite - ne fait rien car la sync est geree par syncFromApi.
  Future<void> ensureInitialized() async {
    // Les donnees sont synchronisees depuis le backend via syncFromApi()
  }

  /// Recupere toutes les categories stockees localement.
  List<CategorieJoueur> getAll() {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => CategorieJoueur.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarde la liste complete des categories.
  Future<void> saveAll(List<CategorieJoueur> categories) async {
    final jsonString = json.encode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, jsonString);
  }

  /// Ajoute une categorie a la liste existante.
  Future<CategorieJoueur> add(CategorieJoueur categorie) async {
    final list = getAll();
    list.add(categorie);
    await saveAll(list);
    return categorie;
  }

  /// Met a jour une categorie existante.
  Future<CategorieJoueur> update(CategorieJoueur categorie) async {
    final list = getAll();
    final index = list.indexWhere((e) => e.id == categorie.id);
    if (index == -1) {
      throw Exception('Categorie non trouvee : ${categorie.id}');
    }
    list[index] = categorie;
    await saveAll(list);
    return categorie;
  }

  /// Supprime une categorie par son identifiant.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  /// Recupere une categorie par son identifiant.
  CategorieJoueur? getById(String id) {
    final list = getAll();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Reconcilie le stockage local avec la liste distante (le serveur fait foi).
  /// Les categories synchronisees absentes du serveur sont supprimees.
  /// Les categories locales en attente de synchronisation (ID timestamp)
  /// sont conservees.
  Future<void> upsertAllFromRemote(List<CategorieJoueur> remoteList) async {
    final local = getAll();
    final remoteIds = remoteList.map((c) => c.id).toSet();
    final kept = local.where((c) {
      final isLocalPending = RegExp(r'^\d{10,}$').hasMatch(c.id);
      return isLocalPending && !remoteIds.contains(c.id);
    }).toList();
    final map = {for (final c in kept) c.id: c};
    for (final remote in remoteList) {
      map[remote.id] = remote;
    }
    await saveAll(map.values.toList());
  }

  /// Synchronise les categories de joueurs depuis le backend.
  /// Reconcilie les donnees locales avec celles du serveur.
  Future<bool> syncFromApi(DioClient dioClient) async {
    try {
      final result = await dioClient.get<List<dynamic>>(
        ApiEndpoints.categoriesJoueurs,
      );
      return result.fold(
        (failure) {
          // ignore: avoid_print
          print('[CategorieJoueur] Sync failed: ${failure.message}');
          return false;
        },
        (data) async {
          final categories = data.map((json) {
            final map = json as Map<String, dynamic>;
            return CategorieJoueur(
              id: map['id'] as String,
              nom: map['nom'] as String,
              description: map['description'] as String?,
              ordre: map['ordre'] as int? ?? 0,
              createdAt: map['created_at'] != null
                  ? DateTime.parse(map['created_at'] as String)
                  : null,
            );
          }).toList();
          await upsertAllFromRemote(categories);
          await _prefs.setBool(_initializedKey, true);
          // ignore: avoid_print
          print(
            '[CategorieJoueur] Synced ${categories.length} items from backend',
          );
          return true;
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[CategorieJoueur] Sync exception: $e');
      return false;
    }
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_storageKey);
    await _prefs.remove(_initializedKey);
  }
}
