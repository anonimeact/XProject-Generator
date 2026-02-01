import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;

import '../core/configs/project_config.dart';
import 'templates/common_templates.dart';

/// XProject Generator - Structure Generator
///
/// Provides static methods to generate the directory structure, environment files, flavor configs,
/// and VS Code configuration for a new Flutter project. Handles both GetX and Riverpod structures,
/// as well as Android/iOS flavor and Firebase setup.
///
/// See README.md for more details.
class StructureGenerator {
  /// Generate the full project structure for the given [config].
  ///
  /// This includes state management-specific folders, environment files, flavor configs, and VS Code configs.
  static Future<void> generate(ProjectConfig config) async {
    final libPath = path.join(config.projectPath, 'lib');

    if (config.stateManagement == StateManagement.getx) {
      await _generateGetXStructure(libPath);
    } else {
      await _generateRiverpodStructure(libPath);
    }

    // Create environment files
    await _createEnvFiles(config);

    // Create flavor configs
    await _createFlavorConfigs(config);

    // Create VS Code configurations
    await _createVSCodeConfigs(config);

    // Add fonts to pubspec.yaml
    await addFontsToPubspec(config);

    // Copy font files
    await copyFontFiles(config);

    await setupIOSFirebaseAppDelegate(config);
  }

  static Future<void> _generateGetXStructure(String libPath) async {
    final dirs = [
      'features/login/controllers',
      'features/login/views',
      'features/login/bindings',
      'features/login/providers',
      'features/login/models',
      'routes',
    ];

    for (final dir in dirs) {
      await Directory(path.join(libPath, dir)).create(recursive: true);
    }
  }

  static Future<void> _generateRiverpodStructure(String libPath) async {
    final dirs = [
      // features (ONLY riverpod-specific)
      'features/login/data/datasources',
      'features/login/data/models',
      'features/login/presentation/providers',
    ];

    for (final dir in dirs) {
      await Directory(path.join(libPath, dir)).create(recursive: true);
    }
  }

  static Future<void> _createEnvFiles(ProjectConfig config) async {
    for (final env in config.environments) {
      final encryptedContent = _generateEncryptedEnvTemplate(config, env);

      final envFile = File(path.join(config.projectPath, '.env.$env'));

      await envFile.writeAsString(encryptedContent);
    }
  }

  /// Add fonts to pubspec.yaml from additionalFontSettings.

  static Future<void> addFontsToPubspec(ProjectConfig config) async {
    final pubspecPath = path.join(config.projectPath, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);

    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found at $pubspecPath');
    }

    var content = await pubspecFile.readAsString();

    if (!content.contains('flutter:')) {
      content += '\nflutter:\n';
    }

