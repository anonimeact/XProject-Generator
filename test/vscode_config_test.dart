import 'dart:convert';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/vscode_config_builder.dart';

void main() {
  final config = ProjectConfig(
    appName: 'demo',
    displayName: 'Demo App',
    androidPackage: 'com.example.demo',
    iosBundleId: 'com.example.demo',
    stateManagement: StateManagement.getx,
    useFirebase: false,
    useSecretKey: false,
  );

  test('launch.json has three flavor configurations', () {
    final json = VsCodeConfigBuilder.launchJson(config);
    final encoded = jsonEncode(json);
    expect(encoded, contains('[DEV]'));
    expect(encoded, contains('[STG]'));
    expect(encoded, contains('main_development.dart'));
    expect(encoded, contains('main_staging.dart'));
    expect(encoded, contains('main_production.dart'));
  });

  test('tasks.json includes run and APK for all flavors', () {
    final tasks = VsCodeConfigBuilder.tasksJson(config)['tasks'] as List;
    final labels = tasks.map((t) => t['label'] as String).toList();
    expect(labels, contains('Run Development'));
    expect(labels, contains('Run Staging'));
    expect(labels, contains('Run Production'));
    expect(labels, contains('Build APK - Development'));
    expect(labels, contains('Build AppBundle - Development'));
    expect(labels, contains('Build IPA - Production'));
  });

  test('web-only configs omit mobile flavor and native build tasks', () {
    final web = ProjectConfig(
      appName: 'webapp',
      displayName: 'Web App',
      androidPackage: 'com.example.webapp',
      iosBundleId: 'com.example.webapp',
      stateManagement: StateManagement.getx,
      useFirebase: false,
      useSecretKey: false,
      platformTargets: {PlatformTarget.web},
    );

    final launch = jsonEncode(VsCodeConfigBuilder.launchJson(web));
    expect(launch, isNot(contains('--flavor')));
    expect(launch, contains('lib/main_development.dart'));

    final labels = (VsCodeConfigBuilder.tasksJson(web)['tasks'] as List)
        .map((t) => t['label'] as String)
        .toList();
    expect(labels, contains('Run Development'));
    expect(labels, isNot(contains('Build APK - Development')));
    expect(labels, isNot(contains('Build IPA - Production')));
  });
}
