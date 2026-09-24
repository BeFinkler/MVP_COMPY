import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

abstract final class AdminFirebaseInitializer {
  static Future<void> initialize() {
    if (Firebase.apps.isNotEmpty) return Future<void>.value();
    return Firebase.initializeApp(
      options: CompyAdminFirebaseOptions.currentPlatform,
    );
  }
}
