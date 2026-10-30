import 'dart:io';

import 'package:path/path.dart' as path;

import 'guide_language.dart';
import 'session_storage_keys.dart';

export 'guide_language.dart';
export 'session_storage_keys.dart';

/// XProject Generator - Project Configuration
///
/// Defines the [ProjectConfig] class, which holds all configuration data
/// required to scaffold a new Flutter project using XProject Generator.
enum StateManagement { getx, riverpod, bloc, provider }

enum StateManagementArchitecture { simple, clean }

/// Platforms passed to `flutter create --platforms`.
enum PlatformTarget {
  android,
  ios,
  web,
  windows,
  macos,
  linux,
}

enum CiCdScope { none, ciOnly, ciAndDeploy }

enum CiCdProvider { gitlab, github }

/// How GitLab jobs run (ignored when [ciCdProvider] is [CiCdProvider.github]).
enum GitLabRunnerMode {
  /// GitLab.com / SaaS shared runners with a Flutter container image.
  sharedFlutterImage,
  /// Shell executor on your machine (e.g. Mac Mini); Flutter & Ruby/Fastlane on PATH.
  selfHostedShell,
  /// Self-hosted runner with Docker executor using [ci/Dockerfile].
  dockerfile,
}

enum DeployTarget {
  playInternal,
  testFlight,
  firebaseAppDistribution,
  artifactsOnly,
}

class ProjectConfig {
  ProjectConfig({
    required this.appName,
    required this.displayName,
    required this.androidPackage,
    required this.iosBundleId,
    required this.stateManagement,
    required this.useFirebase,
    required this.useSecretKey,
    this.blocArchitecture,
    this.riverpodArchitecture,
    Set<PlatformTarget>? platformTargets,
    this.ciCdScope = CiCdScope.none,
    this.ciCdProvider = CiCdProvider.gitlab,
    this.gitlabRunnerMode = GitLabRunnerMode.sharedFlutterImage,
    Set<DeployTarget>? deployTargets,
    this.projectRoot,
    this.guideLanguage = GuideLanguage.en,
    SessionStorageKeys? sessionStorageKeys,
  }) : platformTargets = platformTargets ?? const {
          PlatformTarget.android,
          PlatformTarget.ios,
        },
       deployTargets = deployTargets ?? const {},
       sessionStorageKeys = sessionStorageKeys ?? SessionStorageKeys.generate();

  final String appName;
  final String displayName;
  final String androidPackage;
  final String iosBundleId;
  final StateManagement stateManagement;
  final bool useFirebase;
  final bool useSecretKey;

  final StateManagementArchitecture? blocArchitecture;
  final StateManagementArchitecture? riverpodArchitecture;

  final Set<PlatformTarget> platformTargets;
  final CiCdScope ciCdScope;
  final CiCdProvider ciCdProvider;
  final GitLabRunnerMode gitlabRunnerMode;
  final Set<DeployTarget> deployTargets;

  /// Absolute path of an existing project.
  ///
  /// When null (project creation), [projectPath] is `Directory.current/appName`.
  /// Setup commands set this to the Flutter project root so files are patched
  /// in place instead of inside a new `<appName>/` folder.
  final String? projectRoot;

  /// Language of generated `GUIDE.md`.
  final GuideLanguage guideLanguage;

  /// Per-project random keys for `StorageHelper` (32 characters each).
  final SessionStorageKeys sessionStorageKeys;

