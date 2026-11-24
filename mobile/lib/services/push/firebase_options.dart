import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase config is supplied at build time with `--dart-define-from-file=.env`.
abstract final class FirebaseConfig {
  static const vapidKey = String.fromEnvironment('FIREBASE_VAPID_KEY');
  static const _webApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );

  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      if (_webApiKey.isEmpty ||
          _webAppId.isEmpty ||
          _authDomain.isEmpty ||
          _projectId.isEmpty ||
          _storageBucket.isEmpty ||
          _messagingSenderId.isEmpty ||
          vapidKey.isEmpty) {
        return null;
      }
      return const FirebaseOptions(
        apiKey: _webApiKey,
        authDomain: _authDomain,
        projectId: _projectId,
        storageBucket: _storageBucket,
        messagingSenderId: _messagingSenderId,
        appId: _webAppId,
      );
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android
          when _androidApiKey.isNotEmpty &&
              _androidAppId.isNotEmpty &&
              _projectId.isNotEmpty &&
              _storageBucket.isNotEmpty &&
              _messagingSenderId.isNotEmpty =>
        const FirebaseOptions(
          apiKey: _androidApiKey,
          appId: _androidAppId,
          messagingSenderId: _messagingSenderId,
          projectId: _projectId,
          storageBucket: _storageBucket,
        ),
      _ => null,
    };
  }
}
