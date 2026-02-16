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
      _genererNotificationsDemo();
      return getAll();
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

  /// Genere des notifications de demonstration pour le premier lancement.
  void _genererNotificationsDemo() {
    final now = DateTime.now();
    final demos = <NotificationItem>[
      NotificationItem(
        id: 'notif_001',
        titre: 'Nouvelle seance programmee',
        description:
            'Une seance d\'entrainement a ete programmee pour demain a 15h00 au terrain principal.',
        type: NotificationType.seance,
        priorite: NotificationPriority.haute,
        dateCreation: now.subtract(const Duration(minutes: 15)),
        cibleRole: 'tous',
      ),
      NotificationItem(
        id: 'notif_002',
        titre: 'Taux de presence en baisse',
        description:
            'Le taux de presence de cette semaine est de 72%, en baisse de 8% par rapport a la semaine precedente.',
        type: NotificationType.presence,
        priorite: NotificationPriority.haute,
        dateCreation: now.subtract(const Duration(hours: 2)),
        cibleRole: 'admin',
      ),
      NotificationItem(
        id: 'notif_003',
        titre: 'Nouvel academicien inscrit',
        description:
            'Mamadou Diallo a ete inscrit avec succes dans la categorie U13.',
        type: NotificationType.inscription,
        priorite: NotificationPriority.normale,
        dateCreation: now.subtract(const Duration(hours: 5)),
        cibleRole: 'admin',
      ),
      NotificationItem(
        id: 'notif_004',
        titre: 'Rappel : Evaluation trimestrielle',
        description:
            'Les evaluations trimestrielles doivent etre completees avant le 28 de ce mois.',
        type: NotificationType.rappel,
        priorite: NotificationPriority.urgente,
        dateCreation: now.subtract(const Duration(hours: 8)),
        cibleRole: 'encadreur',
      ),
      NotificationItem(
        id: 'notif_005',
        titre: 'SMS envoyes avec succes',
        description:
            '12 SMS ont ete envoyes aux parents des academiciens du groupe A.',
        type: NotificationType.sms,
        priorite: NotificationPriority.basse,
        dateCreation: now.subtract(const Duration(days: 1)),
        estLue: true,
        cibleRole: 'admin',
      ),
      NotificationItem(
        id: 'notif_006',
        titre: 'Bulletin genere',
        description:
            'Le bulletin de Moussa Keita (U15) a ete genere et est pret a etre consulte.',
        type: NotificationType.bulletin,
        priorite: NotificationPriority.normale,
        dateCreation: now.subtract(const Duration(days: 1, hours: 3)),
        cibleRole: 'tous',
      ),
      NotificationItem(
        id: 'notif_007',
        titre: 'Mise a jour systeme',
        description:
            'L\'application a ete mise a jour vers la version 1.2.0 avec de nouvelles fonctionnalites.',
        type: NotificationType.systeme,
        priorite: NotificationPriority.basse,
        dateCreation: now.subtract(const Duration(days: 2)),
        estLue: true,
        cibleRole: 'tous',
      ),
      NotificationItem(
        id: 'notif_008',
        titre: 'Seance annulee',
        description:
            'La seance du mercredi 12 a ete annulee en raison des conditions meteorologiques.',
        type: NotificationType.seance,
        priorite: NotificationPriority.haute,
        dateCreation: now.subtract(const Duration(days: 3)),
        estLue: true,
        cibleRole: 'tous',
      ),
      NotificationItem(
        id: 'notif_009',
        titre: 'Nouveau coach assigne',
        description:
            'Coach Ibrahim a ete assigne au groupe des U11 pour la saison en cours.',
        type: NotificationType.inscription,
        priorite: NotificationPriority.normale,
        dateCreation: now.subtract(const Duration(days: 4)),
        estLue: true,
        cibleRole: 'encadreur',
      ),
      NotificationItem(
        id: 'notif_010',
        titre: 'Rappel : Reunion d\'equipe',
        description:
            'Reunion de coordination prevue vendredi a 10h00 dans la salle de reunion.',
        type: NotificationType.rappel,
        priorite: NotificationPriority.normale,
        dateCreation: now.subtract(const Duration(days: 5)),
        estLue: true,
        cibleRole: 'tous',
      ),
    ];

    final jsonList = demos.map((e) => e.toJson()).toList();
    _prefs.setString(_key, json.encode(jsonList));
  }
}
