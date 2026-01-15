import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

// If there are additional files in core/configs, add similar documentation comments at the top.
/// XProject Generator - Project Configuration
///
/// Defines the [ProjectConfig] class, which holds all configuration data
/// required to scaffold a new Flutter project using XProject Generator.
///
/// Includes project name, display name, package IDs, Firebase usage, and state management.
///
/// See README.md for more details.

enum StateManagement { getx, riverpod }

class ProjectConfig {
  ProjectConfig({
    required this.appName,
    required this.displayName,
    required this.androidPackage,
    required this.iosBundleId,
    required this.stateManagement,
    required this.useFirebase,
  });

  final String appName;
  final String displayName;
  final String androidPackage;
  final String iosBundleId;
  final StateManagement stateManagement;
  final bool useFirebase;

  // Name variants (derived from appName)
  String get appNamePascal => ReCase(appName).pascalCase;
  String get appNameCamel => ReCase(appName).camelCase;

  // Display
  String get appDisplayName => displayName;

  // Path
  String get projectPath => path.join(Directory.current.path, appName);

  // Environment configs
  String androidPackageForEnv(String env) {
    if (env == 'production') return androidPackage;
    return '$androidPackage.$env';
  }

  String iosBundleIdForEnv(String env) {
    if (env == 'production') return iosBundleId;
    return '$iosBundleId.$env';
  }

  List<String> get environments =>
      const ['development', 'staging', 'production'];
}
