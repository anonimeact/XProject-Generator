/// XProject Generator CLI
///
/// A command-line tool to quickly scaffold new Flutter projects and add new features
/// using best-practice templates for GetX or Riverpod state management.
///
/// Features:
/// - Create a new Flutter project with a complete structure
/// - Add a new feature template to an existing project
/// - Show CLI version and help
///
/// Usage:
///   xproject                 # Create a new project (interactive)
///   xproject create          # Create a new project (interactive)
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
import 'package:path/path.dart' as path;
import 'package:xproject_generator/xfeature_generator.dart';
import 'package:xproject_generator/xproject_generator.dart';

/// Main entry point for XProject Generator CLI.
///
/// The CLI supports the following behaviors depending on provided [arguments]:
/// - No arguments or `create` command: interactively scaffold a new Flutter project.
/// - `--feature <name>` or `-f <name>`: generate a feature template inside the current Flutter project.
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

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _printHelp(parser);
      exit(0);
    }

    if (results['version'] as bool) {
      final version = await getVersionFromPubspec();
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

/// Print CLI usage help for XProject Generator.
void _printHelp(ArgParser parser) {
  print('''
XProject Generator - Flutter Project Generator

Usage: xproject [command] [options]

Commands:
  create    Create a new Flutter project (default)

Options:
${parser.usage}

Examples:
  xproject                                    # Create new project
  xproject create                             # Create new project
  xproject --feature [feature_name]           # Create new feature template in current project
  xproject -f [feature_name]                  # Create new feature template in current project

Note: When creating a new project the CLI will prompt you to choose a state
management option (GetX or Riverpod). When generating features (`--feature`),
state management is detected automatically from the target project; no extra
flags are required for feature generation.
''');
}

/// Get the version string from pubspec.yaml.
Future<String> getVersionFromPubspec() async {
  final scriptPath = Platform.script.toFilePath();
  var dir = Directory(path.dirname(scriptPath));

  while (true) {
    final pubspec = File(path.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      final lines = await pubspec.readAsLines();

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('version:')) {
          // contoh: version: 1.0.0+1
          return trimmed.split(':').last.trim();
        }
      }
      break;
    }

    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  return 'unknown';
}
