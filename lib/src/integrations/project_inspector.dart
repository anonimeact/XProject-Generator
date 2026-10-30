import 'dart:io';

import 'package:path/path.dart' as path;

import '../../core/configs/project_config.dart';
import '../../xfeature_generator.dart';
import 'setup_change_report.dart';

/// Snapshot of an existing XProject app, read from disk.
///
/// Setup commands start here so they can add one integration without asking
/// again for the app name, package id, or state management.
class InspectedProject {
  const InspectedProject({
    required this.root,
    required this.config,
    required this.firebaseReady,
    required this.secretKeyReady,
    required this.ciReady,
  });

  final Directory root;
  final ProjectConfig config;

  /// True when Dart Firebase startup, the dependency, and native hooks that
  /// apply to the selected platforms are all present.
  final bool firebaseReady;

  /// True when encrypted env loading, `cryptic.dart`, and the storage flag
  /// are all present.
  final bool secretKeyReady;

  /// True when a GitLab CI file or the GitHub Actions workflow exists.
  final bool ciReady;

  /// Flutter platforms that do not have a directory in this project yet.
  Set<PlatformTarget> get missingPlatforms {
    return PlatformTarget.values
        .where((target) => !config.platformTargets.contains(target))
        .toSet();
  }
}

/// Reads an XProject Flutter app from [root], or from the current directory.
abstract final class ProjectInspector {
  static Future<InspectedProject> inspect({Directory? root}) async {
    final Directory projectRoot;
    if (root != null) {
      projectRoot = root;
    } else {
      try {
        projectRoot = FeatureGenerator.findFlutterProjectRoot();
      } on Exception catch (error) {
        throw SetupException(
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    }

    final pubspecFile = File(path.join(projectRoot.path, 'pubspec.yaml'));
    final libDir = Directory(path.join(projectRoot.path, 'lib'));
    if (!pubspecFile.existsSync() || !libDir.existsSync()) {
      throw SetupException(
        'Not a Flutter project. Run this command inside an app created with '
        '`xproject create`.',
      );
    }

    final appFile = File(path.join(projectRoot.path, 'lib', 'app.dart'));
    final envConfig = File(
      path.join(projectRoot.path, 'lib', 'core', 'config', 'env_config.dart'),
    );
    if (!appFile.existsSync() || !envConfig.existsSync()) {
      throw SetupException(
        'This Flutter project was not scaffolded by XProject. '
        'Expected lib/app.dart and lib/core/config/env_config.dart.',
      );
    }

    final appSource = await appFile.readAsString();
    if (!appSource.contains('initApp')) {
      throw SetupException(
        'lib/app.dart has no initApp(). Setup only patches XProject apps.',
      );
    }

    final pubspec = await pubspecFile.readAsString();
    final appName = _pubspecName(pubspec);
    final StateManagement stateManagement;
    final StateManagementArchitecture? architecture;
    try {
      stateManagement = await FeatureGenerator.detectStateManagementFromProject(
        projectRoot,
      );
      architecture = await FeatureGenerator.detectArchitectureFromProject(
        root: projectRoot,
        stateManagement: stateManagement,
      );
    } on Exception catch (error) {
      throw SetupException(error.toString().replaceFirst('Exception: ', ''));
    }

    final platforms = _platforms(projectRoot);
    final androidPackage = _androidPackage(projectRoot, appName);
    final iosBundleId = _iosBundleId(projectRoot, androidPackage);
    final useFirebase = _usesFirebase(projectRoot, pubspec);
    final useSecretKey = _usesSecretKey(projectRoot, appSource);
    final ci = _readCi(projectRoot);

    final config = ProjectConfig(
      appName: appName,
      displayName: _displayName(appSource, projectRoot, appName),
      androidPackage: androidPackage,
      iosBundleId: iosBundleId,
      stateManagement: stateManagement,
      useFirebase: useFirebase,
      useSecretKey: useSecretKey,
      blocArchitecture: stateManagement == StateManagement.bloc
          ? architecture
          : null,
      riverpodArchitecture: stateManagement == StateManagement.riverpod
          ? architecture
          : null,
      platformTargets: platforms,
      ciCdScope: ci.scope,
      ciCdProvider: ci.provider,
      gitlabRunnerMode: ci.runnerMode,
      deployTargets: ci.deployTargets,
      projectRoot: projectRoot.path,
    );

    return InspectedProject(
      root: projectRoot,
      config: config,
      firebaseReady: _firebaseReady(
        projectRoot: projectRoot,
        pubspec: pubspec,
        stateManagement: stateManagement,
        platforms: config.platformTargets,
      ),
      secretKeyReady: _secretKeyReady(projectRoot, appSource),
      ciReady: ci.scope != CiCdScope.none,
    );
  }

  static String _pubspecName(String pubspec) {
    final match = RegExp(
      r'^name:\s*([A-Za-z0-9_]+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    if (match == null) {
      throw SetupException('pubspec.yaml is missing a name: field.');
    }
    return match.group(1)!;
  }

  static String _displayName(
    String appSource,
    Directory root,
    String appName,
  ) {
    final title = RegExp(r"title:\s*'([^']*)'").firstMatch(appSource);
    if (title != null && title.group(1)!.trim().isNotEmpty) {
      return title.group(1)!.trim();
    }

    final gradle = _readAndroidGradle(root);
    if (gradle != null) {
      final resValue = RegExp(
        r'resValue\(\s*"string"\s*,\s*"app_name"\s*,\s*"([^"]+)"\s*\)',
      ).firstMatch(gradle);
      if (resValue != null && resValue.group(1)!.trim().isNotEmpty) {
        return resValue.group(1)!.trim();
      }
    }

    return appName;
  }

  static Set<PlatformTarget> _platforms(Directory root) {
    const names = <PlatformTarget, String>{
      PlatformTarget.android: 'android',
      PlatformTarget.ios: 'ios',
      PlatformTarget.web: 'web',
      PlatformTarget.windows: 'windows',
      PlatformTarget.macos: 'macos',
      PlatformTarget.linux: 'linux',
    };
    return names.entries
        .where(
          (entry) => Directory(path.join(root.path, entry.value)).existsSync(),
        )
        .map((entry) => entry.key)
        .toSet();
  }

  static String _androidPackage(Directory root, String appName) {
    final gradle = _readAndroidGradle(root);
    if (gradle != null) {
      final applicationId = RegExp(
        r'applicationId\s*=?\s*"([^"]+)"',
      ).firstMatch(gradle);
      if (applicationId != null) {
        return applicationId.group(1)!;
      }
      final namespace = RegExp(
        r'namespace\s*=?\s*"([^"]+)"',
      ).firstMatch(gradle);
      if (namespace != null) {
        return namespace.group(1)!;
      }
    }
    return 'com.example.$appName';
  }

  static String? _readAndroidGradle(Directory root) {
    final appDir = path.join(root.path, 'android', 'app');
    for (final name in <String>['build.gradle.kts', 'build.gradle']) {
      final file = File(path.join(appDir, name));
      if (file.existsSync()) {
        return file.readAsStringSync();
      }
    }
    return null;
  }

  static String _iosBundleId(Directory root, String fallback) {
    final pbx = File(
      path.join(root.path, 'ios', 'Runner.xcodeproj', 'project.pbxproj'),
    );
    if (!pbx.existsSync()) {
      return fallback;
    }
    final matches = RegExp(
      r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);',
    ).allMatches(pbx.readAsStringSync());
    final ids = matches
        .map((match) => match.group(1)!.trim())
        .where((id) => !id.contains(r'$') && !id.contains('org.flutter'))
        .toList();
    if (ids.isEmpty) {
      return fallback;
    }
    for (final id in ids) {
      if (!id.endsWith('.development') && !id.endsWith('.staging')) {
        return id;
      }
    }
    return ids.first;
  }

  static bool _usesFirebase(Directory root, String pubspec) {
    if (RegExp(r'^\s*firebase_core:\s+\S', multiLine: true).hasMatch(pubspec)) {
      return true;
    }
    return File(
      path.join(
        root.path,
        'lib',
        'core',
        'services',
        'firebase',
        'firebase_service.dart',
      ),
    ).existsSync();
  }

  static bool _usesSecretKey(Directory root, String appSource) {
    if (RegExp(r'isEncryptKeyAndValue:\s*true').hasMatch(appSource)) {
      return true;
    }
    if (File(
      path.join(root.path, 'lib', 'core', 'config', 'cryptic.dart'),
    ).existsSync()) {
      return true;
    }
    final getEnv = File(
      path.join(root.path, 'lib', 'core', 'config', 'get_env.dart'),
    );
    if (!getEnv.existsSync()) {
      return false;
    }
    return getEnv.readAsStringSync().contains('SecretKey');
  }

  static bool _firebaseReady({
    required Directory projectRoot,
    required String pubspec,
    required StateManagement stateManagement,
    required Set<PlatformTarget> platforms,
  }) {
    final hasCore = RegExp(
      r'^\s*firebase_core:\s+\S',
      multiLine: true,
    ).hasMatch(pubspec);
    final hasService = File(
      path.join(
        projectRoot.path,
        'lib',
        'core',
        'services',
        'firebase',
        'firebase_service.dart',
      ),
    ).existsSync();
    final splash = File(
      path.join(projectRoot.path, _splashRelative(stateManagement)),
    );
    final splashReady =
        splash.existsSync() &&
        splash.readAsStringSync().contains('FirebaseService.init');
    if (!hasCore || !hasService || !splashReady) {
      return false;
    }

    if (platforms.contains(PlatformTarget.android)) {
      final settings = _settingsGradle(projectRoot);
      if (settings == null ||
          !settings.contains('com.google.gms.google-services')) {
        return false;
      }
    }
    if (platforms.contains(PlatformTarget.ios)) {
      if (!File(path.join(projectRoot.path, 'ios', 'firebase.sh')).existsSync()) {
        return false;
      }
    }
    return true;
  }

  static String _splashRelative(StateManagement stateManagement) {
    switch (stateManagement) {
      case StateManagement.getx:
        return 'lib/features/splash/controllers/splash_controller.dart';
      case StateManagement.riverpod:
        return 'lib/features/splash/presentation/providers/splash_provider.dart';
      case StateManagement.bloc:
        return 'lib/features/splash/presentation/bloc/splash_bloc.dart';
      case StateManagement.provider:
        return 'lib/features/splash/presentation/notifiers/splash_notifier.dart';
    }
  }

  static bool _secretKeyReady(Directory root, String appSource) {
    final cryptic = File(
      path.join(root.path, 'lib', 'core', 'config', 'cryptic.dart'),
    );
    final getEnv = File(
      path.join(root.path, 'lib', 'core', 'config', 'get_env.dart'),
    );
    if (!cryptic.existsSync() || !getEnv.existsSync()) {
      return false;
    }
    if (!getEnv.readAsStringSync().contains('SecretKey')) {
      return false;
    }
    return RegExp(r'isEncryptKeyAndValue:\s*true').hasMatch(appSource);
  }

  static _CiSnapshot _readCi(Directory root) {
    final gitlab = File(path.join(root.path, '.gitlab-ci.yml'));
    final github = File(
      path.join(root.path, '.github', 'workflows', 'flutter_ci.yml'),
    );
    if (!gitlab.existsSync() && !github.existsSync()) {
      return const _CiSnapshot(
        scope: CiCdScope.none,
        provider: CiCdProvider.gitlab,
        runnerMode: GitLabRunnerMode.sharedFlutterImage,
        deployTargets: <DeployTarget>{},
      );
    }

    final provider = gitlab.existsSync()
        ? CiCdProvider.gitlab
        : CiCdProvider.github;
    final fastfile = File(path.join(root.path, 'fastlane', 'Fastfile'));
    final scope = fastfile.existsSync()
        ? CiCdScope.ciAndDeploy
        : CiCdScope.ciOnly;

    var runnerMode = GitLabRunnerMode.sharedFlutterImage;
    if (File(path.join(root.path, 'ci', 'Dockerfile')).existsSync()) {
      runnerMode = GitLabRunnerMode.dockerfile;
    } else if (File(
      path.join(root.path, 'ci', 'GITLAB_RUNNER_SETUP.md'),
    ).existsSync()) {
      runnerMode = GitLabRunnerMode.selfHostedShell;
    } else if (gitlab.existsSync() &&
        gitlab.readAsStringSync().contains('self-hosted')) {
      runnerMode = GitLabRunnerMode.selfHostedShell;
    }

    final deployTargets = <DeployTarget>{};
    if (fastfile.existsSync()) {
      final body = fastfile.readAsStringSync();
      if (body.contains('deploy_play_internal')) {
        deployTargets.add(DeployTarget.playInternal);
      }
      if (body.contains('deploy_testflight')) {
        deployTargets.add(DeployTarget.testFlight);
      }
      if (body.contains('deploy_firebase')) {
        deployTargets.add(DeployTarget.firebaseAppDistribution);
      }
      if (deployTargets.isEmpty) {
        deployTargets.add(DeployTarget.artifactsOnly);
      }
    }

    return _CiSnapshot(
      scope: scope,
      provider: provider,
      runnerMode: runnerMode,
      deployTargets: deployTargets,
    );
  }

  static String? _settingsGradle(Directory root) {
    for (final name in <String>['settings.gradle.kts', 'settings.gradle']) {
      final file = File(path.join(root.path, 'android', name));
      if (file.existsSync()) {
        return file.readAsStringSync();
      }
    }
    return null;
  }
}

class _CiSnapshot {
  const _CiSnapshot({
    required this.scope,
    required this.provider,
    required this.runnerMode,
    required this.deployTargets,
  });

  final CiCdScope scope;
  final CiCdProvider provider;
  final GitLabRunnerMode runnerMode;
  final Set<DeployTarget> deployTargets;
}
