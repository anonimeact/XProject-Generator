import 'dart:io';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/integrations/guide_writer.dart';

void main() {
  test('writeAll creates only GUIDE.md and removes legacy locale files', () async {
    final root = await Directory.systemTemp.createTemp('xproject_guides');
    addTearDown(() => root.delete(recursive: true));
    await File('${root.path}/GUIDE.en.md').writeAsString('old');
    await File('${root.path}/GUIDE.id.md').writeAsString('old');
    final config = ProjectConfig(
      appName: 'demo',
      displayName: 'Demo',
      androidPackage: 'com.example.demo',
      iosBundleId: 'com.example.demo',
      stateManagement: StateManagement.getx,
      useFirebase: false,
      useSecretKey: false,
      projectRoot: root.path,
    );
    await GuideWriter.writeAll(config);
    expect(File('${root.path}/GUIDE.md').existsSync(), isTrue);
    expect(File('${root.path}/GUIDE.en.md').existsSync(), isFalse);
    expect(File('${root.path}/GUIDE.id.md').existsSync(), isFalse);
    final guide = await File('${root.path}/GUIDE.md').readAsString();
    expect(guide, contains('# Setup guide: Demo'));
    expect(guide, isNot(contains('Panduan setup')));
  });
}
