import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/templates/guide_template.dart';

void main() {
  test('GuideTemplate includes project-specific identifiers', () {
    final config = ProjectConfig(
      appName: 'my_app',
      displayName: 'My App',
      androidPackage: 'com.example.my_app',
      iosBundleId: 'com.example.my_app',
      stateManagement: StateManagement.riverpod,
      useFirebase: true,
      useSecretKey: true,
      riverpodArchitecture: StateManagementArchitecture.clean,
    );

    final guide = GuideTemplate.content(config);

    expect(guide, contains('# Setup guide: My App'));
    expect(guide, contains('com.example.my_app.development'));
    expect(guide, contains('Secret key (SecureCompressor)'));
    expect(guide, contains('##'));
    expect(guide, contains('Firebase'));
  });

  test('GuideTemplate omits Firebase section when disabled', () {
    final config = ProjectConfig(
      appName: 'plain_app',
      displayName: 'Plain',
      androidPackage: 'com.example.plain',
      iosBundleId: 'com.example.plain',
      stateManagement: StateManagement.getx,
      useFirebase: false,
      useSecretKey: false,
    );

    final guide = GuideTemplate.content(config);

    expect(guide, contains('Firebase | No |'));
    expect(guide.contains('heading(\'Firebase\')'), isFalse);
    expect(guide, contains('Table of contents'));
  });
}
