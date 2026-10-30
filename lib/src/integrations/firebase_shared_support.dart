import 'dart:io';

import 'package:path/path.dart' as path;

import '../../core/configs/project_config.dart';
import '../templates/firebase/firebase_messaging_sw_template.dart';
import '../templates/firebase/firebase_options_template.dart';
import 'firebase_service_patch.dart';
import 'setup_change_report.dart';

/// Writes `firebase_options.dart`, web FCM service worker, and patches
/// [FirebaseService] when web or options files were missing.
abstract final class FirebaseSharedSupport {
  static bool projectHasWebFolder(ProjectConfig config) {
    return File(path.join(config.projectPath, 'web', 'index.html')).existsSync();
  }

  static bool includeWebOptions(ProjectConfig config) {
    return config.targetsWeb || projectHasWebFolder(config);
  }

  static Future<void> apply(
    ProjectConfig config,
    SetupChangeReport report, {
    required String firebaseServiceImport,
  }) async {
    await _ensureFirebaseOptions(config, report);
    if (includeWebOptions(config)) {
      await _ensureWebMessagingSw(config, report);
    }
    await _upgradeFirebaseService(config, report, firebaseServiceImport);
  }

  static Future<void> _ensureFirebaseOptions(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    const relative = 'lib/firebase_options.dart';
    final file = File(path.join(config.projectPath, relative));
    if (file.existsSync()) {
      report.skipped.add(relative);
      return;
    }
    await file.parent.create(recursive: true);
    await file.writeAsString(
      FirebaseOptionsTemplate.content(
        config,
        includeWeb: includeWebOptions(config),
      ),
    );
    report.written.add(relative);
  }

  static Future<void> _ensureWebMessagingSw(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    const relative = 'web/firebase-messaging-sw.js';
    final file = File(path.join(config.projectPath, relative));
    if (file.existsSync()) {
      report.skipped.add(relative);
      return;
    }
    await file.parent.create(recursive: true);
    await file.writeAsString(FirebaseMessagingSwTemplate.content());
    report.written.add(relative);
  }

  static Future<void> _upgradeFirebaseService(
    ProjectConfig config,
    SetupChangeReport report,
    String firebaseServiceImport,
  ) async {
    const relative = 'lib/core/services/firebase/firebase_service.dart';
    final file = File(path.join(config.projectPath, relative));
    if (!file.existsSync()) {
      return;
    }
    final before = await file.readAsString();
    final after = FirebaseServicePatch.upgradeForFirebaseOptions(
      source: before,
      firebaseOptionsImport: firebaseServiceImport,
    );
    if (after == before) {
      return;
    }
    await file.writeAsString(after);
    report.written.add('$relative (Firebase options init)');
  }
}
