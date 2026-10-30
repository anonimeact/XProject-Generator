import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/templates/ci_cd/fastlane_template.dart';
import 'package:xproject_generator/src/templates/ci_cd/github_actions_template.dart';
import 'package:xproject_generator/src/templates/ci_cd/gitlab_ci_template.dart';
import 'package:xproject_generator/src/templates/ci_cd/gitlab_runner_setup_template.dart';

ProjectConfig _baseConfig({
  CiCdScope scope = CiCdScope.ciOnly,
  CiCdProvider provider = CiCdProvider.gitlab,
  GitLabRunnerMode runnerMode = GitLabRunnerMode.sharedFlutterImage,
  Set<DeployTarget>? deployTargets,
  Set<PlatformTarget>? platforms,
}) {
  return ProjectConfig(
    appName: 'my_app',
    displayName: 'My App',
    androidPackage: 'com.example.my_app',
    iosBundleId: 'com.example.my_app',
    stateManagement: StateManagement.riverpod,
    useFirebase: false,
    useSecretKey: false,
    ciCdScope: scope,
    ciCdProvider: provider,
    gitlabRunnerMode: runnerMode,
    deployTargets: deployTargets ?? const {},
    platformTargets: platforms,
  );
}

void main() {
  test('ciOnly gitlab yaml includes analyze and not fastlane', () {
    final yml = GitlabCiTemplate.content(_baseConfig());
    expect(yml, contains('flutter analyze'));
    expect(yml, contains('flutter test'));
    expect(yml, contains('build_runner'));
    expect(yml, isNot(contains('deploy_play_internal')));
  });

  test('ciAndDeploy with play and testflight includes lanes', () {
    final config = _baseConfig(
      scope: CiCdScope.ciAndDeploy,
      deployTargets: {
        DeployTarget.playInternal,
        DeployTarget.testFlight,
      },
    );
    final yml = GitlabCiTemplate.content(config);
    expect(yml, contains('deploy_play_internal'));
    expect(yml, contains('deploy_testflight'));
    expect(yml, isNot(contains('deploy_firebase_app_distribution')));

    final fastfile = FastlaneTemplate.fastfile(config);
    expect(fastfile, contains('deploy_play_internal'));
    expect(fastfile, contains('deploy_testflight'));
    expect(fastfile, isNot(contains('deploy_firebase_android')));
  });

  test('self-hosted shell gitlab yaml uses runner tags', () {
    final yml = GitlabCiTemplate.content(
      _baseConfig(runnerMode: GitLabRunnerMode.selfHostedShell),
    );
    expect(yml, contains('self-hosted'));
    expect(yml, contains('GITLAB_RUNNER_SETUP.md'));
    expect(yml, isNot(contains('ghcr.io/cirruslabs/flutter')));
    final setup = GitlabRunnerSetupTemplate.content(_baseConfig());
    expect(setup, contains('Mac Mini'));
  });

  test('github actions workflow includes analyze', () {
    final yml = GitHubActionsTemplate.content(
      _baseConfig(provider: CiCdProvider.github),
    );
    expect(yml, contains('flutter analyze'));
    expect(yml, contains('subosito/flutter-action'));
    expect(yml, isNot(contains('.gitlab-ci')));
  });

  test('android build job omitted when Android not targeted', () {
    final config = _baseConfig(
      scope: CiCdScope.ciAndDeploy,
      platforms: {PlatformTarget.ios},
      deployTargets: {DeployTarget.artifactsOnly},
    );
    final yml = GitlabCiTemplate.content(config);
    expect(yml, isNot(contains('build_android_')));
    expect(yml, contains('build_ios_'));
  });

  test('play lane and dockerfile follow platform and runner options', () {
    final iosOnly = _baseConfig(
      scope: CiCdScope.ciAndDeploy,
      platforms: {PlatformTarget.ios},
      deployTargets: {DeployTarget.playInternal, DeployTarget.testFlight},
    );
    final fastfile = FastlaneTemplate.fastfile(iosOnly);
    expect(fastfile, contains('deploy_testflight'));
    expect(fastfile, isNot(contains('deploy_play_internal')));
    expect(iosOnly.usesDockerRunner, isFalse);

    final docker = _baseConfig(
      runnerMode: GitLabRunnerMode.dockerfile,
      scope: CiCdScope.ciAndDeploy,
      deployTargets: {DeployTarget.artifactsOnly},
    );
    expect(docker.usesDockerRunner, isTrue);

    final github = GitHubActionsTemplate.content(
      _baseConfig(
        provider: CiCdProvider.github,
        scope: CiCdScope.ciAndDeploy,
        deployTargets: {DeployTarget.firebaseAppDistribution},
        platforms: {PlatformTarget.android},
      ),
    );
    expect(github, contains('deploy_firebase_app_distribution'));
    expect(github, isNot(contains('deploy_testflight')));
  });
}
