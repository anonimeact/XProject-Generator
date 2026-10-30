import '../core/configs/project_config.dart';

/// Builds VS Code launch/tasks JSON structures for generated projects.
class VsCodeConfigBuilder {
  static Map<String, dynamic> launchJson(ProjectConfig config) {
    Map<String, dynamic> configuration({
      required String name,
      required String entry,
      required String flavor,
    }) {
      return {
        'name': name,
        'request': 'launch',
        'type': 'dart',
        'program': entry,
        'args': [
          if (config.usesMobileFlavors) ...['--flavor', flavor],
          '--target',
          entry,
        ],
      };
    }

    return {
      'version': '0.2.0',
      'configurations': [
        configuration(
          name: '[DEV] ${config.appDisplayName}',
          entry: 'lib/main_development.dart',
          flavor: 'development',
        ),
        configuration(
          name: '[STG] ${config.appDisplayName}',
          entry: 'lib/main_staging.dart',
          flavor: 'staging',
        ),
        configuration(
          name: config.appDisplayName,
          entry: 'lib/main_production.dart',
          flavor: 'production',
        ),
      ],
    };
  }

  static Map<String, dynamic> tasksJson(ProjectConfig config) {
    final tasks = <Map<String, dynamic>>[
      {
        'label': 'Generate Resources [ln10]',
        'type': 'shell',
        'command': 'flutter',
        'args': ['gen-l10n'],
        'group': {'kind': 'build', 'isDefault': true},
        'presentation': {'reveal': 'silent', 'panel': 'shared'},
        'detail': 'Generate resources using gen-l10n.',
      },
      {
        'label': 'Synchronize Build Runners',
        'type': 'shell',
        'command': 'flutter',
        'args': [
          'pub',
          'run',
          'build_runner',
          'build',
          '--delete-conflicting-outputs',
        ],
        'problemMatcher': [],
        'group': {'kind': 'build', 'isDefault': true},
        'detail':
            'Run this task to synchronize freezed and other build runners actions files.',
      },
      if (config.targetsIos) ...[
        _buildTask(
          label: 'Build IPA - Production',
          artifact: 'ipa',
          flavor: 'production',
          entry: 'lib/main_production.dart',
        ),
        _buildTask(
          label: 'Build IPA - Staging',
          artifact: 'ipa',
          flavor: 'staging',
          entry: 'lib/main_staging.dart',
        ),
      ],
      if (config.targetsAndroid) ...[
        _buildTask(
          label: 'Build APK - Production',
          artifact: 'apk',
          flavor: 'production',
          entry: 'lib/main_production.dart',
          splitPerAbi: true,
        ),
        _buildTask(
          label: 'Build APK - Staging',
          artifact: 'apk',
          flavor: 'staging',
          entry: 'lib/main_staging.dart',
          splitPerAbi: true,
        ),
        _buildTask(
          label: 'Build APK - Development',
          artifact: 'apk',
          flavor: 'development',
          entry: 'lib/main_development.dart',
          splitPerAbi: true,
        ),
        _buildTask(
          label: 'Build AppBundle - Production',
          artifact: 'appbundle',
          flavor: 'production',
          entry: 'lib/main_production.dart',
        ),
        _buildTask(
          label: 'Build AppBundle - Staging',
          artifact: 'appbundle',
          flavor: 'staging',
          entry: 'lib/main_staging.dart',
        ),
        _buildTask(
          label: 'Build AppBundle - Development',
          artifact: 'appbundle',
          flavor: 'development',
          entry: 'lib/main_development.dart',
        ),
      ],
      {
        'label': 'Clean & Get Packages',
        'type': 'shell',
        'command': 'flutter',
        'args': ['clean'],
        'dependsOn': <String>[],
        'problemMatcher': <String>[],
      },
      _runTask(
        config,
        label: 'Run Development',
        flavor: 'development',
        entry: 'lib/main_development.dart',
      ),
      _runTask(
        config,
        label: 'Run Staging',
        flavor: 'staging',
        entry: 'lib/main_staging.dart',
      ),
      _runTask(
        config,
        label: 'Run Production',
        flavor: 'production',
        entry: 'lib/main_production.dart',
      ),
    ];

    return {'version': '2.0.0', 'tasks': tasks};
  }

  static Map<String, dynamic> _buildTask({
    required String label,
    required String artifact,
    required String flavor,
    required String entry,
    bool splitPerAbi = false,
  }) {
    return {
      'label': label,
      'type': 'shell',
      'command': 'flutter',
      'args': [
        'build',
        artifact,
        if (splitPerAbi) '--split-per-abi',
        '--release',
        '--flavor',
        flavor,
        '-t',
        entry,
      ],
    };
  }

  static Map<String, dynamic> _runTask(
    ProjectConfig config, {
    required String label,
    required String flavor,
    required String entry,
  }) {
    return {
      'label': label,
      'type': 'shell',
      'command': 'flutter',
      'args': [
        'run',
        if (config.usesMobileFlavors) ...['--flavor', flavor],
        '-t',
        entry,
      ],
    };
  }
}
