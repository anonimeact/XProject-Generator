import 'dart:io';

import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/templates/common_templates.dart';
import 'package:xproject_generator/src/templates/riverpod/riverpod_feature_template.dart';

ProjectConfig minimalXprojectAppConfig({
  bool firebase = false,
  StateManagement stateManagement = StateManagement.riverpod,
  String? projectRoot,
  Set<PlatformTarget>? platforms,
}) {
  return ProjectConfig(
    appName: 'my_app',
    displayName: 'My App',
    androidPackage: 'com.example.my_app',
    iosBundleId: 'com.example.my_app',
    stateManagement: stateManagement,
    useFirebase: firebase,
    useSecretKey: false,
    projectRoot: projectRoot,
    platformTargets: platforms,
  );
}

/// Minimal on-disk XProject app for setup integration tests.
Future<Directory> writeMinimalXprojectApp() async {
  final root = await Directory.systemTemp.createTemp('xproject_app');
  Future<void> write(String relative, String contents) async {
    final file = File('${root.path}/$relative');
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  await write('pubspec.yaml', '''
name: my_app
description: A new Flutter project
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>3.10.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.4.3
  dio_extended: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
''');
  await write('lib/core/config/env_config.dart', "import 'get_env.dart';\n");
  await write('lib/core/config/get_env.dart', CommonTemplates.getEnvSimple());
  await write('lib/app.dart', '''
import 'core/config/env_config.dart';

class App {
  // Generated projects set this on the root widget: title: 'My App'
}

enum Environment { development, staging, production }

Future<void> initApp(Environment env) async {
  await StorageHelper.initialize('my_app', isEncryptKeyAndValue: false);
  await EnvConfig.load(env.name);
}

class StorageHelper {
  static Future<void> initialize(
    String name, {
    required bool isEncryptKeyAndValue,
  }) async {}
}

class EnvConfig {
  static Future<void> load(String env) async {}
}
''');

  final splashConfig = minimalXprojectAppConfig();
  await write(
    'lib/features/splash/presentation/providers/splash_provider.dart',
    RiverpodFeatureTemplate.splashProvider(splashConfig),
  );
  await write('.env.development', 'BASE_URL=https://development\n');
  await write('.gitignore', '''
# XProject — sensitive & local
.env
.env.*
''');
  await write('android/settings.gradle.kts', '''
pluginManagement {
    repositories {
        google()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
}
''');
  await write('android/app/build.gradle.kts', '''
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.my_app"
    }
}

flutter {
    source = "../.."
}
''');
  await write('android/gradle.properties', 'org.gradle.jvmargs=-Xmx4G\n');
  await write('ios/Runner/AppDelegate.swift', '''
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
''');
  await Directory('${root.path}/ios').create(recursive: true);
  return root;
}
