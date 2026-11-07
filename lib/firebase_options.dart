
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }



  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyBpE9qHybmlSv-rsMIsJ9_RDMoSBGeqW9A",
      authDomain: "pointbox-3f28b.firebaseapp.com",
      projectId: "pointbox-3f28b",
      storageBucket: "pointbox-3f28b.firebasestorage.app",
      messagingSenderId: "195428108197",
      appId: "1:195428108197:web:598e6c307d29e30c178a4c",
      measurementId: "G-K63H2DHR8J"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpE9qHybmlSv-rsMIsJ9_RDMoSBGeqW9A',
    appId: '1:195428108197:web:598e6c307d29e30c178a4c',
    messagingSenderId: '195428108197',
    projectId: 'pointbox-3f28b',
    storageBucket: 'pointbox-3f28b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjQ4lQeHEoukgN6OD9AowqswI5xlvuEdw',
    appId: '1:798134053702:ios:2833f43f0efbe55a6f9347',
    messagingSenderId: '798134053702',
    projectId: 'mate-bet-cd505',
    storageBucket: 'mate-bet-cd505.firebasestorage.app',
    iosBundleId: 'com.example.mateBet',
  );
}