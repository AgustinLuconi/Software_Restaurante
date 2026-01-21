import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuración de Firebase para el proyecto software-restaurante-59030
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
          'DefaultFirebaseOptions no está configurado para Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD4R_JujpPqq8zxhK9mMPq1V7lR6p9MV5U',
    appId: '1:274919132918:web:9e704bd307a6bca02666d7',
    messagingSenderId: '274919132918',
    projectId: 'software-restaurante-59030',
    authDomain: 'software-restaurante-59030.firebaseapp.com',
    storageBucket: 'software-restaurante-59030.firebasestorage.app',
    measurementId: 'G-2YVDZ1R7C7',
  );

  // Placeholder para Android - configurar cuando se necesite
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4R_JujpPqq8zxhK9mMPq1V7lR6p9MV5U',
    appId: '1:274919132918:web:9e704bd307a6bca02666d7',
    messagingSenderId: '274919132918',
    projectId: 'software-restaurante-59030',
    storageBucket: 'software-restaurante-59030.firebasestorage.app',
  );

  // Placeholder para iOS - configurar cuando se necesite
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD4R_JujpPqq8zxhK9mMPq1V7lR6p9MV5U',
    appId: '1:274919132918:web:9e704bd307a6bca02666d7',
    messagingSenderId: '274919132918',
    projectId: 'software-restaurante-59030',
    storageBucket: 'software-restaurante-59030.firebasestorage.app',
    iosBundleId: 'com.example.appRestaurante',
  );

  // Placeholder para macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD4R_JujpPqq8zxhK9mMPq1V7lR6p9MV5U',
    appId: '1:274919132918:web:9e704bd307a6bca02666d7',
    messagingSenderId: '274919132918',
    projectId: 'software-restaurante-59030',
    storageBucket: 'software-restaurante-59030.firebasestorage.app',
    iosBundleId: 'com.example.appRestaurante',
  );

  // Placeholder para Windows
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD4R_JujpPqq8zxhK9mMPq1V7lR6p9MV5U',
    appId: '1:274919132918:web:9e704bd307a6bca02666d7',
    messagingSenderId: '274919132918',
    projectId: 'software-restaurante-59030',
    storageBucket: 'software-restaurante-59030.firebasestorage.app',
  );
}
