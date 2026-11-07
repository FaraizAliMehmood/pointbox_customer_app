import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'local_notification_service.dart';
import 'storage_service.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
  FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationsService? _localNotificationsService;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    _localNotificationsService = localNotificationsService;

    await _requestPermission();
    await _getToken();

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _getToken() async {
    _fcmToken = await FirebaseMessaging.instance.getToken();
    print(_fcmToken);
    log('✅ FCM Token: $_fcmToken');

    // Store token in SharedPreferences
    if (_fcmToken != null) {
      try {
        final storage = Get.find<StorageService>();
        await storage.setString('fcm_token', _fcmToken!);
        log('✅ FCM Token stored in SharedPreferences');
      } catch (e) {
        log('⚠️ Could not store FCM token: $e');
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _fcmToken = token;
      log('🔄 Token refreshed: $token');

      // Update stored token
      try {
        final storage = Get.find<StorageService>();
        storage.setString('fcm_token', token);
        log('✅ Refreshed FCM Token stored');
      } catch (e) {
        log('⚠️ Could not store refreshed FCM token: $e');
      }
    });
  }

  // The backend persists the notification row (MySQL `notifications` +
  // `customer_notifications`) when it's sent, so the client only needs to
  // show the system banner here - the Notifications screen reloads from
  // the backend (see NotificationsController.loadNotifications).
  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotificationsService?.showNotification(
        notification.title,
        notification.body,
        message.data.toString(),
      );
    }

    _refreshNotificationsControllerIfRegistered();
  }

  void _onMessageOpenedApp(RemoteMessage message) async {
    log('📲 Notification opened: ${message.data}');

    try {
      Get.toNamed(AppRoutes.NOTIFICATIONS);
      _refreshNotificationsControllerIfRegistered();
    } catch (e) {
      log('Error navigating to notifications: $e');
    }
  }

  void _refreshNotificationsControllerIfRegistered() {
    try {
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().loadNotifications();
      }
    } catch (e) {
      log('NotificationsController not available: $e');
    }
  }
}
