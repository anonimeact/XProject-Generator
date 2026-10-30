import 'package:interact/interact.dart';

import '../core/configs/project_config.dart';
import 'cli_input.dart';

const _platformOptions = [
  'Android',
  'iOS',
  'Web',
  'Windows',
  'macOS',
  'Linux',
];

const _platformDefaults = [true, true, false, false, false, false];

/// Collects [PlatformTarget] set from interactive multi-select.
Set<PlatformTarget> promptPlatformTargets() {
  while (true) {
    final indices = MultiSelect(
      prompt: 'Platform target (space toggle, enter confirm)',
      options: _platformOptions,
      defaults: _platformDefaults,
    ).interact();

    if (indices.isEmpty) {
      print('  ⚠️  Pilih minimal satu platform.');
      continue;
    }

    return indices.map(_platformTargetFromIndex).toSet();
  }
}

PlatformTarget _platformTargetFromIndex(int index) {
  switch (index) {
    case 0:
      return PlatformTarget.android;
    case 1:
      return PlatformTarget.ios;
    case 2:
      return PlatformTarget.web;
    case 3:
      return PlatformTarget.windows;
    case 4:
      return PlatformTarget.macos;
    case 5:
      return PlatformTarget.linux;
    default:
      return PlatformTarget.android;
  }
}

/// Returns CI scope; [none] if user declines.
CiCdScope promptCiCdScope() {
  final input = promptLine(prompt: 'Setup CI/CD? (y/N): ').trim();
  final enabled =
      input.toLowerCase() == 'y' || input.toLowerCase() == 'yes';
  if (!enabled) return CiCdScope.none;
  return promptCiCdScopeChoice();
}

/// CI scope after the user has already chosen to set CI/CD up.
CiCdScope promptCiCdScopeChoice() {
  final scopeIndex = Select(
    prompt: 'CI/CD scope',
    options: ['CI saja (analyze & test)', 'CI + deployment (build & distribute)'],
  ).interact();

  return scopeIndex == 0 ? CiCdScope.ciOnly : CiCdScope.ciAndDeploy;
}

/// Yes when the answer is `y` or `yes`. Empty input stays no.
bool promptYesNo(String prompt) {
  final input = promptLine(prompt: '$prompt (y/N): ').trim().toLowerCase();
  return input == 'y' || input == 'yes';
}

/// Human label for a [PlatformTarget], matching the create wizard.
String platformTargetLabel(PlatformTarget target) {
  switch (target) {
    case PlatformTarget.android:
      return 'Android';
    case PlatformTarget.ios:
      return 'iOS';
    case PlatformTarget.web:
      return 'Web';
    case PlatformTarget.windows:
      return 'Windows';
    case PlatformTarget.macos:
      return 'macOS';
    case PlatformTarget.linux:
      return 'Linux';
  }
}

/// Multi-select for platforms that are not in the project yet.
Set<PlatformTarget> promptAdditionalPlatforms(Set<PlatformTarget> missing) {
  final ordered = PlatformTarget.values.where(missing.contains).toList();
  while (true) {
    final indices = MultiSelect(
      prompt: 'Platforms to add (space toggle, enter confirm)',
      options: ordered.map(platformTargetLabel).toList(),
    ).interact();

    if (indices.isEmpty) {
      print('  ⚠️  Pilih minimal satu platform.');
      continue;
    }

    return indices.map((index) => ordered[index]).toSet();
  }
}

CiCdProvider promptCiCdProvider() {
  final index = Select(
    prompt: 'CI/CD platform',
    options: ['GitLab CI', 'GitHub Actions'],
  ).interact();
  return index == 0 ? CiCdProvider.gitlab : CiCdProvider.github;
}

GitLabRunnerMode promptGitLabRunnerMode() {
  final index = Select(
    prompt: 'GitLab runner',
    options: [
      'GitLab.com shared runner (image Flutter)',
      'Self-hosted shell (Mac Mini / PC lokal — Flutter di PATH)',
      'Self-hosted Docker (ci/Dockerfile + executor docker)',
    ],
  ).interact();
  switch (index) {
    case 0:
      return GitLabRunnerMode.sharedFlutterImage;
    case 1:
      return GitLabRunnerMode.selfHostedShell;
    default:
      return GitLabRunnerMode.dockerfile;
  }
}

const _deployOptions = [
  'Google Play (internal testing)',
  'TestFlight',
  'Firebase App Distribution',
  'Hanya artifact (tanpa upload)',
];

Set<DeployTarget> promptDeployTargets() {
  while (true) {
    final indices = MultiSelect(
      prompt: 'Deployment channels (space toggle, enter confirm)',
      options: _deployOptions,
      defaults: [false, false, false, true],
    ).interact();

    if (indices.isEmpty) {
      return {DeployTarget.artifactsOnly};
    }

    return indices.map(_deployTargetFromIndex).toSet();
  }
}

DeployTarget _deployTargetFromIndex(int index) {
  switch (index) {
    case 0:
      return DeployTarget.playInternal;
    case 1:
      return DeployTarget.testFlight;
    case 2:
      return DeployTarget.firebaseAppDistribution;
    case 3:
      return DeployTarget.artifactsOnly;
    default:
      return DeployTarget.artifactsOnly;
  }
}
