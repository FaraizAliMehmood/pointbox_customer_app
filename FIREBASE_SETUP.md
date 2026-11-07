# Firebase Cloud Messaging Setup

This document outlines the Firebase Cloud Messaging (FCM) integration for push notifications in the PointBox mobile app.

## What Has Been Implemented

1. **Firebase Dependencies Added**
   - `firebase_core`: ^3.6.0
   - `firebase_messaging`: ^15.1.3
   - `permission_handler`: ^11.3.1

2. **Notification Service** (`lib/app/services/notification_service.dart`)
   - Handles FCM token retrieval
   - Requests notification permissions (iOS and Android)
   - Handles foreground and background messages
   - Stores FCM token in local storage

3. **SplashView Integration**
   - Requests notification permissions on app launch
   - Retrieves and stores FCM token
   - Token is available for use in login API

4. **Login API Integration**
   - Auth controller now retrieves FCM token from storage
   - Token is passed to the login API as `deviceToken` parameter

5. **Platform Configuration**
   - Android: Added notification permissions and FCM service
   - iOS: Added background modes and notification support

## Required Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable Cloud Messaging API

### 2. Android Setup

1. **Add Android App to Firebase:**
   - In Firebase Console, click "Add app" → Android
   - Package name: `com.example.pointbox_mobile`
   - Download `google-services.json`

2. **Place google-services.json:**
   - Copy `google-services.json` to `android/app/`

3. **Update build.gradle files:**
   
   **android/build.gradle.kts:**
   ```kotlin
   buildscript {
       dependencies {
           classpath("com.google.gms:google-services:4.4.0")
       }
   }
   ```
   
   **android/app/build.gradle.kts:**
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```

### 3. iOS Setup

1. **Add iOS App to Firebase:**
   - In Firebase Console, click "Add app" → iOS
   - Bundle ID: Your iOS bundle identifier
   - Download `GoogleService-Info.plist`

2. **Place GoogleService-Info.plist:**
   - Copy `GoogleService-Info.plist` to `ios/Runner/`

3. **Update Podfile:**
   ```ruby
   platform :ios, '12.0'
   ```

4. **Run pod install:**
   ```bash
   cd ios
   pod install
   ```

### 4. Initialize Firebase in Code

The Firebase initialization is already set up in `main.dart`. However, you may need to configure Firebase options:

**Option 1: Using FlutterFire CLI (Recommended)**
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

**Option 2: Manual Configuration**
- Create `lib/firebase_options.dart` with your Firebase configuration
- Update `main.dart` to use `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`

## Testing

1. **Get FCM Token:**
   - Run the app and check console logs for "FCM Token: ..."
   - Token is also stored in SharedPreferences with key `fcm_token`

2. **Test Notifications:**
   - Use Firebase Console → Cloud Messaging → Send test message
   - Enter the FCM token from step 1
   - Send a test notification

3. **Verify Login API:**
   - Login with valid credentials
   - Check backend logs to verify `deviceToken` is received

## API Integration

The FCM token is automatically passed to the login API:

```dart
ApiService.login(
  email: email,
  password: password,
  deviceToken: fcmToken, // Automatically retrieved from storage
)
```

The backend endpoint `/api/customer/login` receives the token in the request body:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "deviceToken": "fcm_token_here"
}
```

## Troubleshooting

1. **Firebase initialization error:**
   - Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location
   - Verify package name/bundle ID matches Firebase project

2. **FCM token not generated:**
   - Check internet connection
   - Verify Firebase project is properly configured
   - Check console logs for error messages

3. **Notifications not received:**
   - Verify notification permissions are granted
   - Check FCM token is valid
   - Ensure device has internet connection
   - For iOS, verify APNs certificates are configured in Firebase

4. **Android 13+ notification permission:**
   - The app automatically requests runtime permission for Android 13+
   - User must grant permission for notifications to work

## Next Steps

1. Complete Firebase project setup (add Android/iOS apps)
2. Add Firebase configuration files to the project
3. Test FCM token generation
4. Test push notifications from Firebase Console
5. Implement notification handling logic based on your requirements
