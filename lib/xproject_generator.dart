/// XProject Generator - Project Generator
///
/// Provides functionality to interactively scaffold a new Flutter project with best-practice structure,
/// including state management (GetX or Riverpod), Firebase support, and platform configuration.
///
/// Usage:
///   await ProjectGenerator().create();
///
/// See README.md for more details.
library;

import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';

import 'core/configs/project_config.dart';
import 'src/file_generator.dart';
import 'src/flutter_generator.dart';
import 'src/structure_generator.dart';

/// Main class for interactively generating a new Flutter project with structure and configuration.
class ProjectGenerator {
  final Logger logger = Logger();

  /// Interactively create a new Flutter project with user input for name, package, state management, etc.
  ///
  /// Generates the project, structure, and files, and prints next steps and setup instructions.
  Future<void> create() async {
    logger.info('\n🚀 XProject - Flutter Project Generator\n');

    final config = await _collectInputsCreateProject();

    logger.info('\n📦 Creating Flutter project...');
    await FlutterGenerator.create(config);

    logger.info('📁 Generating project structure...');
    await StructureGenerator.generate(config);

    logger.info('📝 Generating files...');
    await FileGenerator.generate(config);

    logger.success(
      '\n✅ Project created successfully at: ${config.projectPath}',
    );
    logger.info('\n 📝 Next steps:');
    logger.info('  - cd ${config.appName}');
    logger.info('  - flutter pub get');
    logger.info(
      '\n 🔑 Setup secret keys for SecureCompressor manually and generate secretkey.dart file using secret_key_scrypt_generator package',
    );
    logger.info('  - Add your secret keys in secretkey.dart file located at:');
    logger.info('    lib/core/config/secretkey.dart');
    logger.info(
      '  - Refer to https://pub.dev/packages/secret_key_scrypt_generator for generating secretkey.dart file',
    );
    if (config.useFirebase) {
      logger.info('\n 🔥 Firebase setup:');
      logger.info(
        '  - Place your google-services.json file at: android/app/google-services.json',
      );
      logger.info(
        '  - Place your GoogleService-Info.plist file at: ios/Runner/GoogleService-Info.plist',
      );
      logger.info(
        '  - or use flutterfire CLI to configure Firebase automatically',
      );
      logger.info(
        '  - For more details, refer to the Firebase setup guide in the README.md file',
      );
    }
    logger.info('\n 🔄 Sync freezed and other Build Runners');
    logger.info('   - Make sure the code was clear (No errors)');
    logger.info(
      '   - Run task with Cmd/Ctrl + Shift + P → Tasks: Run Task -> Synchronize Build Runners',
    );
    logger.info('\n 📱 iOS one-time setup (required for --flavor)');
    logger.info('\n Enhance Runner configuration for multiple flavors:');
    logger.info('  1. Open ios/Runner.xcodeproj in Xcode');
    logger.info('  2. Select Runner on PROJECT → Info');
    logger.info(
      '  3. Under "Configurations", duplicate "Debug", "Profile", and "Release" for each flavor: development, staging',
    );
    logger.info('     (e.g., Debug-development, Release-development, etc.)');
    logger.info(
      '  4. Rename origin configurations into "Debug-production", "Profile-production", and "Release-production"',
    );
    logger.info('  5. Go to "Build Settings" in TARGETS → Runner');
    logger.info('  6. Search for "Product Bundle Identifier"');
    logger.info(
      '  7. Set the bundle identifier for each configuration accordingly',
    );
    logger.info(
      '     (e.g., com.example.app.development, com.example.app.staging, etc.)',
    );
    logger.info(
      '  8. Setup display name for each configuration environment if needed.',
    );
    logger.info('     - Tap Add icon to add new User-Defined Setting');
    logger.info(
      '     - Set "APP_DISPLAY_NAME" as the key and your desired app name as the value for each configuration',
    );
    logger.info(
      '     - e.g., "Test App Dev" for development, "Test App Staging" for staging, etc.',
    );
    logger.info(
      '     - Open Info.plist and set the Bundle display name to \$(APP_DISPLAY_NAME)',
    );
    logger.info('');
    logger.info(
      ' 📃 This project uses an iOS Firebase script located at: ios/firebase.sh',
    );
    logger.info(
      '  Please complete the following steps in Xcode to complete the iOS flavoring setup:',
    );
    logger.info('  1. Open Xcode workspace:');
    logger.info('     open ios/Runner.xcworkspace');
    logger.info('  2. Select Runner → Build Phases');
    logger.info('  3. Click "+" → New Run Script Phase');
    logger.info('  4. Paste this script path:');
    logger.info('     "ios/firebase.sh"');
    logger.info('  5. Rename script to "Firebase Script"');
    logger.info(
      '  6. Make sure this phase runs BEFORE "Copy Bundle Resources"',
    );
    logger.info('  7. Create schemes: development, staging, production');
    logger.info('     (Product → Scheme → Manage Schemes)');

    logger.info('\n ▶ Run app:');
    logger.info(
      '  flutter run --flavor development -t lib/main_development.dart',
    );
    logger.info('or: \n  Go to Run and Debug icon in left panel in VSCode, and select env that you want to run');
  }

