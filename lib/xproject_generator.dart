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
import 'src/cli_input.dart';
import 'src/cli_step_progress.dart';
import 'src/file_generator.dart';
import 'src/flutter_generator.dart';
import 'src/post_create_codegen.dart';
import 'src/structure_generator.dart';
import 'src/wizard_inputs.dart';

/// Main class for interactively generating a new Flutter project with structure and configuration.
class ProjectGenerator {
  final Logger logger = Logger();

  /// Interactively create a new Flutter project with user input for name, package, state management, etc.
  ///
  /// Generates the project, structure, and files, and prints next steps and setup instructions.
  Future<void> create() async {
    logger.info('\n🚀 XProject - Flutter Project Generator\n');

    final config = await _collectInputsCreateProject();

    await runWithStepProgress(
      logger,
      'Creating Flutter project...',
      '📦',
      () => FlutterGenerator.create(config),
      progressMin: 0,
      progressMax: 25,
    );

    await runWithStepProgress(
      logger,
      'Generating project structure...',
      '📁',
      () => StructureGenerator.generate(config),
      progressMin: 25,
      progressMax: 50,
    );

    await runWithStepProgress(
      logger,
      'Generating files...',
      '📝',
      () => FileGenerator.generate(config),
      progressMin: 50,
      progressMax: 75,
    );

    await runWithStepProgress(
      logger,
      'Resolving packages and running code generation...',
      '⚙',
      () => PostCreateCodegen.run(config),
      progressMin: 75,
      progressMax: 100,
    );

    logger.success(
      '\n✅ Project created successfully at: ${config.projectPath}',
    );
    logger.info('\n 📝 Next steps:');
    logger.info('  - cd ${config.appName}');
    logger.info('  - Replace `flutter_launcher_icons.image_path` in pubspec.yaml if needed, then: dart run flutter_launcher_icons');
    logger.info('  - flutter run --flavor development -t lib/main_development.dart');
    final guideTopics = <String>[
      'prerequisites & glossary',
      'environment',
      if (config.useSecretKey) 'secret key',
      if (config.useFirebase) 'Firebase',
      if (config.targetsAndroid || config.targetsIos) 'flavor',
      'VS Code run/build',
      'running the app',
      if (config.hasCiCd)
        config.usesGitHubActions ? 'CI/CD GitHub Actions' : 'CI/CD GitLab',
    ];
    logger.info(
      '\n 📖 GUIDE.md is in the project root: ${config.appName}/GUIDE.md — '
      'follow it to finish the remaining configuration '
      '(topics: ${guideTopics.join(', ')}).',
    );
    logger.info('\n ▶ Quick run (after completing the setup in GUIDE.md):');
    logger.info(
      '  flutter run --flavor development -t lib/main_development.dart',
    );
  }

  /// Collect user input for project creation (name, package, state management, etc.).
  ///
  /// Returns a [ProjectConfig] with the collected configuration.
  Future<ProjectConfig> _collectInputsCreateProject() async {
    // 1️⃣ Display name (bebas)
    final displayName = promptLine(
      prompt: 'App display name (e.g. Test App)',
      validator: (x) => x.trim().isNotEmpty,
    );

    // 2️⃣ Auto-generated project name
    final suggestedProjectName = _toSnakeCase(displayName);

    final appName = promptLine(
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
    );

    // 3️⃣ Android package
    final androidPackage = promptLine(
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
    );

    // 4️⃣ iOS bundle ID
    final iosInput = promptLine(
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
    );

    final iosBundleId = iosInput.isEmpty ? androidPackage : iosInput;

    logger.success('iOS bundle ID · $iosBundleId');

    final platformTargets = promptPlatformTargets();
    logger.success('Platforms · ${platformTargets.map((p) => p.name).join(', ')}');

    final stateManagementIndex = Select(
      prompt: 'Select state management',
      options: ['Bloc', 'GetX', 'Provider', 'Riverpod'],
    ).interact();

    StateManagementArchitecture? blocArchitecture;
    StateManagementArchitecture? riverpodArchitecture;
    if (stateManagementIndex == 0) {
      final blocArchitectureIndex = Select(
        prompt: 'Select Bloc architecture',
        options: ['Bloc Simple', 'Bloc Clean Code (Using domain layer)'],
      ).interact();
      blocArchitecture = blocArchitectureIndex == 0
          ? StateManagementArchitecture.simple
          : StateManagementArchitecture.clean;
    }

    if (stateManagementIndex == 3) {
      final riverpodArchitectureIndex = Select(
        prompt: 'Select Riverpod architecture',
        options: [
          'Riverpod Simple',
          'Riverpod Clean Code (Using domain layer)',
        ],
      ).interact();
      riverpodArchitecture = riverpodArchitectureIndex == 0
          ? StateManagementArchitecture.simple
          : StateManagementArchitecture.clean;
    }

    final firebaseInput = promptLine(
      prompt: 'Use Firebase? (y/N): ',
    ).trim();
    final useFirebase =
        firebaseInput.toLowerCase() == 'y' ||
        firebaseInput.toLowerCase() == 'yes';

    // Secret key option
    final secretKeyInput = promptLine(
      prompt: 'Use Secret Key (Generator Package)? (y/N): ',
    ).trim();
    final useSecretKey =
        secretKeyInput.toLowerCase() == 'y' ||
        secretKeyInput.toLowerCase() == 'yes';

    final ciCdScope = promptCiCdScope();
    var ciCdProvider = CiCdProvider.gitlab;
    var gitlabRunnerMode = GitLabRunnerMode.sharedFlutterImage;
    Set<DeployTarget> deployTargets = {};
    if (ciCdScope != CiCdScope.none) {
      ciCdProvider = promptCiCdProvider();
      if (ciCdProvider == CiCdProvider.gitlab) {
        gitlabRunnerMode = promptGitLabRunnerMode();
      }
      if (ciCdScope == CiCdScope.ciAndDeploy) {
        deployTargets = promptDeployTargets();
      }
    }

    return ProjectConfig(
      appName: appName, // snake_case (Flutter-safe)
      displayName: displayName, // human-readable
      androidPackage: androidPackage,
      iosBundleId: iosBundleId,
      useFirebase: useFirebase,
      useSecretKey: useSecretKey,
      stateManagement: stateManagementIndex == 0
          ? StateManagement.bloc
          : stateManagementIndex == 1
          ? StateManagement.getx
          : stateManagementIndex == 2
          ? StateManagement.provider
          : StateManagement.riverpod,
      blocArchitecture: blocArchitecture,
      riverpodArchitecture: riverpodArchitecture,
      platformTargets: platformTargets,
      ciCdScope: ciCdScope,
      ciCdProvider: ciCdProvider,
      gitlabRunnerMode: gitlabRunnerMode,
      deployTargets: deployTargets,
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
