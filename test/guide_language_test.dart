import 'dart:io';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/project_config_file.dart';
import 'package:xproject_generator/src/templates/guide_template.dart';

void main() {
  test('GUIDE.md is English only', () {
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
    expect(guide, contains('# Setup guide: App'));
    expect(guide, contains('## Table of contents'));
    expect(guide, contains('Firebase | No |'));
    expect(guide, isNot(contains('Panduan setup')));
    expect(guide, isNot(contains('Language / Bahasa')));
  });

  test('XProjectConfigFile stores app metadata', () async {
    final root = await Directory.systemTemp.createTemp('xproject_cfg');
    addTearDown(() => root.delete(recursive: true));
    final config = ProjectConfig(
      appName: 'demo',
      displayName: 'Demo App',
      androidPackage: 'com.example.demo',
      iosBundleId: 'com.example.demo',
      stateManagement: StateManagement.getx,
      useFirebase: false,
      useSecretKey: false,
      projectRoot: root.path,
    );
    await XProjectConfigFile.write(config);
    final text = await File('${root.path}/.xproject/config.yaml').readAsString();
    expect(text, contains('app_name: demo'));
    expect(text, isNot(contains('guide_language')));
  });
}
