/// Firebase packages written into a generated or updated `pubspec.yaml`.
///
/// Create and `xproject setup firebase` both read this list so the versions
/// cannot drift between the two paths.
abstract final class FirebaseDependencies {
  static const List<String> pubspecLines = <String>[
    '  firebase_analytics: ^13.0.1',
    '  firebase_core: ^5.1.0',
    '  firebase_crashlytics: ^6.0.1',
    '  firebase_messaging: ^17.0.1',
    '  flutter_local_notifications: ^22.3.3',
  ];

  /// Block inserted under `dependencies:` by [FlutterGenerator].
  static String get pubspecBlock => '${pubspecLines.join('\n')}\n';
}
