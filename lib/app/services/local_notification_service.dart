import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  LocalNotificationsService._internal();
  static final LocalNotificationsService _instance =
  LocalNotificationsService._internal();
  factory LocalNotificationsService.instance() => _instance;

  late FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  int _id = 0;

  final AndroidNotificationChannel _channel =
  const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications',
    importance: Importance.max,
  );

  Future<void> init() async {
    if (_initialized) return;

    _plugin = FlutterLocalNotificationsPlugin();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  Future<void> showNotification(
      String? title,
      String? body,
      String? payload,
      ) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(_id++, title, body, details, payload: payload);
  }
}