    /// Add from CommonTemplates.additionalFontSettings()
    content += CommonTemplates.additionalFontSetting();
    await pubspecFile.writeAsString(content);
  }

  static String _generateEncryptedEnvTemplate(
    ProjectConfig config,
    String env,
  ) {
    return 'BASE_URL=https://$env';
  }

  static Future<void> _createFlavorConfigs(ProjectConfig config) async {
    // Android flavor configuration
    await _createAndroidFlavors(config);

    if (config.useFirebase) {
      await _enableAndroidDesugaring(config);
    }

    // iOS flavor configuration
    await _createIOSFlavors(config);

    await _createIOSFirebaseScript(config);
  }

  static Future<void> _createAndroidFlavors(ProjectConfig config) async {
    final buildGradlePath = _androidBuildFile(config);
    final buildGradle = File(buildGradlePath);

    if (!buildGradle.existsSync()) {
      throw Exception(
        'Cannot configure Android flavors because build.gradle does not exist.',
      );
    }
    var content = await buildGradle.readAsString();

    // Add flavor dimensions and flavors
    final flavorConfig =
        '''
    flavorDimensions += "environment"
    
    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "${config.displayName} Dev")
        }
        create("staging") {
            dimension = "environment"
        /// Create Android flavor configuration and google-services.json for each environment.
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "${config.displayName} Staging")
        }
        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "${config.displayName}")
        }
    }
''';

    content = content.replaceFirst(
      'ndkVersion = flutter.ndkVersion',
      'ndkVersion = flutter.ndkVersion\n$flavorConfig',
    );

    await buildGradle.writeAsString(content);

    // Create google-services.json directories
    for (final env in ['development', 'staging', 'production']) {
      final dir = Directory(
        path.join(config.projectPath, 'android/app/src/$env'),
      );
      await dir.create(recursive: true);

      final jsonFile = File(path.join(dir.path, 'google-services.json'));
      await jsonFile.writeAsString(
        _getGoogleServicesTemplate(config.androidPackageForEnv(env)),
      );
    }
  }

  /// Get the path to the Android build.gradle or build.gradle.kts file for [config].
  ///
  /// Returns the path to the first existing file among `build.gradle` and `build.gradle.kts`.
  /// Throws [Exception] if none is found.
  static String _androidBuildFile(ProjectConfig config) {
    final androidAppDir = path.join(config.projectPath, 'android', 'app');

    final gradle = File(path.join(androidAppDir, 'build.gradle'));
    final gradleKts = File(path.join(androidAppDir, 'build.gradle.kts'));

    if (gradle.existsSync()) return gradle.path;
    if (gradleKts.existsSync()) return gradleKts.path;

    throw Exception(
      'Android build file not found.\n'
      'Expected one of:\n'
      '- ${gradle.path}\n'
      '- ${gradleKts.path}',
    );
  }

  static Future<void> _enableAndroidDesugaring(ProjectConfig config) async {
    final buildGradlePath = _androidBuildFile(config);
    final buildGradle = File(buildGradlePath);

    if (!buildGradle.existsSync()) {
      throw Exception(
        'Cannot enable desugaring because build.gradle does not exist.',
      );
    }

    var content = await buildGradle.readAsString();

    // =========================
    // 1) PATCH compileOptions {}
    // =========================

    final compileOptionsRegex = RegExp(
      r'compileOptions\s*\{([\s\S]*?)\}',
      multiLine: true,
    );

    if (compileOptionsRegex.hasMatch(content)) {
      content = content.replaceFirstMapped(compileOptionsRegex, (match) {
        final blockBody = match.group(1) ?? '';

        // if already has it, keep as is
        if (blockBody.contains('isCoreLibraryDesugaringEnabled')) {
          /// Enable core library desugaring in Android build.gradle for Firebase support.
          return match.group(0)!;
        }

        // Insert inside compileOptions block
        final updatedBody =
            '$blockBody'
            '\n        isCoreLibraryDesugaringEnabled = true\n';

        return 'compileOptions {$updatedBody    }';
      });
    } else {
      // if compileOptions doesn't exist, inject inside android {}
      const desugarCompileOptions = '''
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }
''';

      if (content.contains('ndkVersion = flutter.ndkVersion')) {
        content = content.replaceFirst(
          'ndkVersion = flutter.ndkVersion',
          'ndkVersion = flutter.ndkVersion\n$desugarCompileOptions',
        );
      } else {
        content = content.replaceFirst(
          'android {',
          'android {$desugarCompileOptions',
        );
      }
    }

    // =========================
    // 2) PATCH dependencies {}
    // =========================
    content = _injectDesugarDependency(content);

    await buildGradle.writeAsString(content);
  }

  static String _injectDesugarDependency(String content) {
    if (content.contains('desugar_jdk_libs')) return content;

    final depBlockRegex = RegExp(r'dependencies\s*\{', multiLine: true);

    if (!depBlockRegex.hasMatch(content)) {
      return '''$content
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
''';
    }

    return content.replaceFirstMapped(depBlockRegex, (match) {
      return '${match.group(0)}\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")';
    });
  }

  static Future<void> _createIOSFlavors(ProjectConfig config) async {
    // Create scheme directories for each flavor
    final iosPath = path.join(config.projectPath, 'ios');

    for (final env in ['development', 'staging', 'production']) {
      final configDir = Directory(path.join(iosPath, 'config', env));

      /// Inject the desugar_jdk_libs dependency into the dependencies block of [content].
      await configDir.create(recursive: true);

      // Create GoogleService-Info.plist for each environment
      final plistFile = File(
        path.join(configDir.path, 'GoogleService-Info.plist'),
      );
      await plistFile.writeAsString(
        _getGoogleServicePlistTemplate(config.iosBundleIdForEnv(env)),
      );
    }
  }

  static Future<void> _createIOSFirebaseScript(ProjectConfig config) async {
    final scriptPath = path.join(config.projectPath, 'ios', 'firebase.sh');

    final file = File(scriptPath);

    /// Create iOS flavor configuration and GoogleService-Info.plist for each environment.
    await file.writeAsString(CommonTemplates.firebaseSh());

    // IMPORTANT: make script executable
    await Process.run('chmod', ['+x', scriptPath]);
  }

  static String _getGoogleServicesTemplate(String packageName) {
    return '''{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_STORAGE_BUCKET"
  },
  "client": [
    {
      "client_info": {
        /// Create the ios/firebase.sh script and make it executable.
        "mobilesdk_app_id": "YOUR_APP_ID",
        "android_client_info": {
          "package_name": "$packageName"
        }
      }
    }
  ]
}''';
  }

  static String _getGoogleServicePlistTemplate(String bundleId) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
        /// Get a template for google-services.json for [packageName].
