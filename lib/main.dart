import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/theme_service.dart';
import 'app/services/localization_service.dart';
import 'app/services/firebase_messaging_service.dart';
import 'app/services/local_notification_service.dart';
import 'app/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize StorageService first (required by auth controller and other services)
  await Get.putAsync(() => StorageService().init());

  // ✅ SAFEST Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
    // else: Firebase already initialized → SAFE TO IGNORE
  }

  // ✅ Register background handler ONCE
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await requestPermissions();

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(
    localNotificationsService: localNotificationsService,
  );

  runApp(const MyApp());
}

// The backend persists the notification row (MySQL `notifications` +
// `customer_notifications`) when it's sent, and the OS shows the system
// notification for the `message.notification` payload on its own while the
// app is backgrounded - so this handler only needs Firebase initialized in
// the background isolate, nothing else to do here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      print('❌ Firebase error in background handler: $e');
      rethrow;
    }
  } catch (e) {
    print('❌ Unexpected error in background handler: $e');
  }
}

Future<void> requestPermissions() async {
  await Permission.notification.request();
  await Permission.camera.request();

  if (GetPlatform.isIOS) {
    await Permission.photos.request();
  } else {
    await Permission.storage.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PointBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeService.lightTheme,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.fallbackLocale,
      translations: LocalizationService(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
    );
  }
}
