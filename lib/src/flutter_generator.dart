import 'dart:io';

import 'package:path/path.dart' as path;

import '../core/configs/project_config.dart';

/// XProject Generator - Flutter Project Creator
///
/// Provides static methods to create a new Flutter project using the Flutter CLI,
/// update the pubspec.yaml with required dependencies, and handle state management and Firebase setup.
///
/// See README.md for more details.
class FlutterGenerator {
  /// Create a new Flutter project using the Flutter CLI and the given [config].
  ///
  /// Throws an [Exception] if the project creation fails or the expected directory is not found.
  static Future<void> create(ProjectConfig config) async {
    final parentDir = Directory.current.path;

    final result = await Process.run(
      'flutter',
      [
        'create',
        '--org',
        config.androidPackage.substring(
          0,
          config.androidPackage.lastIndexOf('.'),
        ),
        config.appName,
      ],
      workingDirectory: parentDir, // 🔥 INI KUNCI UTAMA
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to create Flutter project:\n${result.stderr}');
    }

    // ✅ SEKARANG PATH INI VALID
    final androidDir = Directory(path.join(config.projectPath, 'android'));

    if (!androidDir.existsSync()) {
      throw Exception(
        'Flutter project was created, but not in expected location.\n'
        'Expected: ${config.projectPath}',
      );
    }

    await _updatePubspec(config);
  }

  /// Update the pubspec.yaml file for the project described by [config].
  ///
  /// Adds dependencies for the selected state management and Firebase if enabled.
  static Future<void> _updatePubspec(ProjectConfig config) async {
    final pubspecPath = '${config.projectPath}/pubspec.yaml';
    final pubspecFile = File(pubspecPath);

    final additionalDependencies =
        config.stateManagement == StateManagement.getx
        ? _getGetXDependencies()
        : _getRiverpodDependencies();
    final additionalDevDependencies =
        config.stateManagement == StateManagement.getx
        ? ''
        : _getRiverpodDevDependencies();
    final firebaseDependencies = config.useFirebase
        ? '''
  firebase_analytics: ^12.1.0
  firebase_core: ^4.3.0
  firebase_crashlytics: ^5.0.6
  firebase_messaging: ^16.1.0
  flutter_local_notifications: ^19.5.0
  '''
        : '';

    final content =
        '''
name: ${config.appName}
description: A new Flutter project
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>3.10.0'

dependencies:
  flutter:
    sdk: flutter
$additionalDependencies
  dio_extended: ^1.0.15
$firebaseDependencies
  flutter_localizations:
    sdk: flutter
  freezed_annotation: ^3.0.0
  json_annotation: ^4.9.0
  path_provider: ^2.1.5
  secure_compressor: ^1.0.14
  xwidgets_pack: ^1.0.9
  xutils_pack: ^1.0.5

dev_dependencies:
  build_runner: ^2.5.4
  flutter_lints: ^5.0.0
  flutter_test:
    sdk: flutter
  freezed: ^3.0.6
  json_serializable: ^6.9.5
$additionalDevDependencies

flutter:
  uses-material-design: true
  generate: true
  assets:
    - .env.development
    - .env.staging
    - .env.production
''';

    await pubspecFile.writeAsString(content);
  }

  /// Get the GetX dependencies for pubspec.yaml.
  static String _getGetXDependencies() {
    return '''  get: ^4.7.3''';
  }

  /// Get the Riverpod dependencies for pubspec.yaml.
  static String _getRiverpodDependencies() {
    return '''  flutter_riverpod: ^3.1.0
  riverpod_annotation: ^4.0.0
  go_router: ^17.0.1''';
  }

  /// Get the Riverpod dev_dependencies for pubspec.yaml.
  static String _getRiverpodDevDependencies() {
    return '''  riverpod_generator: ^4.0.0+1''';
  }
}
