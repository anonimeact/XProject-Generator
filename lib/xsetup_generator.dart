/// Adds Firebase, secret-key loading, CI/CD, or platforms to an existing app.
///
/// Run from the Flutter project directory (the folder that contains
/// `pubspec.yaml`), not from the parent folder used by `xproject create`.
///
/// ```dart
/// await SetupGenerator().firebase();
/// await SetupGenerator().secretKey();
/// await SetupGenerator().ciCd();
/// await SetupGenerator().platforms();
/// await SetupGenerator().runInteractive();
/// ```
///
/// Each command inspects the project, patches only the integration you asked
/// for, and rewrites `GUIDE.md` when something actually changed. Files you
/// already replaced (Firebase config downloads, a real `secretkey.dart`, an
/// edited `firebase_service.dart`) are not overwritten.
library;

import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';

import 'core/configs/project_config.dart';
import 'src/cli_step_progress.dart';
import 'src/integrations/ci_cd_integrator.dart';
import 'src/integrations/firebase_integrator.dart';
import 'src/integrations/guide_refresher.dart';
import 'src/integrations/platform_integrator.dart';
import 'src/integrations/project_inspector.dart';
import 'src/integrations/secret_key_integrator.dart';
import 'src/integrations/setup_change_report.dart';
import 'src/wizard_inputs.dart';

/// Interactive and direct entry points for `xproject setup`.
class SetupGenerator {
  /// [logger] is overridable so tests can capture output. The CLI uses the
  /// default [Logger].
  SetupGenerator({Logger? logger}) : logger = logger ?? Logger();

  final Logger logger;

  /// Menu of integrations that are not fully present yet.
  Future<void> runInteractive() async {
    final inspected = await ProjectInspector.inspect();
    final options = <String>[];
    final actions = <Future<void> Function()>[];

    if (!inspected.firebaseReady) {
      options.add('Firebase');
      actions.add(firebase);
    }
    if (!inspected.secretKeyReady) {
      options.add('Secret key');
      actions.add(secretKey);
    }
    if (!inspected.ciReady) {
      options.add('CI/CD');
      actions.add(ciCd);
    }
    if (inspected.missingPlatforms.isNotEmpty) {
      options.add('Additional platforms');
      actions.add(platforms);
    }

    if (options.isEmpty) {
      logger.success('Optional integrations are already set up.');
      logger.info(
        'You can still re-run a command directly, for example '
        '`xproject setup ci` to replace CI/CD.',
      );
      return;
    }

    logger.info('\nAdd an integration to this XProject app.\n');
    final index = Select(
      prompt: 'Choose integration',
      options: options,
    ).interact();
    await actions[index]();
  }

  /// Add Firebase packages, splash startup, and native placeholder config.
  Future<void> firebase() async {
    final inspected = await ProjectInspector.inspect();
    final report = await runWithStepProgress(
      logger,
      'Setting up Firebase...',
      '🔥',
      () => FirebaseIntegrator.apply(
        inspected.config.copyWith(useFirebase: true),
      ),
    );
    _printReport(report);
  }

  /// Switch `.env` loading to the encrypted secret-key flow.
  Future<void> secretKey() async {
    final inspected = await ProjectInspector.inspect();
    final report = await runWithStepProgress(
      logger,
      'Setting up secret key...',
      '🔐',
      () => SecretKeyIntegrator.apply(
        inspected.config.copyWith(useSecretKey: true),
      ),
    );
    _printReport(report);
  }

  /// Add GitLab CI or GitHub Actions, optionally with Fastlane deploy lanes.
  ///
  /// When a CI file already exists, asks before overwriting it.
  Future<void> ciCd() async {
    final inspected = await ProjectInspector.inspect();
    final existing = CiCdIntegrator.existingFiles(inspected.root.path);
    var overwrite = false;
    if (existing.isNotEmpty) {
      logger.info('CI/CD files already present: ${existing.join(', ')}');
      overwrite = promptYesNo(
        'Overwrite existing CI/CD files (including fastlane and smoke_test.dart)',
      );
      if (!overwrite) {
        logger.info('Cancelled. Existing CI/CD files were left unchanged.');
        return;
      }
    }

    final scope = promptCiCdScopeChoice();
    final provider = promptCiCdProvider();
    var runnerMode = GitLabRunnerMode.sharedFlutterImage;
    if (provider == CiCdProvider.gitlab) {
      runnerMode = promptGitLabRunnerMode();
    }
    var deployTargets = <DeployTarget>{};
    if (scope == CiCdScope.ciAndDeploy) {
      deployTargets = promptDeployTargets();
    }

    final report = await runWithStepProgress(
      logger,
      'Writing CI/CD files...',
      '🛠',
      () => CiCdIntegrator.apply(
        inspected.config.copyWith(
          ciCdScope: scope,
          ciCdProvider: provider,
          gitlabRunnerMode: runnerMode,
          deployTargets: deployTargets,
        ),
        overwrite: overwrite,
      ),
    );
    _printReport(report);
  }

  /// Add Flutter platforms that are missing from this project.
  Future<void> platforms() async {
    final inspected = await ProjectInspector.inspect();
    if (inspected.missingPlatforms.isEmpty) {
      logger.success('All Flutter platforms are already in this project.');
      return;
    }

    final selected = promptAdditionalPlatforms(inspected.missingPlatforms);
    final report = await runWithStepProgress(
      logger,
      'Adding platforms...',
      '📱',
      () => PlatformIntegrator.apply(
        config: inspected.config,
        additional: selected,
      ),
    );
    _printReport(report);
    logger.info('Next: flutter pub get');
  }

  /// Regenerates English-only `GUIDE.md`.
  Future<void> regenerateGuide() async {
    final inspected = await ProjectInspector.inspect();
    await runWithStepProgress(
      logger,
      'Regenerating GUIDE.md...',
      '📖',
      () => GuideRefresher.refresh(inspected.config),
    );
    logger.success('GUIDE.md updated.');
  }

  void _printReport(SetupChangeReport report) {
    if (report.written.isEmpty) {
      logger.success('Nothing to change.');
    } else {
      logger.success('Updated:');
      for (final item in report.written) {
        logger.info('  - $item');
      }
    }
    if (report.skipped.isNotEmpty) {
      logger.info('Left unchanged:');
      for (final item in report.skipped) {
        logger.info('  - $item');
      }
    }
    for (final note in report.notes) {
      logger.info(note);
    }
    if (report.guideUpdatedFor != null) {
      logger.info(
        '\n📖 GUIDE.md was updated for ${report.guideUpdatedFor} setup. '
        'Open it in the project root (Part 2 checklists).',
      );
    }
  }
}
