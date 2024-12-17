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
    apiKey: 'AIzaSyBNQZ6_wYFtfTMu-uEHEhZF_leFlyOnxZM',
    appId: '1:54753276247:web:42a56523231cb1a0edce12',
    messagingSenderId: '54753276247',
    projectId: 'capstones2024',
    authDomain: 'capstones2024.firebaseapp.com',
    storageBucket: 'capstones2024.appspot.com',
    measurementId: 'G-NDT9BNEXGG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzluYvk94zb70DHVk8E0h7ZFNhT-8-c04',
    appId: '1:54753276247:android:82b6403a1de64b6eedce12',
    messagingSenderId: '54753276247',
    projectId: 'capstones2024',
    storageBucket: 'capstones2024.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCimHiDzfSM12iL3RxvtSaTcdfCNH64aHE',
    appId: '1:54753276247:ios:7bb58fe8acebc4bcedce12',
    messagingSenderId: '54753276247',
    projectId: 'capstones2024',
    storageBucket: 'capstones2024.appspot.com',
    iosBundleId: 'com.example.capstonesproject2024',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCimHiDzfSM12iL3RxvtSaTcdfCNH64aHE',
    appId: '1:54753276247:ios:7bb58fe8acebc4bcedce12',
    messagingSenderId: '54753276247',
    projectId: 'capstones2024',
    storageBucket: 'capstones2024.appspot.com',
    iosBundleId: 'com.example.capstonesproject2024',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBNQZ6_wYFtfTMu-uEHEhZF_leFlyOnxZM',
    appId: '1:54753276247:web:d16da43d5f8aa4f4edce12',
    messagingSenderId: '54753276247',
    projectId: 'capstones2024',
    authDomain: 'capstones2024.firebaseapp.com',
    storageBucket: 'capstones2024.appspot.com',
    measurementId: 'G-4G0WFPM5SW',
  );
}