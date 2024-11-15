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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyDgorC-A4PaY6IAfdm23P9pg6KHvdfGt3c',
    appId: '1:1067949980182:web:420637e8aa56e067b99337',
    messagingSenderId: '1067949980182',
    projectId: 'pw-manager-mongiello',
    authDomain: 'pw-manager-mongiello.firebaseapp.com',
    storageBucket: 'pw-manager-mongiello.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgnqDYcm30_wdKhG9gX8wnDXyVqKLegdE',
    appId: '1:1067949980182:android:a1164910fdef591cb99337',
    messagingSenderId: '1067949980182',
    projectId: 'pw-manager-mongiello',
    storageBucket: 'pw-manager-mongiello.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA46DjcKE4QD7brPGu6J7FQv2Cs9Dd5mPs',
    appId: '1:1067949980182:ios:a787c2a5dcc52894b99337',
    messagingSenderId: '1067949980182',
    projectId: 'pw-manager-mongiello',
    storageBucket: 'pw-manager-mongiello.firebasestorage.app',
    iosBundleId: 'com.example.pwFrontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA46DjcKE4QD7brPGu6J7FQv2Cs9Dd5mPs',
    appId: '1:1067949980182:ios:a787c2a5dcc52894b99337',
    messagingSenderId: '1067949980182',
    projectId: 'pw-manager-mongiello',
    storageBucket: 'pw-manager-mongiello.firebasestorage.app',
    iosBundleId: 'com.example.pwFrontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDgorC-A4PaY6IAfdm23P9pg6KHvdfGt3c',
    appId: '1:1067949980182:web:f8d00587737281deb99337',
    messagingSenderId: '1067949980182',
    projectId: 'pw-manager-mongiello',
    authDomain: 'pw-manager-mongiello.firebaseapp.com',
    storageBucket: 'pw-manager-mongiello.firebasestorage.app',
  );

}