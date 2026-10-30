import 'dart:io';

import '../core/configs/project_config.dart';

/// Runs Flutter tooling after scaffold files are written.
///
/// Generated sources reference outputs that do not exist until tooling runs:
/// - `lib/core/l10n/generated/app_localizations.dart` (`flutter: generate: true`)
/// - `*.freezed.dart` / `*.g.dart` (freezed, json_serializable, riverpod_generator)
///
/// Without this step, the IDE reports missing URIs right after `xproject create`.
abstract final class PostCreateCodegen {
  /// Resolves packages, generates l10n, then runs build_runner.
  static Future<void> run(
    ProjectConfig config, {
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments,
      String workingDirectory,
    )?
    runner,
  }) async {
    final root = config.projectPath;
    final run = runner ?? _runProcess;

    await _step(
      run,
      root,
      'flutter',
      const ['pub', 'get'],
      label: 'flutter pub get',
    );
    if (config.targetsAndroid || config.targetsIos) {
      await _step(
        run,
        root,
        'dart',
        const ['run', 'flutter_launcher_icons'],
        label: 'flutter_launcher_icons',
      );
    }
    await _step(
      run,
      root,
      'dart',
      [
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ],
      label: 'build_runner',
    );
    _assertL10nOutputs(root);
  }

  /// Same build_runner invocation used after feature generation.
  static Future<void> runBuildRunner(String projectRoot) async {
    final result = await _runProcess(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      projectRoot,
    );
    if (result.exitCode != 0) {
      throw Exception(
        'build_runner failed (exit ${result.exitCode}).\n${result.stderr}',
      );
    }
  }

  static Future<void> _step(
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments,
      String workingDirectory,
    ) run,
    String root,
    String executable,
    List<String> args, {
    required String label,
  }) async {
    final result = await run(executable, args, root);
    if (result.exitCode != 0) {
      throw Exception(
        '$label failed (exit ${result.exitCode}).\n'
        '${result.stderr}\n${result.stdout}',
      );
    }
  }

  static void _assertL10nOutputs(String projectRoot) {
    final file = File(
      '$projectRoot/lib/core/l10n/generated/app_localizations.dart',
    );
    if (!file.existsSync()) {
      throw Exception(
        'Localization codegen did not create '
        'lib/core/l10n/generated/app_localizations.dart. '
        'Ensure pubspec.yaml contains `flutter: generate: true` and '
        'l10n.yaml points at lib/core/l10n/*.arb.',
      );
    }
  }

  static Future<ProcessResult> _runProcess(
    String executable,
    List<String> arguments,
    String workingDirectory,
  ) {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
  }
}
