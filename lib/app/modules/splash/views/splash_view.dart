import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:pointbox_mobile/app/services/storage_service.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('🚀 SplashView: Initializing app...');
    
    try {
      // Initialize notification service and get FCM token
      print('🔔 SplashView: Getting NotificationService...');
      //final notificationService = Get.find<NotificationService>();
      
      // Try to get FCM token (it should already be initialized in main.dart)
      print('🔔 SplashView: Checking FCM token...');
      // var fcmToken = notificationService.fcmToken;
      //
      // // If token is not available, try to get it again
      // if (fcmToken == null || fcmToken.isEmpty) {
      //   print('⚠️ SplashView: FCM token not found, requesting again...');
      //   await notificationService.requestNotificationPermissions();
      //   fcmToken = await notificationService.getFCMToken();
      // }
      //
      // // Get the FCM token and store it
      // if (fcmToken != null && fcmToken.isNotEmpty) {
      //   final storage = Get.find<StorageService>();
      //   await storage.setString('fcm_token', fcmToken);
      //   print('✅ SplashView: FCM Token stored: $fcmToken');
      // } else {
      //   print('⚠️ SplashView: FCM token is still null or empty');
      //   print('⚠️ This might indicate Firebase is not properly configured');
      // }
    } catch (e, stackTrace) {
      print('❌ SplashView: Error initializing notifications: $e');
      print('Stack trace: $stackTrace');
      // Continue even if notification setup fails
    }
    
    // Wait a bit for initialization
    print('⏳ SplashView: Waiting 2 seconds...');
    await Future.delayed(const Duration(seconds: 2));
    
    // Check authentication status
    print('🔐 SplashView: Checking authentication status...');
    final storage = Get.find<StorageService>();
    final isLoggedIn = storage.getBool('is_logged_in') ?? false;
    print('🔐 SplashView: Is logged in: $isLoggedIn');
    
    final route = isLoggedIn ? AppRoutes.HOME : AppRoutes.LOGIN;
    print('🚀 SplashView: Navigating to: $route');
    Get.offNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: ThemeService.purpleGradient,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset('./assets/images/logo.png')),
              // Image.network(
              //   'https://res.cloudinary.com/dcz9bugal/image/upload/v1765730094/settings-logos/yqfrzyjurn9kkvxrgde1.png',
              //   width: 200,
              //   height: 200,
              //   fit: BoxFit.contain,
              //   errorBuilder: (context, error, stackTrace) {
              //     return const Icon(
              //       Icons.image_not_supported,
              //       size: 200,
              //       color: Colors.white70,
              //     );
              //   },
              //   loadingBuilder: (context, child, loadingProgress) {
              //     if (loadingProgress == null) return child;
              //     return const SizedBox(
              //       width: 200,
              //       height: 200,
              //       child: Center(
              //         child: CircularProgressIndicator(
              //           color: Colors.white,
              //         ),
              //       ),
              //     );
              //   },
              // ),
            const  SizedBox(height: 24),
             const Text(
                'PointBox',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

