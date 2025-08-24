// File: lib/firebase_options.dart

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
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCY6a2TtVZNjXrLxdc8ZXjWymjVM2BVDMQ',
    authDomain: 'formify-144f9.firebaseapp.com',
    projectId: 'formify-144f9',
    storageBucket: 'formify-144f9.firebasestorage.app',
    messagingSenderId: '945217121097',
    appId: '1:945217121097:web:c2e2c3ba5acf324e8a0898',
    measurementId: 'G-QF7GY52CPR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDelEl-DzWNMf0mki_A9w-EHSkrx5r4hQQ',
    appId: '1:945217121097:android:5205026fdab75bd18a0898',
    messagingSenderId: '945217121097',
    projectId: 'formify-144f9',
    storageBucket: 'formify-144f9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: '945217121097',
    projectId: 'formify-144f9',
    storageBucket: 'formify-144f9.firebasestorage.app',
    iosBundleId: 'your.ios.bundle.id',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: 'your-macos-app-id',
    messagingSenderId: '945217121097',
    projectId: 'formify-144f9',
    storageBucket: 'formify-144f9.firebasestorage.app',
    iosBundleId: 'your.macos.bundle.id',
  );
}
