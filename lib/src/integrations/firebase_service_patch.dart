/// Upgrades generated [FirebaseService] when Firebase options / web support is added.
abstract final class FirebaseServicePatch {
  static String upgradeForFirebaseOptions({
    required String source,
    required String firebaseOptionsImport,
  }) {
    var result = source;

    if (!result.contains('firebase_options.dart') &&
        !result.contains(firebaseOptionsImport.trim())) {
      final anchor = "import 'package:flutter/foundation.dart';";
      if (result.contains(anchor)) {
        result = result.replaceFirst(
          anchor,
          '$anchor\n$firebaseOptionsImport',
        );
      }
    }

    if (result.contains('await Firebase.initializeApp();')) {
      result = result.replaceFirst(
        'await Firebase.initializeApp();',
        'await Firebase.initializeApp(\n'
        '      options: DefaultFirebaseOptions.currentPlatform,\n'
        '    );',
      );
    }

    return result;
  }
}