  /// Copy of this config with selected fields replaced.
  ///
  /// Used by setup commands to flip one integration (Firebase, secret key,
  /// CI/CD, platforms) without dropping the rest of the detected project.
  ProjectConfig copyWith({
    String? appName,
    String? displayName,
    String? androidPackage,
    String? iosBundleId,
    StateManagement? stateManagement,
    bool? useFirebase,
    bool? useSecretKey,
    StateManagementArchitecture? blocArchitecture,
    StateManagementArchitecture? riverpodArchitecture,
    Set<PlatformTarget>? platformTargets,
    CiCdScope? ciCdScope,
    CiCdProvider? ciCdProvider,
    GitLabRunnerMode? gitlabRunnerMode,
    Set<DeployTarget>? deployTargets,
    String? projectRoot,
    GuideLanguage? guideLanguage,
    SessionStorageKeys? sessionStorageKeys,
  }) {
    return ProjectConfig(
      appName: appName ?? this.appName,
      displayName: displayName ?? this.displayName,
      androidPackage: androidPackage ?? this.androidPackage,
      iosBundleId: iosBundleId ?? this.iosBundleId,
      stateManagement: stateManagement ?? this.stateManagement,
      useFirebase: useFirebase ?? this.useFirebase,
      useSecretKey: useSecretKey ?? this.useSecretKey,
      blocArchitecture: blocArchitecture ?? this.blocArchitecture,
      riverpodArchitecture: riverpodArchitecture ?? this.riverpodArchitecture,
      platformTargets: platformTargets ?? this.platformTargets,
      ciCdScope: ciCdScope ?? this.ciCdScope,
      ciCdProvider: ciCdProvider ?? this.ciCdProvider,
      gitlabRunnerMode: gitlabRunnerMode ?? this.gitlabRunnerMode,
      deployTargets: deployTargets ?? this.deployTargets,
      projectRoot: projectRoot ?? this.projectRoot,
      guideLanguage: guideLanguage ?? this.guideLanguage,
      sessionStorageKeys: sessionStorageKeys ?? this.sessionStorageKeys,
    );
  }

  bool get usesGitLabCi => hasCiCd && ciCdProvider == CiCdProvider.gitlab;

  bool get usesGitHubActions => hasCiCd && ciCdProvider == CiCdProvider.github;

  bool get gitLabSelfHostedShell =>
      usesGitLabCi && gitlabRunnerMode == GitLabRunnerMode.selfHostedShell;

  String get appDisplayName => displayName;

  String get projectPath =>
      projectRoot ?? path.join(Directory.current.path, appName);

  static const String defaultCiFlavor = 'staging';

  /// True when the project uses codegen beyond l10n (freezed, riverpod_generator, …).
  ///
  /// GetX only needs freezed/json_serializable outputs; Riverpod and Bloc also
  /// need `riverpod_generator` or bloc-related generated parts.
  bool get needsCodegen =>
      stateManagement == StateManagement.getx ||
      stateManagement == StateManagement.riverpod ||
      stateManagement == StateManagement.bloc ||
      stateManagement == StateManagement.provider;

  bool get hasCiCd => ciCdScope != CiCdScope.none;

  bool get hasCiDeploy => ciCdScope == CiCdScope.ciAndDeploy;

  bool get targetsAndroid => platformTargets.contains(PlatformTarget.android);

  bool get targetsIos => platformTargets.contains(PlatformTarget.ios);

  bool get targetsWeb => platformTargets.contains(PlatformTarget.web);

  /// True when GitLab jobs should use the generated `ci/Dockerfile`.
  bool get usesDockerRunner =>
      usesGitLabCi && gitlabRunnerMode == GitLabRunnerMode.dockerfile;

  /// `--flavor` applies to Android and iOS product flavors.
  bool get usesMobileFlavors => targetsAndroid || targetsIos;

  /// Resolved deploy targets when [hasCiDeploy]; defaults to [artifactsOnly].
  Set<DeployTarget> get resolvedDeployTargets {
    if (!hasCiDeploy) return const {};
    if (deployTargets.isEmpty) return {DeployTarget.artifactsOnly};
    return deployTargets;
  }

  String get flutterPlatformsArg =>
      platformTargets.map((p) => p.name).join(',');

  String platformTargetsLabel() =>
      platformTargets.map((p) => p.name).join(', ');

  String androidPackageForEnv(String env) {
    if (env == 'production') return androidPackage;
    return '$androidPackage.$env';
  }

  String iosBundleIdForEnv(String env) {
    if (env == 'production') return iosBundleId;
    return '$iosBundleId.$env';
  }

  List<String> get environments => const [
    'development',
    'staging',
    'production',
  ];
}
