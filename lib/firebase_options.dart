// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDR32dsGsiNWEVisky38Owh6ev5fWZXT_8',
    appId: '1:251836884122:web:9ed6d58e1ac4f6cb1aeb23',
    messagingSenderId: '251836884122',
    projectId: 'melodyflow-now-playing',
    authDomain: 'melodyflow-now-playing.firebaseapp.com',
    storageBucket: 'melodyflow-now-playing.appspot.com',
    measurementId: 'G-655GV1KCXV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEovhkxVHv5Qp3LAHU1bFXxsVszBe-lPw',
    appId: '1:251836884122:android:0c725acc5e17188e1aeb23',
    messagingSenderId: '251836884122',
    projectId: 'melodyflow-now-playing',
    storageBucket: 'melodyflow-now-playing.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDR32dsGsiNWEVisky38Owh6ev5fWZXT_8',
    appId: '1:251836884122:web:2ed4bab5ad2712731aeb23',
    messagingSenderId: '251836884122',
    projectId: 'melodyflow-now-playing',
    authDomain: 'melodyflow-now-playing.firebaseapp.com',
    storageBucket: 'melodyflow-now-playing.appspot.com',
    measurementId: 'G-J9PTDZHV3Y',
  );
}
