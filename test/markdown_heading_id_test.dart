import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/templates/guide_template.dart';

void main() {
  test('part 2 TOC links match VS Code preview heading ids', () {
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

    expect(
      guide,
      contains('[Initial steps & dependencies](#1-initial-steps--dependencies)'),
    );
    expect(guide, contains('### 1. Initial steps & dependencies\n'));
    expect(
      guide,
      contains('[VS Code: run & build](#7-vs-code-run--build)'),
    );
    expect(guide, contains('### 7. VS Code: run & build\n'));
    expect(
      guide,
      contains('[Environment files (.env)](#2-environment-files-env)'),
    );
  });
}
