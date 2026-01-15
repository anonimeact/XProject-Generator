
/// XProject Generator - Feature Generator
///
/// Provides functionality to generate a new feature template in an existing Flutter project.
/// Automatically detects the state management (GetX or Riverpod) used in the project and
/// generates the appropriate template. Also runs build_runner after feature generation.
///
/// Usage:
///   FeatureGenerator().add('feature_name');
///
/// See README.md for more details.
library;

import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import 'core/configs/project_config.dart';
import 'src/file_generator.dart';

/// Main class for generating new feature templates in an existing Flutter project.
class FeatureGenerator {
  final Logger logger = Logger();
  /// Generate a new feature template with the given [featureName].
  ///
  /// Detects the state management used in the project and generates the appropriate template.
  /// Runs build_runner after generation.
  Future<void> add(String featureName) async {
    logger.info('\n📦 Generating new feature template...');
    final root = findFlutterProjectRoot();
    final currentStateManagement = await detectStateManagementFromProject(root);
    await FileGenerator.generateFeature(stateManagement: currentStateManagement, featureName: featureName);
    logger.success('\n✅ $featureName template already generated!');
    await runBuildRunner(projectRoot: root);
  }

  /// Detect the state management (GetX or Riverpod) used in the project at [root].
  static Future<StateManagement> detectStateManagementFromProject(Directory root) async {
    final pubspecFile = File(path.join(root.path, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();

    final hasGet = RegExp(r'^\s*get:\s*', multiLine: true).hasMatch(content);
    final hasRiverpod = RegExp(r'^\s*flutter_riverpod:\s*', multiLine: true).hasMatch(content);

    if (hasGet && !hasRiverpod) return StateManagement.getx;
    if (hasRiverpod && !hasGet) return StateManagement.riverpod;

    // Kalau keduanya ada (possible), pakai rule tambahan
    if (hasGet && hasRiverpod) {
      // Prefer routing detection
      final hasGetMaterialApp = await _hasTextInLib(root.path, 'GetMaterialApp');
      if (hasGetMaterialApp) return StateManagement.getx;

      final hasGoRouter = await _hasTextInLib(root.path, 'GoRouter');
      if (hasGoRouter) return StateManagement.riverpod;
    }

    throw Exception(
      'Cannot detect state management. '
      'No get/flutter_riverpod dependency found.',
    );
  }

  /// Find the root directory of the Flutter project by searching for pubspec.yaml and lib/.
  static Directory findFlutterProjectRoot() {
    Directory dir = Directory.current;

    while (true) {
      final pubspec = File(path.join(dir.path, 'pubspec.yaml'));
      final libDir = Directory(path.join(dir.path, 'lib'));

      if (pubspec.existsSync() && libDir.existsSync()) {
        return dir;
      }

      final parent = dir.parent;
      if (parent.path == dir.path) {
        throw Exception(
          'Flutter project root not found. '
          'Make sure you run this command inside a Flutter project.',
        );
      }

      dir = parent;
    }
  }

  /// Search for [text] in all Dart files under lib/ in [rootPath].
  static Future<bool> _hasTextInLib(String rootPath, String text) async {
    final libDir = Directory(path.join(rootPath, 'lib'));
    if (!libDir.existsSync()) return false;

    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final data = await entity.readAsString();
        if (data.contains(text)) return true;
      }
    }
    return false;
  }

  /// Run build_runner in the given [projectRoot] directory after feature generation.
  static Future<void> runBuildRunner({required Directory projectRoot}) async {
    stdout.writeln('\n⚙ Running build_runner...');

    final result = await Process.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      workingDirectory: projectRoot.path,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      stderr.writeln('❌ build_runner failed');
      stderr.writeln(result.stderr);
      return;
    }

    stdout.writeln('✅ build_runner completed');
    stdout.writeln(result.stdout);
  }
}
