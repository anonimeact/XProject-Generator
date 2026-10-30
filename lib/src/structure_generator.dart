import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;

import '../core/configs/app_icon_config.dart';
import '../core/configs/project_config.dart';
import 'android_gradle_patches.dart';
import 'integrations/firebase_native_files.dart';
import 'integrations/firebase_shared_support.dart';
import 'integrations/setup_change_report.dart';
import 'templates/common_templates.dart';
import 'vscode_config_builder.dart';

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
    } else if (config.stateManagement == StateManagement.riverpod) {
      if (config.riverpodArchitecture == StateManagementArchitecture.clean) {
        await _generateRiverpodCleanStructure(libPath);
      } else {
        await _generateRiverpodStructure(libPath);
      }
    } else if (config.stateManagement == StateManagement.provider) {
      await _generateProviderStructure(libPath);
    } else {
      if (config.blocArchitecture == StateManagementArchitecture.clean) {
        await _generateBlocCleanStructure(libPath);
      } else {
        await _generateBlocStructure(libPath);
      }
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

    // Default launcher icon (Anonimeact logo → assets/icons/app_icon.png)
    await copyDefaultAppIcon(config);
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

  static Future<void> _generateRiverpodCleanStructure(String libPath) async {
    final dirs = [
      'features/login/data/datasources',
      'features/login/data/models',
      'features/login/data/repositories',
      'features/login/domain/entities',
      'features/login/domain/repositories',
      'features/login/domain/usecases',
      'features/login/presentation/providers',
      'features/login/presentation/views',
      'features/home/data/datasources',
      'features/home/data/models',
      'features/home/data/repositories',
      'features/home/domain/entities',
      'features/home/domain/repositories',
      'features/home/domain/usecases',
      'features/home/presentation/providers',
      'features/home/presentation/views',
      'features/splash/presentation/providers',
      'features/splash/presentation/views',
    ];

    for (final dir in dirs) {
      await Directory(path.join(libPath, dir)).create(recursive: true);
    }
  }

  static Future<void> _generateProviderStructure(String libPath) async {
    final dirs = [
      'features/splash/presentation/notifiers',
      'features/splash/presentation/views',
      'features/login/data/datasources',
      'features/login/data/models',
      'features/login/presentation/notifiers',
      'features/login/presentation/views',
      'features/home/data/datasources',
      'features/home/data/models',
      'features/home/presentation/notifiers',
      'features/home/presentation/views',
      'routes',
    ];

    for (final dir in dirs) {
      await Directory(path.join(libPath, dir)).create(recursive: true);
    }
  }

  static Future<void> _generateBlocStructure(String libPath) async {
    final dirs = [
      'features/splash/presentation/bloc',
      'features/splash/presentation/views',
      'features/login/data/datasources',
      'features/login/data/models',
      'features/login/presentation/bloc',
      'features/login/presentation/views',
      'features/home/data/datasources',
      'features/home/data/models',
      'features/home/presentation/bloc',
      'features/home/presentation/views',
      'routes',
    ];

    for (final dir in dirs) {
      await Directory(path.join(libPath, dir)).create(recursive: true);
    }
  }

  static Future<void> _generateBlocCleanStructure(String libPath) async {
    final dirs = [
      'features/splash/presentation/bloc',
      'features/splash/presentation/views',
      'features/login/data/datasources',
      'features/login/data/models',
      'features/login/data/repositories',
      'features/login/domain/entities',
      'features/login/domain/repositories',
      'features/login/domain/usecases',
      'features/login/presentation/bloc',
      'features/login/presentation/views',
      'features/home/data/datasources',
      'features/home/data/models',
      'features/home/data/repositories',
      'features/home/domain/entities',
      'features/home/domain/repositories',
      'features/home/domain/usecases',
      'features/home/presentation/bloc',
      'features/home/presentation/views',
      'routes',
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

  /// Ensures Android and iOS product flavors exist for [config].
  ///
  /// Safe to run on an existing project: a `productFlavors` block that is
  /// already present is not duplicated. When [ProjectConfig.useFirebase] is
  /// set, [applyFirebaseSupport] runs afterwards.
  static Future<void> ensureFlavorConfigs(ProjectConfig config) {
    return _createFlavorConfigs(config);
  }

  static Future<void> _createFlavorConfigs(ProjectConfig config) async {
    if (config.targetsAndroid) {
      await _createAndroidFlavors(config);
      await _ensureAndroidGradleProperties(config);
    }

    if (config.useFirebase) {
      await applyFirebaseSupport(config);
    }
  }

  /// Adds Firebase native pieces that `xproject create` writes when Firebase
  /// is accepted at creation time.
  ///
  /// Placeholder `google-services.json` and `GoogleService-Info.plist` files
  /// are created only when missing, so a real download from Firebase Console
  /// is never replaced. Gradle plugin lines and the iOS AppDelegate patch are
  /// inserted only when absent.
  static Future<SetupChangeReport> applyFirebaseSupport(
    ProjectConfig config,
  ) async {
    final report = SetupChangeReport();
    if (!config.useFirebase) {
      return report;
    }

    if (config.targetsAndroid) {
      final gradlePath = _androidBuildFile(config);
      final gradleFile = File(gradlePath);
      final beforeDesugar = await gradleFile.readAsString();
      await _enableAndroidDesugaring(config);
      final afterDesugar = await gradleFile.readAsString();
      if (beforeDesugar != afterDesugar) {
        report.written.add(
          '${path.relative(gradlePath, from: config.projectPath)} (desugaring)',
        );
      }
      await _ensureFirebaseGradlePlugins(config, report);
      await _writeAndroidGoogleServicesPlaceholders(config, report);
    }

    if (config.targetsIos) {
      await _createIOSFlavors(config, report);
      await _createIOSFirebaseScript(config, report);
      final changedDelegate = await _patchIosAppDelegate(config);
      if (changedDelegate) {
        report.written.add('ios AppDelegate FirebaseApp.configure()');
      } else {
        report.skipped.add('ios AppDelegate');
      }
    }

    if (!config.targetsAndroid && !config.targetsIos) {
      if (FirebaseSharedSupport.includeWebOptions(config)) {
        report.notes.add(
          'Web Firebase placeholders were added under lib/firebase_options.dart '
          'and web/firebase-messaging-sw.js when missing. Replace YOUR_* values '
          'from Firebase Console (Web app) or run flutterfire configure.',
        );
      } else {
        report.notes.add(
          'No Android or iOS target. Native Firebase files were not created. '
          'Add the web platform (or Android/iOS) and finish Firebase config in GUIDE.md.',
        );
      }
    }

    await FirebaseSharedSupport.apply(
      config,
      report,
      firebaseServiceImport: "import '../../../firebase_options.dart';",
    );

    return report;
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
    final isKotlinDsl = buildGradlePath.endsWith('.kts');

    content = ensureBuiltInKotlinAppGradle(
      content,
      isKotlinDsl: isKotlinDsl,
    );
    content = ensureAndroidResValuesEnabled(
      content,
      isKotlinDsl: isKotlinDsl,
    );

    if (!content.contains('productFlavors')) {
      final flavorConfig =
          '''
    flavorDimensions += "environment"
    
    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".development"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "${config.displayName} Dev")
        }
        create("staging") {
            dimension = "environment"
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
    }

    await buildGradle.writeAsString(content);
    await _patchAndroidManifestAppName(config);
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

    final isKotlinDsl = buildGradlePath.endsWith('.kts');
    var content = await buildGradle.readAsString();
    content = patchAndroidDesugaring(content, isKotlinDsl: isKotlinDsl);

    await buildGradle.writeAsString(content);
  }

  static Future<void> _ensureAndroidGradleProperties(ProjectConfig config) async {
    final propsPath = path.join(config.projectPath, 'android', 'gradle.properties');
    final propsFile = File(propsPath);

    if (!propsFile.existsSync()) {
      throw Exception(
        'Cannot configure Android gradle.properties because the file does not exist.',
      );
    }

    var content = await propsFile.readAsString();
    content = ensureGradlePropertiesFlags(content);
    await propsFile.writeAsString(content);
  }

  static Future<void> _patchAndroidManifestAppName(ProjectConfig config) async {
    final manifestPath = path.join(
      config.projectPath,
      'android',
      'app',
      'src',
      'main',
      'AndroidManifest.xml',
    );
    final manifestFile = File(manifestPath);

    if (!manifestFile.existsSync()) {
      return;
    }

    var content = await manifestFile.readAsString();
    content = patchAndroidManifestAppLabel(content);
    await manifestFile.writeAsString(content);
  }

  static Future<void> _createIOSFlavors(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    final iosPath = path.join(config.projectPath, 'ios');

    for (final env in config.environments) {
      final configDir = Directory(path.join(iosPath, 'config', env));
      await configDir.create(recursive: true);

      final plistFile = File(
        path.join(configDir.path, 'GoogleService-Info.plist'),
      );
      final relative = path.join('ios', 'config', env, 'GoogleService-Info.plist');
      if (plistFile.existsSync()) {
        report.skipped.add(relative);
        continue;
      }
      await plistFile.writeAsString(
        FirebaseNativeFiles.googleServiceInfoPlist(config.iosBundleIdForEnv(env)),
      );
      report.written.add(relative);
    }
  }

  static Future<void> _createIOSFirebaseScript(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    final scriptPath = path.join(config.projectPath, 'ios', 'firebase.sh');
    final file = File(scriptPath);
    if (file.existsSync()) {
      report.skipped.add('ios/firebase.sh');
      return;
    }

    await file.writeAsString(CommonTemplates.firebaseSh());
    await Process.run('chmod', ['+x', scriptPath]);
    report.written.add('ios/firebase.sh');
  }

  static Future<void> _writeAndroidGoogleServicesPlaceholders(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    for (final env in config.environments) {
      final dir = Directory(
        path.join(config.projectPath, 'android', 'app', 'src', env),
      );
      await dir.create(recursive: true);

      final jsonFile = File(path.join(dir.path, 'google-services.json'));
      final relative = path.join(
        'android',
        'app',
        'src',
        env,
        'google-services.json',
      );
      if (jsonFile.existsSync()) {
        report.skipped.add(relative);
        continue;
      }
      await jsonFile.writeAsString(
        FirebaseNativeFiles.googleServicesJson(config.androidPackageForEnv(env)),
      );
      report.written.add(relative);
    }
  }

  static Future<void> _ensureFirebaseGradlePlugins(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    final settings = _firstExistingFile(<String>[
      path.join(config.projectPath, 'android', 'settings.gradle.kts'),
      path.join(config.projectPath, 'android', 'settings.gradle'),
    ]);
    if (settings == null) {
      throw SetupException(
        'android/settings.gradle(.kts) was not found, so the Google Services '
        'Gradle plugin could not be added.',
      );
    }
    await _patchFirebaseGradleFile(
      settings,
      projectRoot: config.projectPath,
      isSettingsFile: true,
      report: report,
    );

    final appGradle = File(_androidBuildFile(config));
    await _patchFirebaseGradleFile(
      appGradle,
      projectRoot: config.projectPath,
      isSettingsFile: false,
      report: report,
    );
  }

  static Future<void> _patchFirebaseGradleFile(
    File file, {
    required String projectRoot,
    required bool isSettingsFile,
    required SetupChangeReport report,
  }) async {
    final before = await file.readAsString();
    final String updated;
    try {
      updated = ensureFirebaseGradlePlugins(
        before,
        isKotlinDsl: file.path.endsWith('.kts'),
        isSettingsFile: isSettingsFile,
      );
    } on FormatException catch (error) {
      throw SetupException('${file.path}: ${error.message}');
    }
    final relative = path.relative(file.path, from: projectRoot);
    if (updated == before) {
      report.skipped.add(relative);
      return;
    }
    await file.writeAsString(updated);
    report.written.add(relative);
  }

  static File? _firstExistingFile(List<String> candidates) {
    for (final candidate in candidates) {
      final file = File(candidate);
      if (file.existsSync()) {
        return file;
      }
    }
    return null;
  }

  static Future<bool> _patchIosAppDelegate(ProjectConfig config) async {
    final iosRunnerPath = path.join(config.projectPath, 'ios', 'Runner');
    final swiftAppDelegate = File(
      path.join(iosRunnerPath, 'AppDelegate.swift'),
    );
    final objcAppDelegate = File(path.join(iosRunnerPath, 'AppDelegate.m'));
    final target = swiftAppDelegate.existsSync()
        ? swiftAppDelegate
        : objcAppDelegate.existsSync()
        ? objcAppDelegate
        : null;
    if (target == null) {
      throw SetupException(
        'Cannot find iOS AppDelegate. Expected AppDelegate.swift or '
        'AppDelegate.m inside ios/Runner.',
      );
    }
    final before = await target.readAsString();
    await setupIOSFirebaseAppDelegate(config);
    final after = await target.readAsString();
    return before != after;
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
    final launchFile = File(path.join(vscodePath, 'launch.json'));
    await launchFile.writeAsString(
      _formatJson(VsCodeConfigBuilder.launchJson(config)),
    );
  }

  static Future<void> _createTasksJson(
    ProjectConfig config,
    String vscodePath,
  ) async {
    final tasksFile = File(path.join(vscodePath, 'tasks.json'));
    await tasksFile.writeAsString(
      _formatJson(VsCodeConfigBuilder.tasksJson(config)),
    );
  }

  static String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  /// iOS code adjustment for Firebase
  static Future<void> setupIOSFirebaseAppDelegate(ProjectConfig config) async {
    if (!config.useFirebase || !config.targetsIos) return;

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
    final fontsDestinationPath = path.join(
      config.projectPath,
      'assets',
      'fonts',
    );

    final sourceDir = Directory(fontsSourcePath);
    if (!sourceDir.existsSync()) {
      throw Exception('Source fonts directory not found at $fontsSourcePath');
    }

    await for (final file in sourceDir.list(recursive: true)) {
      if (file is File) {
        final relativePath = path.relative(file.path, from: fontsSourcePath);
        final destinationFile = File(
          path.join(fontsDestinationPath, relativePath),
        );
        await destinationFile.create(recursive: true);
        await file.copy(destinationFile.path);
      }
    }
  }

  static Future<Directory> getPackageAssetDir() async {
    final uri = await Isolate.resolvePackageUri(
      Uri.parse('package:xproject_generator/assets/fonts/'),
    );

    if (uri == null) {
      throw Exception('Could not resolve package asset path');
    }

    return Directory.fromUri(uri);
  }

  /// Copies the package default logo into the generated project as [AppIconConfig.projectAssetPath].
  static Future<void> copyDefaultAppIcon(ProjectConfig config) async {
    final source = await AppIconConfig.bundledLogoFile();
    final destination = File(
      path.join(config.projectPath, AppIconConfig.projectAssetPath),
    );
    await destination.parent.create(recursive: true);
    await source.copy(destination.path);
  }

  // TODO: add ignote g and freezed files in gitignore
//  *.g.dart
// *.freezed.dart
}
