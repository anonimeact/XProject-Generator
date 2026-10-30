import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/android_gradle_patches.dart';
import 'package:xproject_generator/src/integrations/ci_cd_integrator.dart';
import 'package:xproject_generator/src/integrations/firebase_integrator.dart';
import 'package:xproject_generator/src/integrations/firebase_native_files.dart';
import 'package:xproject_generator/src/integrations/platform_integrator.dart';
import 'package:xproject_generator/src/integrations/project_inspector.dart';
import 'package:xproject_generator/src/integrations/pubspec_editor.dart';
import 'package:xproject_generator/src/integrations/secret_key_integrator.dart';
import 'package:xproject_generator/src/integrations/setup_change_report.dart';
import 'package:xproject_generator/src/integrations/splash_firebase_patch.dart';
import 'package:xproject_generator/src/project_gitignore.dart';
import 'package:xproject_generator/src/templates/bloc/bloc_feature_template.dart';
import 'package:xproject_generator/src/templates/getx/getx_feature_template.dart';
import 'package:xproject_generator/src/templates/provider/provider_feature_template.dart';
import 'package:xproject_generator/src/templates/riverpod/riverpod_feature_template.dart';

import 'helpers/xproject_app_fixture.dart';

ProjectConfig _config({
  bool firebase = false,
  StateManagement stateManagement = StateManagement.riverpod,
  String? projectRoot,
  Set<PlatformTarget>? platforms,
}) {
  return minimalXprojectAppConfig(
    firebase: firebase,
    stateManagement: stateManagement,
    projectRoot: projectRoot,
    platforms: platforms,
  );
}

