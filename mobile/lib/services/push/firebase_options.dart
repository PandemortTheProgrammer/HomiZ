import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Configuración de Firebase (proyecto homiz-413ff) por plataforma. Estos datos son públicos: identifican la app.
/// - Web: «Tus apps» → Homiz Web (firebaseConfig) y la clave de «Certificados push web».
/// - Android: datos de android/app/google-services.json (paquete mx.zugar.homiz).
/// - iOS: datos de ios/Runner/GoogleService-Info.plist (bundle mx.zugar.homiz) + clave APNs subida a Firebase.
/// null = esa plataforma todavía no está registrada en Firebase: la app funciona igual, sin avisos push.
abstract final class FirebaseConfig {
  static const vapidKey = 'BEJw-k2x765RpmUta5eQpKFwF0Pfp5f8B7yRorKR792pTS0irlUE-dGdiGZj7sC9KDaZf3skbgCH8WpdhV25Elc';

  static const _web = FirebaseOptions(
    apiKey: 'AIzaSyBx7pt0_zgMJBrK0MoFiM91-7tOmRLtX1E',
    authDomain: 'homiz-413ff.firebaseapp.com',
    projectId: 'homiz-413ff',
    storageBucket: 'homiz-413ff.firebasestorage.app',
    messagingSenderId: '781670117568',
    appId: '1:781670117568:web:ce01ba2a927343e7c57d25',
  );

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'AIzaSyD9ABCMIBFZ3uXA3OvCBHz_le7DifocQQs',
    appId: '1:781670117568:android:76ec2a2314de49f6c57d25',
    messagingSenderId: '781670117568',
    projectId: 'homiz-413ff',
    storageBucket: 'homiz-413ff.firebasestorage.app',
  );

  // Pendiente: se llena con GoogleService-Info.plist.
  static const FirebaseOptions? _ios = null;

  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return _web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _android,
      TargetPlatform.iOS => _ios,
      _ => null,
    };
  }
}
