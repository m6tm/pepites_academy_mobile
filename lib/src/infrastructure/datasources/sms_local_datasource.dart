import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/entities/sms_message.dart';

/// Source de donnees locale pour les SMS.
/// Utilise SharedPreferences pour persister l'historique en JSON.
class SmsLocalDatasource {
  static const String _key = 'sms_history_data';
  final SharedPreferences _prefs;
  AppLocalizations? _l10n;

  SmsLocalDatasource(this._prefs);

  /// Met a jour les traductions.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Recupere tout l'historique des SMS.
  List<SmsMessage> getAll() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => SmsMessage.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.dateEnvoi.compareTo(a.dateEnvoi));
  }

  /// Enregistre un nouveau SMS dans l'historique.
  Future<SmsMessage> add(SmsMessage message) async {
    final list = getAll();
    list.insert(0, message);
    await _saveAll(list);
    return message;
  }

  /// Met a jour le statut d'un SMS existant.
  Future<SmsMessage> update(SmsMessage message) async {
    final list = getAll();
    final index = list.indexWhere((m) => m.id == message.id);
    if (index == -1) {
      throw Exception(
        _l10n?.infraSmsNotFound(message.id) ??
            'SMS introuvable : ${message.id}',
      );
    }
    list[index] = message;
    await _saveAll(list);
    return message;
  }

  /// Supprime un SMS de l'historique.
  Future<void> delete(String id) async {
    final list = getAll();
    list.removeWhere((m) => m.id == id);
    await _saveAll(list);
  }

  /// Compte le nombre total de SMS envoyes avec succes.
  int getTotalEnvoyes() {
    return getAll().where((m) => m.statut == StatutEnvoi.envoye).length;
  }

  /// Compte le nombre de SMS envoyes ce mois-ci.
  int getEnvoyesCeMois() {
    final now = DateTime.now();
    return getAll()
        .where(
          (m) =>
              m.statut == StatutEnvoi.envoye &&
              m.dateEnvoi.year == now.year &&
              m.dateEnvoi.month == now.month,
        )
        .length;
  }

  /// Compte le nombre de SMS en echec.
  int getEnEchec() {
    return getAll().where((m) => m.statut == StatutEnvoi.echec).length;
  }

  Future<void> _saveAll(List<SmsMessage> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, json.encode(jsonList));
  }
}