void main() {
  test('firebase placeholder json and plist are parseable', () {
    final jsonText = FirebaseNativeFiles.googleServicesJson(
      'com.example.my_app.development',
    );
    final decoded = jsonDecode(jsonText) as Map<String, Object?>;
    final client = (decoded['client'] as List<Object?>).first as Map<String, Object?>;
    final info = client['client_info'] as Map<String, Object?>;
    final android = info['android_client_info'] as Map<String, Object?>;
    expect(android['package_name'], 'com.example.my_app.development');
    expect(jsonText.contains('///'), isFalse);

    final plist = FirebaseNativeFiles.googleServiceInfoPlist(
      'com.example.my_app',
    );
    expect(plist, contains('<string>com.example.my_app</string>'));
    expect(plist.contains('///'), isFalse);
  });

  test('gradle plugins are inserted once, before the plugins block closes', () {
    const settings = '''
pluginManagement {
    repositories {
        google()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
}
''';
    final once = ensureFirebaseGradlePlugins(
      settings,
      isKotlinDsl: true,
      isSettingsFile: true,
    );
    expect(once, contains('id("com.google.gms.google-services") version "4.4.2" apply false'));
    expect(
      once,
      contains('id("com.google.firebase.crashlytics") version "3.0.3" apply false'),
    );
    expect(once.indexOf('com.android.application'), lessThan(once.indexOf('google-services')));
    expect(ensureFirebaseGradlePlugins(
      once,
      isKotlinDsl: true,
      isSettingsFile: true,
    ), once);

    const app = '''
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}
''';
    final appOnce = ensureFirebaseGradlePlugins(
      app,
      isKotlinDsl: true,
      isSettingsFile: false,
    );
    expect(appOnce, contains('id("com.google.gms.google-services")'));
    expect(appOnce, isNot(contains('version "4.4.2"')));
    expect(appOnce.indexOf('flutter-gradle-plugin'), lessThan(appOnce.indexOf('google-services')));
  });

  test('pubspec editor inserts only missing firebase packages', () {
    const pubspec = '''
name: my_app
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
''';
    final updated = PubspecEditor.addDependencies(
      pubspec,
      const [
        '  firebase_core: ^5.1.0',
        '  firebase_analytics: ^13.0.1',
      ],
    );
    expect('firebase_core:'.allMatches(updated).length, 1);
    expect(updated, contains('firebase_analytics: ^13.0.1'));
    expect(updated.indexOf('firebase_analytics'), lessThan(updated.indexOf('dev_dependencies:')));
    expect(
      PubspecEditor.addDependencies(updated, const ['  firebase_analytics: ^13.0.1']),
      updated,
    );
  });

  test('unmodified splash templates gain the create-time firebase variant', () {
    final config = _config();
    for (final state in StateManagement.values) {
      final plain = _splash(state, config, false);
      final firebase = _splash(state, config, true);
      final patched = enableFirebaseInSplash(
        source: plain,
        stateManagement: state,
        config: config,
      );
      expect(patched, firebase, reason: state.name);
      expect(
        enableFirebaseInSplash(
          source: patched,
          stateManagement: state,
          config: config,
        ),
        patched,
        reason: '${state.name} second pass',
      );
    }
  });

  test('customized splash keeps surrounding code and calls Firebase', () {
    const source = '''
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  Future<void> _start() async {
    await Future.delayed(Duration(seconds: 3));
    keep('still here');
    Get.offAllNamed(Routes.login);
  }
}
''';
    final patched = enableFirebaseInSplash(
      source: source,
      stateManagement: StateManagement.getx,
      config: _config(stateManagement: StateManagement.getx),
    );
    expect(patched, contains('FirebaseService.init'));
    expect(patched, contains("keep('still here')"));
    expect(patched, contains('package:flutter/material.dart'));
    expect(patched, isNot(contains('Duration(seconds: 3)')));
  });

  test('customized bloc splash replaces the const delay', () {
    const source = '''
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashBloc {
  Future<void> _onStarted() async {
    await Future.delayed(const Duration(seconds: 3));
    emit(state.copyWith(isFinished: true));
  }
}
''';
    final patched = enableFirebaseInSplash(
      source: source,
      stateManagement: StateManagement.bloc,
      config: _config(stateManagement: StateManagement.bloc),
    );
    expect(patched, contains('FirebaseService.init'));
    expect(patched, contains('emit(state.copyWith(isFinished: true))'));
    expect(patched, isNot(contains('const Duration(seconds: 3)')));
  });

  test('gitignore gains the secret key path when the marker already exists', () async {
    final root = await Directory.systemTemp.createTemp('xproject_gitignore');
    addTearDown(() => root.delete(recursive: true));
    final config = _config(projectRoot: root.path);
    await File('${root.path}/.gitignore').writeAsString('''
# XProject — sensitive & local
.env
.env.*
''');

    await ProjectGitignore.append(config.copyWith(useSecretKey: true));
    final text = await File('${root.path}/.gitignore').readAsString();
    expect(text, contains('lib/core/config/secretkey.dart'));
    expect('# XProject'.allMatches(text).length, 1);

    await ProjectGitignore.append(config.copyWith(useSecretKey: true));
    final again = await File('${root.path}/.gitignore').readAsString();
    expect('secretkey.dart'.allMatches(again).length, 1);
  });

  test('inspector reads an xproject app and rejects a plain flutter app', () async {
    final root = await writeMinimalXprojectApp();
    addTearDown(() => root.delete(recursive: true));

    final inspected = await ProjectInspector.inspect(root: root);
    expect(inspected.config.appName, 'my_app');
    expect(inspected.config.displayName, 'My App');
    expect(inspected.config.androidPackage, 'com.example.my_app');
    expect(inspected.config.stateManagement, StateManagement.riverpod);
    expect(inspected.config.useFirebase, isFalse);
    expect(inspected.config.useSecretKey, isFalse);
    expect(inspected.config.platformTargets, contains(PlatformTarget.android));
    expect(inspected.config.platformTargets, contains(PlatformTarget.ios));
    expect(inspected.firebaseReady, isFalse);
    expect(inspected.secretKeyReady, isFalse);
    expect(inspected.missingPlatforms, contains(PlatformTarget.web));

    final plain = await Directory.systemTemp.createTemp('xproject_plain');
    addTearDown(() => plain.delete(recursive: true));
    await Directory('${plain.path}/lib').create();
    await File('${plain.path}/pubspec.yaml').writeAsString('name: plain\n');
    expect(
      () => ProjectInspector.inspect(root: plain),
      throwsA(isA<SetupException>()),
    );
  });

  test('firebase setup is idempotent and does not replace real config', () async {
    final root = await writeMinimalXprojectApp();
    addTearDown(() => root.delete(recursive: true));
    const realJson = '{"project_info":{"project_id":"real"}}\n';
    final jsonFile = File(
      '${root.path}/android/app/src/development/google-services.json',
    );
    await jsonFile.parent.create(recursive: true);
    await jsonFile.writeAsString(realJson);

    final config = (await ProjectInspector.inspect(root: root)).config;
    final first = await FirebaseIntegrator.apply(config.copyWith(useFirebase: true));
    expect(first.written, contains('pubspec.yaml'));
    expect(first.written, contains('lib/core/services/firebase/firebase_service.dart'));
    expect(first.skipped, contains('android/app/src/development/google-services.json'));
    expect(await jsonFile.readAsString(), realJson);

    final splash = await File(
      '${root.path}/lib/features/splash/presentation/providers/splash_provider.dart',
    ).readAsString();
    expect(splash, contains('FirebaseService.init'));

    final pubspec = await File('${root.path}/pubspec.yaml').readAsString();
    expect('firebase_core:'.allMatches(pubspec).length, 1);
    expect(pubspec, contains('firebase_crashlytics:'));

    final settings = await File('${root.path}/android/settings.gradle.kts').readAsString();
    expect(settings, contains('com.google.gms.google-services'));
    final guide = await File('${root.path}/GUIDE.md').readAsString();
    expect(guide, contains('Firebase | Yes |'));

    final second = await FirebaseIntegrator.apply(
      (await ProjectInspector.inspect(root: root)).config.copyWith(useFirebase: true),
    );
    expect(second.written, isEmpty);
    expect(await File('${root.path}/GUIDE.md').readAsString(), guide);
  });

  test('secret key setup switches the loader and can be run twice', () async {
    final root = await writeMinimalXprojectApp();
    addTearDown(() => root.delete(recursive: true));
    final originalEnv = await File('${root.path}/.env.development').readAsString();
    final config = (await ProjectInspector.inspect(root: root)).config;

    final first = await SecretKeyIntegrator.apply(config.copyWith(useSecretKey: true));
    expect(first.written, contains('lib/core/config/get_env.dart'));
    expect(first.written, contains('lib/core/config/cryptic.dart'));
    expect(first.written, contains('lib/core/config/secretkey.dart'));
    expect(first.written, contains('lib/app.dart'));
    expect(first.written, contains('.gitignore'));

    final app = await File('${root.path}/lib/app.dart').readAsString();
    expect(app, contains('isEncryptKeyAndValue: true'));
    expect(app, contains("import 'core/config/secretkey.dart';"));
    final getEnv = await File('${root.path}/lib/core/config/get_env.dart').readAsString();
    expect(getEnv, contains('SecretKey.unixKey'));
    expect(await File('${root.path}/.env.development').readAsString(), originalEnv);
    expect(
      await File('${root.path}/.gitignore').readAsString(),
      contains('lib/core/config/secretkey.dart'),
    );

    final second = await SecretKeyIntegrator.apply(
      (await ProjectInspector.inspect(root: root)).config,
    );
    expect(second.written, isEmpty);
  });

  test('ci setup refuses to overwrite until asked', () async {
    final root = await writeMinimalXprojectApp();
    addTearDown(() => root.delete(recursive: true));
    final config = (await ProjectInspector.inspect(root: root)).config.copyWith(
      ciCdScope: CiCdScope.ciOnly,
      ciCdProvider: CiCdProvider.gitlab,
    );
    final smoke = File('${root.path}/test/smoke_test.dart');
    await smoke.parent.create(recursive: true);
    await smoke.writeAsString('// keep me\n');

    final first = await CiCdIntegrator.apply(config);
    expect(await File('${root.path}/.gitlab-ci.yml').exists(), isTrue);
    expect(first.written, contains('.gitlab-ci.yml'));
    expect(first.written, isNot(contains('test/smoke_test.dart')));
    expect(await smoke.readAsString(), '// keep me\n');
    expect(await File('${root.path}/fastlane/Fastfile').exists(), isFalse);

    expect(
      () => CiCdIntegrator.apply(config),
      throwsA(isA<SetupException>()),
    );

    final replaced = await CiCdIntegrator.apply(
      config.copyWith(
        ciCdScope: CiCdScope.ciAndDeploy,
        deployTargets: {DeployTarget.artifactsOnly},
      ),
      overwrite: true,
    );
    expect(replaced.written, contains('fastlane/Fastfile'));
    expect(await File('${root.path}/.gitlab-ci.yml').readAsString(), contains('flutter test'));
  });

  test('platform arguments keep flutter create order and a fake runner', () async {
    expect(
      PlatformIntegrator.flutterCreateArguments({
        PlatformTarget.linux,
        PlatformTarget.web,
      }),
      ['create', '--platforms', 'web,linux', '.'],
    );

    final root = await Directory.systemTemp.createTemp('xproject_platforms');
    addTearDown(() => root.delete(recursive: true));
    final config = _config(
      projectRoot: root.path,
      platforms: {PlatformTarget.android, PlatformTarget.ios},
    );
    final report = await PlatformIntegrator.apply(
      config: config,
      additional: {PlatformTarget.web},
      runner: (executable, arguments, workingDirectory) async {
        expect(executable, 'flutter');
        expect(workingDirectory, root.path);
        expect(arguments, ['create', '--platforms', 'web', '.']);
        return ProcessResult(0, 0, '', '');
      },
    );
    expect(report.written, contains('web'));
    expect(await File('${root.path}/GUIDE.md').readAsString(), contains('web'));
  });
}

String _splash(StateManagement state, ProjectConfig config, bool firebase) {
  final resolved = config.copyWith(useFirebase: firebase);
  switch (state) {
    case StateManagement.getx:
      return GetxFeatureTemplate.splashController(resolved);
    case StateManagement.riverpod:
      return RiverpodFeatureTemplate.splashProvider(resolved);
    case StateManagement.bloc:
      return BlocFeatureTemplate.splashBloc(resolved);
    case StateManagement.provider:
      return ProviderFeatureTemplate.splashNotifier(resolved);
  }
}
