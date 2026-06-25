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

    final result = await Process.run('flutter', [
      'create',
      '--org',
      config.androidPackage.substring(
        0,
        config.androidPackage.lastIndexOf('.'),
      ),
      config.appName,
    ], workingDirectory: parentDir);

    if (result.exitCode != 0) {
      throw Exception('Failed to create Flutter project:\n${result.stderr}');
    }

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
        : config.stateManagement == StateManagement.riverpod
        ? _getRiverpodDependencies()
        : _getBlocDependencies();
    final additionalDevDependencies =
        config.stateManagement == StateManagement.riverpod
        ? _getRiverpodDevDependencies()
        : '';

    // riverpod_generator 4.0.3 (the newest version compatible with the meta
    // 1.17.0 pinned by Flutter stable) caps analyzer at ^9.0.0. The latest
    // json_serializable/json_annotation require analyzer >=10, so for Riverpod
    // projects we pin the json packages to the highest analyzer-9-compatible
    // releases. GetX/Bloc keep the latest versions.
    final isRiverpod = config.stateManagement == StateManagement.riverpod;
    final jsonAnnotation = isRiverpod ? '4.11.0' : '^4.12.0';
    final jsonSerializable = isRiverpod ? '6.13.0' : '^6.14.0';
    final firebaseDependencies = config.useFirebase
        ? '''
  firebase_analytics: ^12.4.3
  firebase_core: ^4.11.0
  firebase_crashlytics: ^5.2.4
  firebase_messaging: ^16.4.1
  flutter_local_notifications: ^22.0.1
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
  dio_extended: ^1.0.19
$firebaseDependencies
  flutter_localizations:
    sdk: flutter
  freezed_annotation: ^3.1.0
  json_annotation: $jsonAnnotation
  path_provider: ^2.1.6
  secure_compressor: ^1.0.14
  xwidgets_pack: ^1.1.0
  xutils_pack: ^1.0.5

dev_dependencies:
  build_runner: ^2.15.0
  flutter_lints: ^6.0.0
  flutter_test:
    sdk: flutter
  freezed: ^3.2.5
  json_serializable: $jsonSerializable
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
    return '''  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2
  go_router: ^17.3.0''';
  }

  /// Get the Bloc dependencies for pubspec.yaml.
  static String _getBlocDependencies() {
    return '''  bloc: ^9.2.1
  flutter_bloc: ^9.1.1
  equatable: ^2.0.8
  go_router: ^17.3.0''';
  }

  /// Get the Riverpod dev_dependencies for pubspec.yaml.
  static String _getRiverpodDevDependencies() {
    // Pinned to 4.0.3 (not ^) because riverpod_generator >=4.0.4 requires
    // analyzer ^12 → meta ^1.18, which conflicts with the meta 1.17.0 pinned
    // by the current Flutter stable SDK. Bump only when Flutter stable ships
    // meta >=1.18.0.
    return '''  riverpod_generator: 4.0.3''';
  }
}
