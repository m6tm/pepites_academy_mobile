import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/notification_item.dart';

/// Source de donnees locale pour les notifications.
/// Utilise SharedPreferences pour persister les notifications en JSON.
/// Genere des notifications de demonstration au premier chargement.
class NotificationLocalDatasource {
  static const String _key = 'notifications_data';
  final SharedPreferences _prefs;

  NotificationLocalDatasource(this._prefs);

  /// Recupere toutes les notifications triees par date decroissante.
  List<NotificationItem> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  }

  /// Recupere les notifications filtrees par role cible.
  List<NotificationItem> getByRole(String role) {
    return getAll()
        .where((n) => n.cibleRole == role || n.cibleRole == 'tous')
        .toList();
  }

  /// Recupere les notifications non lues pour un role.
  List<NotificationItem> getNonLues(String role) {
    return getByRole(role).where((n) => !n.estLue).toList();
  }

  /// Ajoute une nouvelle notification.
  Future<NotificationItem> add(NotificationItem notification) async {
    final list = getAll();
    list.insert(0, notification);
    await _saveAll(list);
    return notification;
  }

  /// Marque une notification comme lue.
  Future<void> marquerCommeLue(String id) async {
    final list = getAll();
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(estLue: true);
      await _saveAll(list);
    }
  }

  /// Marque toutes les notifications comme lues pour un role.
  Future<void> marquerToutesCommeLues(String role) async {
    final list = getAll();
    final updated = list.map((n) {
      if ((n.cibleRole == role || n.cibleRole == 'tous') && !n.estLue) {
        return n.copyWith(estLue: true);
      }
      return n;
    }).toList();
    await _saveAll(updated);
  }

  /// Fusionne une liste de notifications distantes dans le cache local (par id).
  /// Concilie l'etat de lecture (local ou distant) sans perdre une lecture locale
  /// en attente de synchronisation.
  Future<void> upsertAll(List<NotificationItem> remote) async {
    final local = getAll();
    final byId = {for (final n in local) n.id: n};

    for (final r in remote) {
      final existing = byId[r.id];
      if (existing == null) {
        byId[r.id] = r;
      } else {
        byId[r.id] = r.copyWith(estLue: r.estLue || existing.estLue);
      }
    }

    final merged = byId.values.toList()
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    await _saveAll(merged);
  }

  Future<void> replaceAll(List<NotificationItem> items) async {
    final sorted = items.toList()
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    await _saveAll(sorted);
  }

  /// Supprime une notification.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((n) => n.id == id);
    await _saveAll(list);
  }

  /// Supprime toutes les notifications lues pour un role.
  Future<void> supprimerLues(String role) async {
    final list = getAll();
    list.removeWhere(
      (n) => (n.cibleRole == role || n.cibleRole == 'tous') && n.estLue,
    );
    await _saveAll(list);
  }

  /// Compte le nombre de notifications non lues pour un role.
  int compterNonLues(String role) {
    return getNonLues(role).length;
  }

  Future<void> _saveAll(List<NotificationItem> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }
}
