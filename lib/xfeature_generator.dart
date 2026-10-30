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
import 'src/post_create_codegen.dart';

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
    final architecture = await detectArchitectureFromProject(
      root: root,
      stateManagement: currentStateManagement,
    );
    await FileGenerator.generateFeature(
      stateManagement: currentStateManagement,
      featureName: featureName,
      architecture: architecture,
    );
    logger.success('\n✅ $featureName template already generated!');
    await runBuildRunner(projectRoot: root);
  }

  /// Detect the state management (GetX or Riverpod) used in the project at [root].
  static Future<StateManagement> detectStateManagementFromProject(
    Directory root,
  ) async {
    final pubspecFile = File(path.join(root.path, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();

    final hasGet = RegExp(r'^\s*get:\s*', multiLine: true).hasMatch(content);
    final hasRiverpod = RegExp(
      r'^\s*flutter_riverpod:\s*',
      multiLine: true,
    ).hasMatch(content);
    final hasBloc = RegExp(
      r'^\s*flutter_bloc:\s*',
      multiLine: true,
    ).hasMatch(content);
    final hasProviderPackage = RegExp(
      r'^\s*provider:\s*',
      multiLine: true,
    ).hasMatch(content);

    if (hasGet &&
        !hasRiverpod &&
        !hasBloc &&
        !hasProviderPackage) {
      return StateManagement.getx;
    }
    if (hasRiverpod &&
        !hasGet &&
        !hasBloc &&
        !hasProviderPackage) {
      return StateManagement.riverpod;
    }
    if (hasBloc && !hasGet && !hasRiverpod && !hasProviderPackage) {
      return StateManagement.bloc;
    }
    if (hasProviderPackage && !hasGet && !hasRiverpod && !hasBloc) {
      return StateManagement.provider;
    }

    // Kalau keduanya ada (possible), pakai rule tambahan
    if (hasGet || hasRiverpod || hasBloc || hasProviderPackage) {
      // Prefer routing detection
      final hasGetMaterialApp = await _hasTextInLib(
        root.path,
        'GetMaterialApp',
      );
      if (hasGetMaterialApp) return StateManagement.getx;

      final hasProviderScope = await _hasTextInLib(root.path, 'ProviderScope');
      if (hasProviderScope) return StateManagement.riverpod;

      final hasBlocProvider = await _hasTextInLib(root.path, 'BlocProvider');
      if (hasBlocProvider) return StateManagement.bloc;

      final hasChangeNotifierProvider = await _hasTextInLib(
        root.path,
        'ChangeNotifierProvider',
      );
      if (hasChangeNotifierProvider) return StateManagement.provider;
    }

    throw Exception(
      'Cannot detect state management. '
      'No get/flutter_riverpod/flutter_bloc/provider dependency found.',
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

  static Future<StateManagementArchitecture?> detectArchitectureFromProject({
    required Directory root,
    required StateManagement stateManagement,
  }) async {
    if (stateManagement == StateManagement.getx ||
        stateManagement == StateManagement.provider) {
      return null;
    }

    final featuresDir = Directory(path.join(root.path, 'lib', 'features'));
    if (!featuresDir.existsSync()) return StateManagementArchitecture.simple;

    final entries = featuresDir.listSync().whereType<Directory>();

    for (final featureDir in entries) {
      final domainDir = Directory(path.join(featureDir.path, 'domain'));
      if (domainDir.existsSync()) return StateManagementArchitecture.clean;

      final dataRepositories = Directory(
        path.join(featureDir.path, 'data', 'repositories'),
      );
      if (dataRepositories.existsSync())
        return StateManagementArchitecture.clean;
    }

    // Fallback: detect clean providers/usecases in files
    if (stateManagement == StateManagement.riverpod) {
      final hasUsecase = await _hasTextInLib(root.path, 'Get');
      final hasRepository = await _hasTextInLib(root.path, 'Repository');
      if (hasUsecase && hasRepository) return StateManagementArchitecture.clean;
    }

    if (stateManagement == StateManagement.bloc) {
      final hasUsecase = await _hasTextInLib(root.path, 'Usecase');
      final hasRepository = await _hasTextInLib(root.path, 'Repository');
      if (hasUsecase && hasRepository) return StateManagementArchitecture.clean;
    }

    return StateManagementArchitecture.simple;
  }

  /// Run build_runner in the given [projectRoot] directory after feature generation.
  static Future<void> runBuildRunner({required Directory projectRoot}) async {
    stdout.writeln('\n⚙ Running build_runner...');

    try {
      await PostCreateCodegen.runBuildRunner(projectRoot.path);
    } on Exception catch (error) {
      stderr.writeln('❌ build_runner failed');
      stderr.writeln(error);
      return;
    }

    stdout.writeln('✅ build_runner completed');
  }
}
