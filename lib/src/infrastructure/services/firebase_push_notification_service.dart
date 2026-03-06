import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/notification_item.dart';
import '../../domain/entities/sync_operation.dart';
import '../datasources/notification_local_datasource.dart';
import '../network/api_endpoints.dart';
import '../../injection_container.dart';

/// Topics FCM pour chaque catégorie de notification
enum NotificationTopic {
  seances('seances'),
  presences('presences'),
  annotations('annotations'),
  messages('messages'),
  rappels('rappels');

  const NotificationTopic(this.value);
  final String value;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Pour le background, on doit s'assurer que SharedPreferences est accessible
  final prefs = await SharedPreferences.getInstance();
  final localDb = NotificationLocalDatasource(prefs);

  // Vérifier si les notifications globales sont activées
  final notifGlobales = prefs.getBool('notif_globales') ?? true;
  if (!notifGlobales) return;

  // Vérifier la catégorie de la notification
  final category = message.data['category'] as String?;
  if (category != null) {
    final categoryKey = 'notif_$category';
    final categoryEnabled = prefs.getBool(categoryKey) ?? true;
    if (!categoryEnabled) return;
  }

  _saveNotificationToDb(message, localDb);
}

/// Handler de niveau supérieur pour les notifications en arrière-plan
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  if (response.payload != null) {
    debugPrint('Background notification payload: ${response.payload}');
  }
}

void _saveNotificationToDb(
  RemoteMessage message,
  NotificationLocalDatasource localDb,
) {
  try {
    if (message.notification != null) {
      // Déterminer le type de notification depuis les données
      final category = message.data['category'] as String?;
      NotificationType type = NotificationType.systeme;
      if (category != null) {
        switch (category) {
          case 'seances':
            type = NotificationType.seance;
            break;
          case 'presences':
            type = NotificationType.presence;
            break;
          case 'annotations':
            type = NotificationType
                .systeme; // Pas de type annotation, utiliser systeme
            break;
          case 'messages':
            type = NotificationType.sms; // Utiliser sms pour les messages
            break;
          case 'rappels':
            type = NotificationType.rappel;
            break;
        }
      }

      final notif = NotificationItem(
        id:
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        titre: message.notification?.title ?? 'Nouvelle notification',
        description: message.notification?.body ?? '',
        type: type,
        priorite: NotificationPriority.normale,
        dateCreation: message.sentTime ?? DateTime.now(),
        cibleRole: 'tous',
      );
      localDb.add(notif);
    }
  } catch (e) {
    debugPrint('Erreur lors de la sauvegarde de la notification: $e');
  }
}

class FirebasePushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final NotificationLocalDatasource _localDatasource;
  final SharedPreferences _prefs;

  /// Callback appelé quand une notification est reçue en foreground
  /// Permet de notifier l'UI pour rafraîchir la liste des notifications
  VoidCallback? onNotificationReceived;

  FirebasePushNotificationService(this._localDatasource, this._prefs);

  Future<void> initialize() async {
    // 1. Demander les permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permission de notification accordée');
    } else {
      debugPrint('Permission de notification refusée');
      return;
    }

    // 2. Initialiser le plugin de notifications locales
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onSelectNotification(response);
      },
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Créer le channel Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'Notifications Importantes', // name
      description: 'Ce canal est utilisé pour les notifications importantes.',
      importance: Importance.high,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 3. Configurer les handlers
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message reçu au premier plan: ${message.messageId}');
      _handleForegroundMessage(message, channel);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message cliqué depuis l\'arrière-plan: ${message.messageId}');
      _handleMessageOpenedApp(message);
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // 4. Obtenir le token FCM et l'envoyer au serveur
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      if (token != null) {
        await sendTokenToServer();
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token FCM: $e');
    }

    // 4.5 Écouter les rafraîchissements de token
    setupTokenRefreshListener();

    // 5. Synchroniser les topics selon les préférences actuelles
    await syncTopicsFromPreferences();
  }

  /// Synchronise les souscriptions aux topics FCM selon les préférences
  Future<void> syncTopicsFromPreferences() async {
    final notifGlobales = _prefs.getBool('notif_globales') ?? true;

    if (!notifGlobales) {
      // Se désinscrire de tous les topics
      for (final topic in NotificationTopic.values) {
        await unsubscribeFromTopic(topic);
      }
      return;
    }

    // Synchroniser chaque topic individuellement
    for (final topic in NotificationTopic.values) {
      final key = 'notif_${topic.value}';
      final enabled = _prefs.getBool(key) ?? true;

      if (enabled) {
        await subscribeToTopic(topic);
      } else {
        await unsubscribeFromTopic(topic);
      }
    }
  }

  /// Souscrit à un topic FCM
  Future<void> subscribeToTopic(NotificationTopic topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic.value);
      debugPrint('Souscrit au topic: ${topic.value}');
    } catch (e) {
      debugPrint('Erreur souscription topic ${topic.value}: $e');
    }
  }

  /// Se désinscrit d'un topic FCM
  Future<void> unsubscribeFromTopic(NotificationTopic topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic.value);
      debugPrint('Désinscrit du topic: ${topic.value}');
    } catch (e) {
      debugPrint('Erreur désinscription topic ${topic.value}: $e');
    }
  }

  /// Active ou désactive toutes les notifications push
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notif_globales', enabled);

    if (!enabled) {
      // Se désinscrire de tous les topics
      for (final topic in NotificationTopic.values) {
        await unsubscribeFromTopic(topic);
      }
    } else {
      // Resynchroniser selon les préférences
      await syncTopicsFromPreferences();
    }
  }

  /// Active ou désactive une catégorie de notification
  Future<void> setCategoryEnabled(NotificationTopic topic, bool enabled) async {
    final key = 'notif_${topic.value}';
    await _prefs.setBool(key, enabled);

    final notifGlobales = _prefs.getBool('notif_globales') ?? true;
    if (!notifGlobales) return;

    if (enabled) {
      await subscribeToTopic(topic);
    } else {
      await unsubscribeFromTopic(topic);
    }
  }

  /// Vérifie si une catégorie de notification est activée
  bool isCategoryEnabled(NotificationTopic topic) {
    final notifGlobales = _prefs.getBool('notif_globales') ?? true;
    if (!notifGlobales) return false;

    final key = 'notif_${topic.value}';
    return _prefs.getBool(key) ?? true;
  }

  /// Vérifie si les notifications globales sont activées
  bool isNotificationsEnabled() {
    return _prefs.getBool('notif_globales') ?? true;
  }

  /// Envoie le token FCM au serveur backend via la queue de synchronisation.
  /// Retourne true si l'operation a ete mise en file d'attente, false sinon.
  /// Si aucune session n'est active, l'envoi est ignore.
  Future<bool> sendTokenToServer() async {
    try {
      // Verifier si une session est active avant d'envoyer le token
      final isLoggedIn = _prefs.getBool('user_role') != null;
      if (!isLoggedIn) {
        debugPrint('Session non active, envoi token FCM differe');
        return false;
      }

      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        debugPrint('Aucun token FCM disponible');
        return false;
      }

      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'web';

      // Ajouter l'operation dans la queue de synchronisation (non bloquant)
      await DependencyInjection.syncService.enqueueOperation(
        entityType: SyncEntityType.fcmToken,
        entityId: token,
        operationType: SyncOperationType.create,
        data: {
          'token': token,
          'platform': platform,
          'device_name':
              '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        },
      );

      debugPrint('Token FCM mis en file d\'attente pour envoi');
      return true;
    } catch (e) {
      debugPrint('Exception mise en file token FCM: $e');
      return false;
    }
  }

  /// Supprime le token FCM du serveur (déconnexion)
  Future<bool> removeTokenFromServer() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) return true;

      final result = await DependencyInjection.dioClient.delete<dynamic>(
        ApiEndpoints.fcmToken,
        data: {'token': token},
      );

      return result.fold(
        (failure) {
          debugPrint('Erreur suppression token FCM: $failure');
          return false;
        },
        (data) {
          debugPrint('Token FCM supprimé du serveur');
          return true;
        },
      );
    } catch (e) {
      debugPrint('Exception suppression token FCM: $e');
      return false;
    }
  }

  /// Écoute les changements de token FCM et les envoie au serveur
  /// L'envoi n'est effectue que si une session est active.
  void setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token rafraîchi: $newToken');
      await sendTokenToServer();
    });
  }

  void _handleForegroundMessage(
    RemoteMessage message,
    AndroidNotificationChannel channel,
  ) {
    // Vérifier les préférences avant d'afficher
    final notifGlobales = _prefs.getBool('notif_globales') ?? true;
    if (!notifGlobales) return;

    // Vérifier la catégorie
    final category = message.data['category'] as String?;
    if (category != null) {
      final categoryKey = 'notif_$category';
      final categoryEnabled = _prefs.getBool(categoryKey) ?? true;
      if (!categoryEnabled) return;
    }

    _saveNotificationToDb(message, _localDatasource);

    // Notifier l'UI qu'une nouvelle notification a été reçue
    onNotificationReceived?.call();

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Navigation depuis notification: ${message.data}');
  }

  void _onSelectNotification(NotificationResponse response) {
    if (response.payload != null) {
      debugPrint('Payload de notification cliquée: ${response.payload}');
    }
  }
}
