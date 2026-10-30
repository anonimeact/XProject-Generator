import '../../../core/configs/project_config.dart';

/// Setup guide for self-hosted GitLab Runner (local / Mac Mini).
class GitlabRunnerSetupTemplate {
  static String content(ProjectConfig config) {
    final buffer = StringBuffer();
    buffer.writeln('# GitLab Runner — self-hosted (local / Mac Mini)');
    buffer.writeln();
    buffer.writeln(
      'This project uses the **shell executor** on your machine (`tags: self-hosted`, `flutter`). '
      'Jobs in `.gitlab-ci.yml` **do not** use a Docker image; Flutter must already be on the PATH of the user running the runner.',
    );
    buffer.writeln();
    buffer.writeln('## 1. Prerequisites on the runner machine');
    buffer.writeln();
    buffer.writeln('- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable); `flutter doctor` passes');
    buffer.writeln('- Git');
    if (config.hasCiDeploy) {
      buffer.writeln('- Ruby + Bundler + Fastlane (for deploy jobs)');
    }
    if (config.targetsIos) {
      buffer.writeln('- **Mac** with Xcode (required for iOS builds / TestFlight)');
    }
    if (config.targetsAndroid && !config.targetsIos) {
      buffer.writeln('- Android SDK (for APK/AAB builds) — Mac, Linux, or Windows');
    }
    buffer.writeln();
    buffer.writeln('## 2. Install GitLab Runner');
    buffer.writeln();
    buffer.writeln('Official docs: [Install GitLab Runner](https://docs.gitlab.com/runner/install/).');
    buffer.writeln();
    buffer.writeln('**macOS (Homebrew):**');
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('brew install gitlab-runner');
    buffer.writeln('gitlab-runner install');
    buffer.writeln('gitlab-runner start');
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln('## 3. Register the runner with this project');
    buffer.writeln();
    buffer.writeln('In GitLab: **Settings → CI/CD → Runners → New project runner**.');
    buffer.writeln();
    buffer.writeln('When running `gitlab-runner register`:');
    buffer.writeln();
    buffer.writeln('| Prompt | Recommended value |');
    buffer.writeln('| --- | --- |');
    buffer.writeln('| Executor | `shell` |');
    buffer.writeln('| Tags | `self-hosted`, `flutter` |');
    if (config.targetsIos) {
      buffer.writeln('| Extra tags for iOS jobs | `macos` — required by iOS build/deploy jobs in `.gitlab-ci.yml` |');
    }
    buffer.writeln();
    buffer.writeln('Example (replace URL and token from GitLab):');
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('gitlab-runner register \\');
    buffer.writeln('  --url https://gitlab.com/ \\');
    buffer.writeln('  --token <RUNNER_TOKEN> \\');
    buffer.writeln('  --executor shell \\');
    buffer.writeln('  --description "Mac Mini Flutter" \\');
    if (config.targetsIos) {
      buffer.writeln('  --tag-list "self-hosted,flutter,macos"');
    } else {
      buffer.writeln('  --tag-list "self-hosted,flutter"');
    }
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln('## 4. Keep the runner online');
    buffer.writeln();
    buffer.writeln(
      'After reboot, start the runner again (`gitlab-runner start` or a macOS service). '
      'Jobs stay **pending** if no online runner matches the job tags.',
    );
    buffer.writeln();
    buffer.writeln('## 5. Self-managed GitLab');
    buffer.writeln();
    buffer.writeln(
      'If GitLab runs on your own server (not gitlab.com), steps are the same: install the runner on the build machine, '
      'register against your GitLab URL, executor **shell**, same tags.',
    );
    buffer.writeln();
    buffer.writeln('## 6. Docker executor (alternative)');
    buffer.writeln();
    buffer.writeln(
      'If you chose **Self-hosted Docker** in the wizard, use `ci/Dockerfile` and executor `docker` '
      '— see comments in `.gitlab-ci.yml`.',
    );
    buffer.writeln();
    return buffer.toString().trimRight();
  }
}
