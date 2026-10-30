import 'dart:io';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/app_icon_config.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/structure_generator.dart';
import 'package:xproject_generator/src/templates/common_templates.dart';

void main() {
  test('default app icon asset exists in generator package', () async {
    final file = await AppIconConfig.bundledLogoFile();
    expect(file.existsSync(), isTrue);
  });

  test('generated pubspec documents launcher icon path', () {
    expect(
      CommonTemplates.flutterLauncherIconsBlock(),
      contains(AppIconConfig.projectAssetPath),
    );
    expect(
      CommonTemplates.flutterLauncherIconsBlock(),
      contains('dart run flutter_launcher_icons'),
    );
  });

  test('copyDefaultAppIcon writes PNG into generated project', () async {
    final temp = await Directory.systemTemp.createTemp('xproject_icon');
    addTearDown(() => temp.delete(recursive: true));

    final config = ProjectConfig(
      appName: 'icon_test',
      displayName: 'Icon Test',
      androidPackage: 'com.example.icon_test',
      iosBundleId: 'com.example.icon_test',
      stateManagement: StateManagement.provider,
      useFirebase: false,
      useSecretKey: false,
      projectRoot: temp.path,
    );
    await Directory(config.projectPath).create(recursive: true);

    await StructureGenerator.copyDefaultAppIcon(config);

    final dest = File('${config.projectPath}/${AppIconConfig.projectAssetPath}');
    expect(dest.existsSync(), isTrue);
    expect(await dest.length(), greaterThan(100));
  });
}
