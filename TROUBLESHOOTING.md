# Troubleshooting FCM Token and Notifications

## Issue: FCM Token Not Showing in Logs

### Step 1: Check Firebase Initialization

Look for these logs when the app starts:
```
🔥 Initializing Firebase...
✅ Firebase initialized successfully
```

If you see:
```
❌ Firebase initialization error: ...
```

**Solution:**
1. **For Android:**
   - Make sure `google-services.json` is in `android/app/`
   - Add to `android/build.gradle.kts`:
     ```kotlin
     buildscript {
         dependencies {
             classpath("com.google.gms:google-services:4.4.0")
         }
     }
     ```
   - Add to `android/app/build.gradle.kts`:
     ```kotlin
     plugins {
         id("com.google.gms.google-services")
     }
     ```

2. **For iOS:**
   - Make sure `GoogleService-Info.plist` is in `ios/Runner/`
   - Run: `cd ios && pod install`

3. **Or use FlutterFire CLI:**
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```

### Step 2: Check Notification Service Initialization

Look for these logs:
```
🔔 Initializing NotificationService...
✅ FirebaseMessaging instance created
📱 Requesting notification permissions...
✅ User granted notification permission
🔑 Getting FCM token...
✅ FCM Token retrieved and stored: ...
```

If you see errors, check:
- Firebase is properly initialized (Step 1)
- Permissions are granted
- Internet connection is available

### Step 3: Check Permission Status

The app will request permissions automatically. Check logs for:
```
📱 Authorization status: AuthorizationStatus.authorized
```

If status is `denied`:
- **Android:** Go to Settings → Apps → Your App → Notifications → Enable
- **iOS:** Go to Settings → Your App → Notifications → Enable

### Step 4: Manual Token Retrieval Test

Add this to test token retrieval manually:

```dart
// In any controller or widget
final notificationService = Get.find<NotificationService>();
final token = await notificationService.getFCMToken();
print('Manual token check: $token');
```

## Issue: Notification Pop-up Not Showing

### For Foreground Notifications

Foreground notifications show as snackbars. Check:
1. App is in foreground (not minimized)
2. Notification service is initialized
3. Message handler is registered (check logs)

### For Background Notifications

Background notifications should show automatically. Check:
1. App has notification permissions
2. Background message handler is registered in `main.dart`
3. Firebase Cloud Messaging is enabled in Firebase Console

### Testing Notifications

1. **Get FCM Token from logs:**
   ```
   ✅ FCM Token retrieved and stored: YOUR_TOKEN_HERE
   ```

2. **Send test notification from Firebase Console:**
   - Go to Firebase Console → Cloud Messaging
   - Click "Send your first message"
   - Enter title and message
   - Click "Send test message"
   - Paste your FCM token
   - Send

3. **Or use curl:**
   ```bash
   curl -X POST https://fcm.googleapis.com/fcm/send \
     -H "Authorization: key=YOUR_SERVER_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "to": "YOUR_FCM_TOKEN",
       "notification": {
         "title": "Test",
         "body": "Test notification"
       }
     }'
   ```

## Common Errors

### Error: "Firebase app is NOT initialized"
- **Cause:** Firebase configuration files missing
- **Solution:** Follow Step 1 above

### Error: "Failed to get FCM token - token is null"
- **Cause:** Firebase not properly configured or no internet
- **Solution:** 
  - Check internet connection
  - Verify Firebase project is set up correctly
  - Check Firebase Console for any errors

### Error: "User denied notification permission"
- **Cause:** User denied permission
- **Solution:** 
  - Go to device settings
  - Enable notifications for the app
  - Restart the app

### No logs appearing at all
- **Cause:** App might be crashing silently
- **Solution:**
  - Check full error logs: `flutter run -v`
  - Check device logs: `adb logcat` (Android) or Console.app (iOS)
  - Look for any red error messages

## Debug Checklist

- [ ] Firebase initialized successfully (check logs)
- [ ] `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) exists
- [ ] Notification permissions granted
- [ ] Internet connection available
- [ ] FCM token appears in logs
- [ ] Token is stored in SharedPreferences (key: `fcm_token`)
- [ ] Background message handler registered
- [ ] Foreground message handler registered

## Quick Test

Run this in your app to test everything:

```dart
// Add to any controller
void testNotifications() async {
  try {
    final service = Get.find<NotificationService>();
    print('Testing notification service...');
    
    final token = await service.getFCMToken();
    print('Token: $token');
    
    final storage = Get.find<StorageService>();
    final storedToken = storage.getString('fcm_token');
    print('Stored token: $storedToken');
    
    print('Service initialized: ${service.fcmToken != null}');
  } catch (e) {
    print('Error: $e');
  }
}
```
