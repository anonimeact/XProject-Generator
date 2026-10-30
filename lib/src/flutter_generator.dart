import 'dart:io';

import 'package:path/path.dart' as path;

import '../core/configs/app_icon_config.dart';
import '../core/configs/project_config.dart';
import 'integrations/firebase_dependencies.dart';
import 'templates/common_templates.dart';

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
      '--platforms',
      config.flutterPlatformsArg,
      config.appName,
    ], workingDirectory: parentDir);

    if (result.exitCode != 0) {
      throw Exception('Failed to create Flutter project:\n${result.stderr}');
    }

    final projectDir = Directory(config.projectPath);
    if (!projectDir.existsSync()) {
      throw Exception(
        'Flutter project was created, but not in expected location.\n'
        'Expected: ${config.projectPath}',
      );
    }

    if (config.targetsAndroid) {
      final androidDir = Directory(path.join(config.projectPath, 'android'));
      if (!androidDir.existsSync()) {
        throw Exception(
          'Flutter project missing android/ despite Android being selected.',
        );
      }
    }

    await _updatePubspec(config);
  }

  /// Update the pubspec.yaml file for the project described by [config].
  ///
  /// Adds dependencies for the selected state management and Firebase if enabled.
  static Future<void> _updatePubspec(ProjectConfig config) async {
    final pubspecPath = '${config.projectPath}/pubspec.yaml';
    final pubspecFile = File(pubspecPath);

    final additionalDependencies = switch (config.stateManagement) {
      StateManagement.getx => _getGetXDependencies(),
      StateManagement.riverpod => _getRiverpodDependencies(),
      StateManagement.provider => _getProviderDependencies(),
      StateManagement.bloc => _getBlocDependencies(),
    };
    final additionalDevDependencies =
        config.stateManagement == StateManagement.riverpod
        ? _getRiverpodDevDependencies()
        : '';

    final firebaseDependencies = config.useFirebase
        ? '\n${FirebaseDependencies.pubspecBlock}'
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
  dio_extended: ^2.0.0
$firebaseDependencies
  flutter_localizations:
    sdk: flutter
  freezed_annotation: ^3.1.0
  json_annotation: ^4.12.0
  path_provider: ^2.1.6
  secure_compressor: ^1.0.16
  xwidgets_pack: ^1.3.0
  xutils_pack: ^1.0.5

dev_dependencies:
  build_runner: ^2.16.0
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.4
  flutter_test:
    sdk: flutter
  freezed: ^4.0.3
  json_serializable: ^6.15.2
$additionalDevDependencies

flutter:
  uses-material-design: true
  generate: true
  assets:
    - .env.development
    - .env.staging
    - .env.production
    - ${AppIconConfig.projectAssetPath}
''';

    await pubspecFile.writeAsString(
      content + CommonTemplates.flutterLauncherIconsBlock(),
    );
  }

  /// Get the GetX dependencies for pubspec.yaml.
  static String _getGetXDependencies() {
    return '''  get: ^4.7.3''';
  }

  /// Get the Riverpod dependencies for pubspec.yaml.
  static String _getRiverpodDependencies() {
    return '''  flutter_riverpod: ^3.4.3
  riverpod_annotation: ^4.0.7
  go_router: ^18.1.1''';
  }

  /// Get the Provider dependencies for pubspec.yaml.
  static String _getProviderDependencies() {
    return '''  provider: ^6.1.5+1
  go_router: ^18.1.1''';
  }

  /// Get the Bloc dependencies for pubspec.yaml.
  static String _getBlocDependencies() {
    return '''  bloc: ^9.2.1
  flutter_bloc: ^9.1.1
  equatable: ^3.0.0
  go_router: ^18.1.1''';
  }

  /// Get the Riverpod dev_dependencies for pubspec.yaml.
  static String _getRiverpodDevDependencies() {
    // build_runner ^2.17.x requires build ^5.x, which riverpod_generator does not
    // support yet; use ^2.16.0 (latest compatible with riverpod_generator).
    return '''  riverpod_generator: ^4.0.9''';
  }
}
