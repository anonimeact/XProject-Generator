/// XProject Generator CLI
///
/// A command-line tool to quickly scaffold new Flutter projects and add new features
/// using best-practice templates for GetX or Riverpod state management.
///
/// Features:
/// - Create a new Flutter project with a complete structure (step progress + pub get/codegen)
/// - Add a new feature template to an existing project
/// - Add Firebase, secret key, CI/CD, or platforms after create
/// - Show CLI version and help
///
/// Usage:
///   xproject                 # Create a new project (interactive)
///   xproject create          # Create a new project (interactive)
///   xproject setup           # Add a missing integration (interactive)
///   xproject setup firebase  # Add Firebase to the current project
///   xproject setup secret-key
///   xproject setup ci
///   xproject setup platforms
///   xproject --feature name  # Add a new feature template
///   xproject -f name         # Add a new feature template
///   xproject --version       # Show version
///   xproject --help          # Show help
///
/// Notes:
/// - State management (GetX or Riverpod) is auto-detected by the generators; you do
///   not need to pass any state-management flags when creating projects or features.
///
/// For more details, see README.md or use --help.
library;

import 'dart:io';
import 'package:args/args.dart';
import 'package:xproject_generator/core/package_version.dart';
import 'package:xproject_generator/xfeature_generator.dart';
import 'package:xproject_generator/xproject_generator.dart';
import 'package:xproject_generator/xsetup_generator.dart';

/// Main entry point for XProject Generator CLI.
///
/// The CLI supports the following behaviors depending on provided [arguments]:
/// - No arguments or `create` command: interactively scaffold a new Flutter project.
/// - `--feature <name>` or `-f <name>`: generate a feature template inside the current Flutter project.
/// - `setup` and `setup <integration>`: add Firebase, secret key, CI/CD, or platforms to the current project.
/// - `--version` or `-v`: print the XProject Generator version (read from nearest `pubspec.yaml`).
/// - `--help` or `-h`: print usage help.
///
/// The function may call `exit()` on non-recoverable errors. It throws no exceptions itself
/// because errors are caught and reported to the user in the `try/catch` block.
///
/// [arguments]: Command-line arguments forwarded by the Dart runtime.
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'feature',
      abbr: 'f',
      help: 'Generate a feature template inside the current Flutter project',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help')
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Show version');

  parser.addCommand('create');
  _addSetupCommand(parser);

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      exit(0);
    }

    if (results['version'] as bool) {
      final version = await readPackageVersion();
      print('XProject Generator v$version');
      exit(0);
    }

    final shortcutFeature = results['feature'] as String?;
    if (shortcutFeature != null && shortcutFeature.trim().isNotEmpty) {
      final featureName = shortcutFeature.trim();
      final generator = FeatureGenerator();
      await generator.add(featureName);
      exit(0);
    }

    final command = results.command;

    if (command == null) {
      final generator = ProjectGenerator();
      await generator.create();
    } else if (command.name == 'create') {
      final generator = ProjectGenerator();
      await generator.create();
    } else if (command.name == 'setup') {
      await _runSetup(command);
    } else if (command.name == 'help') {
      _printHelp(parser);
      exit(0);
    } else {
      print('Unknown command: ${command.name}');
      _printHelp(parser);
      exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

/// Registers `xproject setup` and its integrations.
///
/// Subcommands are explicit so `xproject setup firebase` does not fall through
/// to project creation. `secret` and `cicd` are short aliases.
void _addSetupCommand(ArgParser parser) {
  final setup = parser.addCommand('setup')
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show setup commands',
    );
  setup.addCommand('firebase');
  setup.addCommand('secret-key');
  setup.addCommand('secret');
  setup.addCommand('ci');
  setup.addCommand('cicd');
  setup.addCommand('platforms');
  setup.addCommand('guide');
}

/// Runs the setup menu, or one integration when a subcommand was given.
Future<void> _runSetup(ArgResults command) async {
  if (command['help'] == true) {
    _printSetupHelp();
    exit(0);
  }

  final generator = SetupGenerator();
  final subcommand = command.command;
  if (subcommand == null) {
    final unknown = command.rest.where((arg) => !arg.startsWith('-')).toList();
    if (unknown.isNotEmpty) {
      print('Unknown setup command: ${unknown.first}');
      _printSetupHelp();
      exit(1);
    }
    await generator.runInteractive();
    return;
  }

  switch (subcommand.name) {
    case 'firebase':
      await generator.firebase();
    case 'secret-key':
    case 'secret':
      await generator.secretKey();
    case 'ci':
    case 'cicd':
      await generator.ciCd();
    case 'platforms':
      await generator.platforms();
    case 'guide':
      await generator.regenerateGuide();
    default:
      print('Unknown setup command: ${subcommand.name}');
      _printSetupHelp();
      exit(1);
  }
}

/// Print CLI usage help for XProject Generator.
void _printHelp(ArgParser parser) {
  print('''
XProject Generator - Flutter Project Generator

Usage: xproject [command] [options]

Commands:
  create                  Create a new Flutter project (default)
  setup                   Add an integration to the current project
  setup firebase          Add Firebase (packages, splash, native placeholders)
  setup secret-key        Encrypt .env loading (alias: secret)
  setup ci                Add GitLab CI or GitHub Actions (alias: cicd)
  setup platforms         Add Flutter platforms that were not selected at create

Options:
${parser.usage}

Examples:
  xproject                                    # Create new project
  xproject create                             # Create new project
  xproject setup                              # Menu of integrations not yet installed
  xproject setup firebase                     # Run inside the Flutter project
  xproject setup secret-key
  xproject setup ci
  xproject setup platforms
  xproject --feature [feature_name]           # Create new feature template in current project
  xproject -f [feature_name]                  # Create new feature template in current project

Note: When creating a new project the CLI will prompt you to choose a state
management option (GetX, Riverpod, or Bloc). When generating features (`--feature`),
state management is detected automatically from the target project; no extra
flags are required for feature generation.

`xproject setup` must be run from the generated Flutter project (the directory
that contains pubspec.yaml), after `xproject create`. It does not replace
create, and it leaves Firebase config files and secretkey.dart alone when
those files already exist.
''');
}

void _printSetupHelp() {
  print('''
Add an integration that was skipped during xproject create.

Run these commands from the Flutter project directory.

  xproject setup                 Interactive menu
  xproject setup firebase        Firebase packages, splash init, native files
  xproject setup secret-key      Encrypted .env loader (alias: secret)
  xproject setup ci              GitLab CI or GitHub Actions (alias: cicd)
  xproject setup platforms       Extra Flutter platforms (web, desktop, mobile)
  xproject setup guide           Regenerate GUIDE.md (English)

Already-present downloads are not overwritten:
  android/app/src/<flavor>/google-services.json
  ios/config/<flavor>/GoogleService-Info.plist
  lib/core/services/firebase/firebase_service.dart
  lib/core/config/secretkey.dart

CI files are overwritten only after you confirm.
GUIDE.md is regenerated when the command changes the project.
''');
}

