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
    apiKey: 'AIzaSyCoWPgOcpHPPk58XxmZ6D3XhdX9abZHK9w',
    appId: '1:336794678098:web:b0b801abafe5cd1891808b',
    messagingSenderId: '336794678098',
    projectId: 'bootcamprojeai',
    authDomain: 'bootcamprojeai.firebaseapp.com',
    storageBucket: 'bootcamprojeai.appspot.com',
    measurementId: 'G-BQ4D80NRPG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFIOM1g1annWpzmVWOSgs9K9bAwEp4NjU',
    appId: '1:336794678098:android:f41e28b15e050bed91808b',
    messagingSenderId: '336794678098',
    projectId: 'bootcamprojeai',
    storageBucket: 'bootcamprojeai.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBpFb1V8mf5M0o_-QWNbUjZlw0wGbb_y48',
    appId: '1:336794678098:ios:4a8467767fb004fb91808b',
    messagingSenderId: '336794678098',
    projectId: 'bootcamprojeai',
    storageBucket: 'bootcamprojeai.appspot.com',
    iosClientId: '336794678098-tkficuaovgp90rt3lpvv4tqqbe6klufp.apps.googleusercontent.com',
    iosBundleId: 'com.example.bootcamprojeai',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBpFb1V8mf5M0o_-QWNbUjZlw0wGbb_y48',
    appId: '1:336794678098:ios:4a8467767fb004fb91808b',
    messagingSenderId: '336794678098',
    projectId: 'bootcamprojeai',
    storageBucket: 'bootcamprojeai.appspot.com',
    iosClientId: '336794678098-tkficuaovgp90rt3lpvv4tqqbe6klufp.apps.googleusercontent.com',
    iosBundleId: 'com.example.bootcamprojeai',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCoWPgOcpHPPk58XxmZ6D3XhdX9abZHK9w',
    appId: '1:336794678098:web:bbeab8ce547a28af91808b',
    messagingSenderId: '336794678098',
    projectId: 'bootcamprojeai',
    authDomain: 'bootcamprojeai.firebaseapp.com',
    storageBucket: 'bootcamprojeai.appspot.com',
    measurementId: 'G-NDTYRM77ED',
  );
}