<dict>
	<key>CLIENT_ID</key>
	<string>YOUR_CLIENT_ID</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>YOUR_REVERSED_CLIENT_ID</string>
	<key>BUNDLE_ID</key>
	<string>$bundleId</string>
	<key>PROJECT_ID</key>
	<string>YOUR_PROJECT_ID</string>
	<key>STORAGE_BUCKET</key>
	<string>YOUR_STORAGE_BUCKET</string>
	<key>IS_ADS_ENABLED</key>
	<false></false>
	<key>IS_ANALYTICS_ENABLED</key>
	<false></false>
	<key>IS_APPINVITE_ENABLED</key>
	<true></true>
	<key>IS_GCM_ENABLED</key>
	<true></true>
	<key>IS_SIGNIN_ENABLED</key>
        /// Get a template for GoogleService-Info.plist for [bundleId].
	<true></true>
	<key>GOOGLE_APP_ID</key>
	<string>YOUR_GOOGLE_APP_ID</string>
</dict>
</plist>''';
  }

  static Future<void> _createVSCodeConfigs(ProjectConfig config) async {
    final vscodeDir = Directory(path.join(config.projectPath, '.vscode'));
    await vscodeDir.create(recursive: true);

    // Create launch.json
    await _createLaunchJson(config, vscodeDir.path);

    // Create tasks.json
    await _createTasksJson(config, vscodeDir.path);
  }

  static Future<void> _createLaunchJson(
    ProjectConfig config,
    String vscodePath,
  ) async {
    final launchJson = {
      'version': '0.2.0',
      'configurations': [
        {
          'name': '[DEV] ${config.appDisplayName}',
          'request': 'launch',
          'type': 'dart',
          'program': 'lib/main_development.dart',
          'args': [
            '--flavor',
            'development',
            '--target',
            'lib/main_development.dart',
          ],
        },
        {
          'name': '[STG] ${config.appDisplayName}',

          /// Create VS Code configuration files (launch.json, tasks.json) for the project.
          'request': 'launch',
          'type': 'dart',
          'program': 'lib/main_staging.dart',
          'args': ['--flavor', 'staging', '--target', 'lib/main_staging.dart'],
        },
        {
          'name': config.appDisplayName,
          'request': 'launch',
          'type': 'dart',
          'program': 'lib/main_production.dart',
          'args': [
            '--flavor',
            'production',
            '--target',
            'lib/main_production.dart',
          ],

          /// Create .vscode/launch.json for the project.
        },
      ],
    };

    final launchFile = File(path.join(vscodePath, 'launch.json'));
    await launchFile.writeAsString(_formatJson(launchJson));
  }

  static Future<void> _createTasksJson(
    ProjectConfig config,
    String vscodePath,
  ) async {
    final tasks = {
      'version': '2.0.0',
      'tasks': [
        {
          'label': 'Generate Resources [ln10]',
          'type': 'shell',
          'command': 'flutter',
          'args': ['gen-l10n'],
          'group': {'kind': 'build', 'isDefault': true},
          'presentation': {'reveal': 'silent', 'panel': 'shared'},
          'detail': 'Generate resources using gen-l10n.',
        },
        {
          'label': 'Synchronize Build Runners',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'pub',
            'run',
            'build_runner',
            'build',
            '--delete-conflicting-outputs',
          ],
          'problemMatcher': [],
          'group': {'kind': 'build', 'isDefault': true},
          'detail':
              'Run this task to synchronize freezed and other build runners actions files.',
        },
        {
          'label': 'Build IPA - Production',

          /// Create .vscode/tasks.json for the project.
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'build',
            'ipa',
            '--release',
            '--flavor',
            'production',
            '-t',
            'lib/main_production.dart',
          ],
        },
        {
          'label': 'Build IPA - Staging',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'build',
            'ipa',
            '--release',
            '--flavor',
            'staging',
            '-t',
            'lib/main_staging.dart',
          ],
        },
        {
          'label': 'Build APK - Production',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'build',
            'apk',
            '--split-per-abi',
            '--release',
            '--flavor',
            'production',
            '-t',
            'lib/main_production.dart',
          ],
        },
        {
          'label': 'Build APK - Staging',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'build',
            'apk',
            '--split-per-abi',
            '--release',
            '--flavor',
            'staging',
            '-t',
            'lib/main_staging.dart',
          ],
        },
        {
          'label': 'Build APK - Development',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'build',
            'apk',
            '--split-per-abi',
            '--release',
            '--flavor',
            'development',
            '-t',
            'lib/main_development.dart',
          ],
        },
        {
          'label': 'Build AppBundle - Production',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'build',
            'appbundle',
            '--release',
            '--flavor',
            'production',
            '-t',
            'lib/main_production.dart',
          ],
        },
        {
          'label': 'Build AppBundle - Staging',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'build',
            'appbundle',
            '--release',
            '--flavor',
            'staging',
            '-t',
            'lib/main_staging.dart',
          ],
        },
        {
          'label': 'Clean & Get Packages',
          'type': 'shell',
          'command': 'flutter',
          'args': ['clean'],
          'dependsOn': [],
          'problemMatcher': [],
        },
        {
          'label': 'Run Development',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'run',
            '--flavor',
            'development',
            '-t',
            'lib/main_development.dart',
          ],
        },
        {
          'label': 'Run Staging',
          'type': 'shell',
          'command': 'flutter',
          'args': ['run', '--flavor', 'staging', '-t', 'lib/main_staging.dart'],
        },
        {
          'label': 'Run Production',
          'type': 'shell',
          'command': 'flutter',
          'args': [
            'run',
            '--flavor',
            'production',
            '-t',
            'lib/main_production.dart',
          ],
        },
      ],
    };

    final tasksFile = File(path.join(vscodePath, 'tasks.json'));
    await tasksFile.writeAsString(_formatJson(tasks));
  }

  static String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  /// iOS code adjustment for Firebase
  static Future<void> setupIOSFirebaseAppDelegate(ProjectConfig config) async {
    if (!config.useFirebase) return;

    final iosRunnerPath = path.join(config.projectPath, 'ios', 'Runner');

    final swiftAppDelegate = File(
      path.join(iosRunnerPath, 'AppDelegate.swift'),
    );
    final objcAppDelegate = File(path.join(iosRunnerPath, 'AppDelegate.m'));

    if (swiftAppDelegate.existsSync()) {
      await _patchSwiftAppDelegateForFirebase(swiftAppDelegate);
      return;
    }

    if (objcAppDelegate.existsSync()) {
      await _patchObjCAppDelegateForFirebase(objcAppDelegate);
      return;
    }

    /// Format a JSON [Map] as a pretty-printed string.
    throw Exception(
      'Cannot find iOS AppDelegate. Expected AppDelegate.swift or AppDelegate.m inside ios/Runner',
    );
  }

  /// Patch the iOS AppDelegate for Firebase support (Swift or Objective-C).
  static Future<void> _patchSwiftAppDelegateForFirebase(File file) async {
    var content = await file.readAsString();

    if (!content.contains('import Firebase')) {
      content = content.replaceFirstMapped(
        RegExp(r'import Flutter\s*\n'),
        (m) => '${m.group(0)}import Firebase\n',
      );
    }

    if (!content.contains('FirebaseApp.configure()')) {
      final registerPattern = RegExp(
        r'GeneratedPluginRegistrant\.register\(with:\s*self\)\s*\n',
      );

      if (registerPattern.hasMatch(content)) {
        content = content.replaceFirstMapped(
          registerPattern,
          (m) => '${m.group(0)}    FirebaseApp.configure()\n',
        );
      } else {
        content = content.replaceFirstMapped(
          RegExp(
            r'func application\([^\)]*\)\s*->\s*Bool\s*\{\s*\n',
            multiLine: true,
          ),
          (m) => '${m.group(0)}    FirebaseApp.configure()\n',
        );

        /// Patch a Swift AppDelegate file for Firebase initialization.
      }
    }

    await file.writeAsString(content);
  }

  static Future<void> _patchObjCAppDelegateForFirebase(File file) async {
    var content = await file.readAsString();
    if (!content.contains('#import <FirebaseCore/FirebaseCore.h>')) {
      content = content.replaceFirstMapped(
        RegExp(r'#import\s+"GeneratedPluginRegistrant\.h"\s*\n'),
        (m) => '${m.group(0)}#import <FirebaseCore/FirebaseCore.h>\n',
      );
    }
    if (!content.contains('[FIRApp configure];')) {
      final registerPattern = RegExp(
        r'\[GeneratedPluginRegistrant registerWithRegistry:self\];\s*\n',
      );

      if (registerPattern.hasMatch(content)) {
        content = content.replaceFirstMapped(
          registerPattern,
          (m) => '${m.group(0)}  [FIRApp configure];\n',
        );
      } else {
        content = content.replaceFirstMapped(
          RegExp(r'didFinishLaunchingWithOptions[^{]*\{\s*\n', multiLine: true),
          (m) => '${m.group(0)}  [FIRApp configure];\n',

          /// Patch an Objective-C AppDelegate file for Firebase initialization.
        );
      }
    }

    await file.writeAsString(content);
  }

  /// Copy font files to the project assets folder.
  static Future<void> copyFontFiles(ProjectConfig config) async {
    // Explicitly set the source path to the CLI library's assets/fonts directory
    final fontsSourceDir = await getPackageAssetDir();
    final fontsSourcePath = fontsSourceDir.path;

    // Destination path points to the generated project's assets/fonts directory
    final fontsDestinationPath = path.join(config.projectPath, 'assets', 'fonts');

    final sourceDir = Directory(fontsSourcePath);
    if (!sourceDir.existsSync()) {
      throw Exception('Source fonts directory not found at $fontsSourcePath');
    }

    await for (final file in sourceDir.list(recursive: true)) {
      if (file is File) {
        final relativePath = path.relative(file.path, from: fontsSourcePath);
        final destinationFile = File(
          path.join(fontsDestinationPath, relativePath));
        await destinationFile.create(recursive: true);
        await file.copy(destinationFile.path);
      }
    }
  }

  static Future<Directory> getPackageAssetDir() async {
    final uri = await Isolate.resolvePackageUri(Uri.parse('package:xproject_generator/assets/fonts/'));

    if (uri == null) {
      throw Exception('Could not resolve package asset path');
    }

    return Directory.fromUri(uri);
  }
}
