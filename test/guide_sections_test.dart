import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/templates/guide_template.dart';

void main() {
  test('beginner guide includes core sections', () {
    final guide = GuideTemplate.content(
      ProjectConfig(
        appName: 'app',
        displayName: 'App',
        androidPackage: 'com.example.app',
        iosBundleId: 'com.example.app',
        stateManagement: StateManagement.getx,
        useFirebase: false,
        useSecretKey: false,
      ),
    );

    expect(guide, contains('GUIDE.md'));
    expect(guide, contains('## Table of contents'));
    expect(guide, contains('Glossary'));
    expect(guide, contains('flutter doctor'));
    expect(guide, contains('# Part 1: Understanding the project'));
    expect(guide, contains('# Part 2: Configuration to complete'));
    expect(guide, contains('### 7. VS Code: run & build'));
    expect(guide, isNot(contains('Cursor')));
    expect(
      guide,
      contains('[Initial steps & dependencies](#1-initial-steps--dependencies)'),
    );
    expect(guide, contains('### 1. Initial steps & dependencies'));
    expect(
      guide,
      contains('- [ ] `flutter pub get` completes without errors'),
    );
    expect(guide, contains('Manage Schemes'));
    expect(guide, contains('Debug-development'));
    expect(guide, contains('Troubleshooting'));
  });

  test('guide omits Firebase when disabled', () {
    final guide = GuideTemplate.content(
      ProjectConfig(
        appName: 'plain',
        displayName: 'Plain',
        androidPackage: 'com.example.plain',
        iosBundleId: 'com.example.plain',
        stateManagement: StateManagement.getx,
        useFirebase: false,
        useSecretKey: false,
      ),
    );
    expect(guide.contains('### Script iOS'), isFalse);
    expect(guide, contains('Firebase | No |'));
    expect(guide, contains('xproject setup firebase'));
    expect(guide, contains('xproject setup'));
  });

  test('guide includes GitLab CI/CD when enabled', () {
    final guide = GuideTemplate.content(
      ProjectConfig(
        appName: 'ci',
        displayName: 'CI',
        androidPackage: 'com.example.ci',
        iosBundleId: 'com.example.ci',
        stateManagement: StateManagement.bloc,
        useFirebase: true,
        useSecretKey: false,
        ciCdScope: CiCdScope.ciOnly,
        gitlabRunnerMode: GitLabRunnerMode.selfHostedShell,
      ),
    );
    expect(guide, contains('CI/CD (GitLab)'));
    expect(guide, contains('GITLAB_RUNNER_SETUP'));
    expect(guide, contains('Firebase'));
  });

  test('guide includes GitHub Actions when selected', () {
    final guide = GuideTemplate.content(
      ProjectConfig(
        appName: 'gh',
        displayName: 'GH',
        androidPackage: 'com.example.gh',
        iosBundleId: 'com.example.gh',
        stateManagement: StateManagement.getx,
        useFirebase: false,
        useSecretKey: false,
        ciCdScope: CiCdScope.ciOnly,
        ciCdProvider: CiCdProvider.github,
      ),
    );
    expect(guide, contains('CI/CD (GitHub Actions)'));
    expect(guide, contains('flutter_ci.yml'));
  });
}
