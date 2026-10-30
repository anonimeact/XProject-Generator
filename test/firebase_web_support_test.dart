import 'dart:io';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/integrations/firebase_service_patch.dart';
import 'package:xproject_generator/src/integrations/firebase_shared_support.dart';
import 'package:xproject_generator/src/integrations/setup_change_report.dart';
import 'package:xproject_generator/src/templates/firebase/firebase_options_template.dart';

void main() {
  test('firebase options template includes web when requested', () {
    final text = FirebaseOptionsTemplate.content(
      ProjectConfig(
        appName: 'demo',
        displayName: 'Demo',
        androidPackage: 'com.example.demo',
        iosBundleId: 'com.example.demo',
        stateManagement: StateManagement.getx,
        useFirebase: true,
        useSecretKey: false,
        platformTargets: {PlatformTarget.web},
      ),
      includeWeb: true,
    );
    expect(text, contains('static const FirebaseOptions web'));
    expect(text, contains('YOUR_WEB_API_KEY'));
    expect(text, isNot(contains('static const FirebaseOptions android')));
  });

  test('FirebaseSharedSupport writes options and messaging sw when missing', () async {
    final root = await Directory.systemTemp.createTemp('xproject_firebase_web');
    addTearDown(() => root.delete(recursive: true));
    await Directory('${root.path}/web').create(recursive: true);
    await File('${root.path}/web/index.html').writeAsString('<html></html>');

    final config = ProjectConfig(
      appName: 'demo',
      displayName: 'Demo',
      androidPackage: 'com.example.demo',
      iosBundleId: 'com.example.demo',
      stateManagement: StateManagement.getx,
      useFirebase: true,
      useSecretKey: false,
      platformTargets: {PlatformTarget.web},
      projectRoot: root.path,
    );

    final report = SetupChangeReport();
    await FirebaseSharedSupport.apply(
      config,
      report,
      firebaseServiceImport: "import '../../../firebase_options.dart';",
    );

    expect(File('${root.path}/lib/firebase_options.dart').existsSync(), isTrue);
    expect(
      File('${root.path}/web/firebase-messaging-sw.js').existsSync(),
      isTrue,
    );
    expect(report.written, contains('lib/firebase_options.dart'));
  });

  test('FirebaseServicePatch upgrades bare initializeApp', () {
    const before = '''
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp();
  }
}
''';
    final after = FirebaseServicePatch.upgradeForFirebaseOptions(
      source: before,
      firebaseOptionsImport: "import '../../../firebase_options.dart';",
    );
    expect(after, contains('DefaultFirebaseOptions.currentPlatform'));
    expect(after, contains("import '../../../firebase_options.dart';"));
  });
}
