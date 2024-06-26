// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
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
    apiKey: 'AIzaSyA10XHSad6vTrAZtqe4flPlzrtbpAUEzps',
    appId: '1:1017167425832:web:b4b82d3850a5b2ecf6a01d',
    messagingSenderId: '1017167425832',
    projectId: 'gpt-exam',
    authDomain: 'gpt-exam.firebaseapp.com',
    storageBucket: 'gpt-exam.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdIpyt3JiTMgOoOI4GQtu7nj_TwshRezw',
    appId: '1:1017167425832:android:0e9d2e165ce1e6fef6a01d',
    messagingSenderId: '1017167425832',
    projectId: 'gpt-exam',
    storageBucket: 'gpt-exam.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBaaM9Yn447PU-iulnbDqhqkWttRedSogw',
    appId: '1:1017167425832:ios:930f3bd2a7bc9e42f6a01d',
    messagingSenderId: '1017167425832',
    projectId: 'gpt-exam',
    storageBucket: 'gpt-exam.appspot.com',
    iosBundleId: 'com.example.appAtexGptExam',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBaaM9Yn447PU-iulnbDqhqkWttRedSogw',
    appId: '1:1017167425832:ios:8c45587be6984e02f6a01d',
    messagingSenderId: '1017167425832',
    projectId: 'gpt-exam',
    storageBucket: 'gpt-exam.appspot.com',
    iosBundleId: 'com.example.appAtexGptExam.RunnerTests',
  );
}
