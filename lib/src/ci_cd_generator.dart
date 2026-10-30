import 'dart:io';

import 'package:path/path.dart' as path;

import '../core/configs/project_config.dart';
import 'templates/ci_cd/dockerfile_template.dart';
import 'templates/ci_cd/fastlane_template.dart';
import 'templates/ci_cd/github_actions_template.dart';
import 'templates/ci_cd/gitlab_ci_template.dart';
import 'templates/ci_cd/gitlab_runner_setup_template.dart';

/// Writes CI/CD related files into a generated project.
class CiCdGenerator {
  /// Writes pipeline, Fastlane, and smoke-test files for [config].
  ///
  /// When [replaceExisting] is false, a file that is already on disk is left
  /// untouched. Create uses the default (`true`) because the project tree is
  /// new. Setup passes `false` unless the user confirmed an overwrite, so a
  /// hand-written `test/smoke_test.dart` is not replaced by accident.
  static Future<List<String>> generate(
    ProjectConfig config, {
    bool replaceExisting = true,
  }) async {
    if (!config.hasCiCd) return const <String>[];

    final root = config.projectPath;
    final written = <String>[];

    Future<void> writeRelative(String relative, String content) async {
      final didWrite = await _write(
        path.join(root, relative),
        content,
        replaceExisting: replaceExisting,
      );
      if (didWrite) written.add(relative);
    }

    if (config.usesGitLabCi) {
      await writeRelative('.gitlab-ci.yml', GitlabCiTemplate.content(config));

      if (config.gitLabSelfHostedShell) {
        await writeRelative(
          'ci/GITLAB_RUNNER_SETUP.md',
          GitlabRunnerSetupTemplate.content(config),
        );
      }

      if (config.usesDockerRunner) {
        await writeRelative('ci/Dockerfile', DockerfileTemplate.content());
      }
    }

    if (config.usesGitHubActions) {
      await writeRelative(
        '.github/workflows/flutter_ci.yml',
        GitHubActionsTemplate.content(config),
      );
    }

    await writeRelative('test/smoke_test.dart', FastlaneTemplate.smokeTest());

    if (!config.hasCiDeploy) return written;

    await writeRelative('fastlane/Appfile', FastlaneTemplate.appfile(config));
    await writeRelative('fastlane/Fastfile', FastlaneTemplate.fastfile(config));
    await writeRelative('fastlane/.env.example', FastlaneTemplate.envExample());
    return written;
  }

  /// Returns true when [filePath] was created or replaced.
  static Future<bool> _write(
    String filePath,
    String content, {
    required bool replaceExisting,
  }) async {
    final file = File(filePath);
    if (file.existsSync() && !replaceExisting) return false;
    await file.parent.create(recursive: true);
    await file.writeAsString('$content\n');
    return true;
  }
}
