import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final webKey = dotenv.env['FIREBASE_WEB_API_KEY'];
    final androidKey = dotenv.env['FIREBASE_ANDROID_API_KEY'];


    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: webKey ?? "",
        appId: dotenv.env['APP_ID_WEB'] ?? "",
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? "",
        projectId: dotenv.env['PROJECT_ID'] ?? "",
        authDomain: dotenv.env['AUTH_DOMAIN'] ?? "",
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? "",
      );
    }

    return FirebaseOptions(
      apiKey: androidKey ?? "",
      appId: dotenv.env['APP_ID_ANDROID'] ?? "",
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? "",
      projectId: dotenv.env['PROJECT_ID'] ?? "",
      authDomain: dotenv.env['AUTH_DOMAIN'] ?? "",
      storageBucket: dotenv.env['STORAGE_BUCKET'] ?? "",
    );
  }
}