  /// Collect user input for project creation (name, package, state management, etc.).
  ///
  /// Returns a [ProjectConfig] with the collected configuration.
  Future<ProjectConfig> _collectInputsCreateProject() async {
    // 1️⃣ Display name (bebas)
    final displayName = Input(
      prompt: 'App display name (e.g. Test App)',
      validator: (x) => x.trim().isNotEmpty,
    ).interact();

    // 2️⃣ Auto-generated project name
    final suggestedProjectName = _toSnakeCase(displayName);

    final appName = Input(
      prompt: 'Project name (snake_case)',
      defaultValue: suggestedProjectName,
      validator: (String x) {
        if (x.isEmpty) return false;

        if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(x)) {
          print(
            '  ⚠️  Must be lowercase snake_case. Example: aplikasi_makanan',
          );
          return false;
        }
        return true;
      },
    ).interact();

    // 3️⃣ Android package
    final androidPackage = Input(
      prompt: 'Android package (e.g., com.example.app)',
      defaultValue: 'com.example.$appName',
      validator: (String x) {
        if (x.isEmpty) return false;

        // 1️⃣ IZINKAN INPUT SAAT MENGETIK
        if (!RegExp(r'^[a-z0-9._]+$').hasMatch(x)) {
          print('  ⚠️  Use lowercase letters, numbers, underscores, and dots');
          return false;
        }

        // 2️⃣ VALIDASI FORMAT FINAL ANDROID
        if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$').hasMatch(x)) {
          return false;
        }

        return true;
      },
    ).interact();

    // 4️⃣ iOS bundle ID
    final iosInput = Input(
      prompt: 'iOS bundle ID (Just enter to use $androidPackage)',
      validator: (String x) {
        if (x.isEmpty) return true; // ⬅️ allow empty (fallback)

        // allow typing
        if (!RegExp(r'^[a-z0-9.-]+$').hasMatch(x)) {
          print('  ⚠️  Use lowercase letters, numbers, dots, and hyphens');
          return false;
        }

        // final validation
        if (!RegExp(r'^[a-z][a-z0-9-]*(\.[a-z0-9-]+)+$').hasMatch(x)) {
          return false;
        }

        return true;
      },
    ).interact();

    final iosBundleId = iosInput.isEmpty ? androidPackage : iosInput;

    logger.success('iOS bundle ID · $iosBundleId');

    final firebaseInput = Input(
      prompt: 'Use Firebase? (Y/n): ',
    ).interact().trim();
    final useFirebase =
        firebaseInput.isEmpty ||
        firebaseInput.toLowerCase() == 'y' ||
        firebaseInput.toLowerCase() == 'yes';

    // 5️⃣ State management
    final stateManagementIndex = Select(
      prompt: 'Select state management',
      options: ['GetX', 'Riverpod'],
    ).interact();

    return ProjectConfig(
      appName: appName, // snake_case (Flutter-safe)
      displayName: displayName, // human-readable
      androidPackage: androidPackage,
      iosBundleId: iosBundleId,
      useFirebase: useFirebase,
      stateManagement: stateManagementIndex == 0
          ? StateManagement.getx
          : StateManagement.riverpod,
    );
  }

  /// Convert a string [input] to snake_case for use as a project name.
  String _toSnakeCase(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
