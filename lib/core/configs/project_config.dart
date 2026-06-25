import 'dart:io';
import 'package:path/path.dart' as path;

// If there are additional files in core/configs, add similar documentation comments at the top.
/// XProject Generator - Project Configuration
///
/// Defines the [ProjectConfig] class, which holds all configuration data
/// required to scaffold a new Flutter project using XProject Generator.
///
/// Includes project name, display name, package IDs, Firebase usage, and state management.
///
/// See README.md for more details.

enum StateManagement { getx, riverpod, bloc }

enum StateManagementArchitecture { simple, clean }

class ProjectConfig {
  ProjectConfig({
    required this.appName,
    required this.displayName,
    required this.androidPackage,
    required this.iosBundleId,
    required this.stateManagement,
    required this.useFirebase,
    required this.useSecretKey,
    this.blocArchitecture,
    this.riverpodArchitecture,
  });

  final String appName;
  final String displayName;
  final String androidPackage;
  final String iosBundleId;
  final StateManagement stateManagement;
  final bool useFirebase;

  /// Whether to use SecureCompressor + secret_key_scrypt_generator for encrypted
  /// env files and encrypted local storage. When false, env files are read as plain
  /// text and StorageHelper stores data without key-value encryption.
  final bool useSecretKey;

  final StateManagementArchitecture? blocArchitecture;
  final StateManagementArchitecture? riverpodArchitecture;

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

  List<String> get environments => const [
    'development',
    'staging',
    'production',
  ];
}
