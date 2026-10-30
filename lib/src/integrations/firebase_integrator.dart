import 'dart:io';

import 'package:path/path.dart' as path;

import '../../core/configs/project_config.dart';
import '../structure_generator.dart';
import '../templates/common_templates.dart';
import 'firebase_dependencies.dart';
import 'guide_refresher.dart';
import 'pubspec_editor.dart';
import 'setup_change_report.dart';
import 'splash_firebase_patch.dart';

/// Adds Firebase to an XProject app that was created with Firebase set to no.
///
/// The same native steps run during `xproject create` when Firebase is yes,
/// via [StructureGenerator.applyFirebaseSupport]. Dart services and the splash
/// hook are added here because create writes them only for a new tree.
///
/// Re-running is safe:
/// - `pubspec.yaml` gains a package only when that package name is absent
/// - `firebase_service.dart` is not overwritten
/// - `google-services.json` and `GoogleService-Info.plist` are not overwritten
/// - splash is left alone once it calls `FirebaseService.init`
abstract final class FirebaseIntegrator {
  static Future<SetupChangeReport> apply(ProjectConfig config) async {
    if (config.projectRoot == null) {
      throw SetupException(
        'Firebase setup needs an existing project root. '
        'Run `xproject setup firebase` inside the Flutter project.',
      );
    }

    final report = SetupChangeReport();
    final enabled = config.copyWith(useFirebase: true);

    await _addPubspecDependencies(enabled, report);
    await _writeServiceFiles(enabled, report);
    await _patchSplash(enabled, report);

    final native = await StructureGenerator.applyFirebaseSupport(enabled);
    report.written.addAll(native.written);
    report.skipped.addAll(native.skipped);
    report.notes.addAll(native.notes);

    if (report.changed) {
      await GuideRefresher.refresh(enabled);
      report.written.add('GUIDE.md');
      report.guideUpdatedFor = 'Firebase';
      report.notes.add(
        'Replace placeholder google-services.json and '
        'GoogleService-Info.plist files from Firebase Console. '
        'On iOS, add a Run Script phase that executes ios/firebase.sh '
        'before Copy Bundle Resources. '
        'For web, replace YOUR_* in lib/firebase_options.dart and '
        'web/firebase-messaging-sw.js (or run flutterfire configure). '
        'Then run flutter pub get.',
      );
    } else {
      report.notes.add('Firebase is already configured. No files were changed.');
    }

    return report;
  }

  static Future<void> _addPubspecDependencies(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    final pubspecFile = File(path.join(config.projectPath, 'pubspec.yaml'));
    final before = await pubspecFile.readAsString();
    final after = PubspecEditor.addDependencies(
      before,
      FirebaseDependencies.pubspecLines,
    );
    if (after == before) {
      report.skipped.add('pubspec.yaml');
      return;
    }
    await pubspecFile.writeAsString(after);
    report.written.add('pubspec.yaml');
  }

  static Future<void> _writeServiceFiles(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    final files = <String, String>{
      'lib/core/services/firebase/firebase_service.dart':
          CommonTemplates.firebaseService(),
      'lib/core/services/firebase/notification_service.dart':
          CommonTemplates.notificationService(),
    };

    for (final entry in files.entries) {
      final file = File(path.join(config.projectPath, entry.key));
      if (file.existsSync()) {
        report.skipped.add(entry.key);
        continue;
      }
      await file.parent.create(recursive: true);
      await file.writeAsString(entry.value);
      report.written.add(entry.key);
    }
  }

  static Future<void> _patchSplash(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    final relative = splashFirebaseRelativePath(config.stateManagement);
    final file = File(path.join(config.projectPath, relative));
    if (!file.existsSync()) {
      throw SetupException(
        'Cannot wire Firebase startup. Missing $relative. '
        'This file is created by `xproject create`.',
      );
    }

    final before = await file.readAsString();
    final after = enableFirebaseInSplash(
      source: before,
      stateManagement: config.stateManagement,
      config: config,
    );
    if (after == before) {
      report.skipped.add(relative);
      return;
    }
    await file.writeAsString(after);
    report.written.add(relative);
  }
}
