import 'dart:io';

import '../../core/configs/project_config.dart';
import '../structure_generator.dart';
import 'firebase_shared_support.dart';
import 'guide_refresher.dart';
import 'setup_change_report.dart';

/// Adds Flutter platforms that were not selected during `xproject create`.
///
/// The heavy lifting is `flutter create --platforms <list> .`, which is the
/// supported way to add `web`, `windows`, `macos`, `linux`, `android`, or
/// `ios` to an existing app. After Android or iOS is added, flavor config is
/// applied with [StructureGenerator.ensureFlavorConfigs]. That call is
/// idempotent for platforms that were already flavored.
abstract final class PlatformIntegrator {
  /// Arguments passed to the `flutter` executable.
  static List<String> flutterCreateArguments(Set<PlatformTarget> additional) {
    final ordered = PlatformTarget.values
        .where(additional.contains)
        .map((target) => target.name)
        .join(',');
    return <String>['create', '--platforms', ordered, '.'];
  }

  static Future<SetupChangeReport> apply({
    required ProjectConfig config,
    required Set<PlatformTarget> additional,
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments,
      String workingDirectory,
    )?
    runner,
  }) async {
    if (config.projectRoot == null) {
      throw SetupException(
        'Platform setup needs an existing project root. '
        'Run `xproject setup platforms` inside the Flutter project.',
      );
    }
    if (additional.isEmpty) {
      throw SetupException('Choose at least one platform to add.');
    }

    final args = flutterCreateArguments(additional);
    final run = runner ?? _runFlutter;
    final ProcessResult result;
    try {
      result = await run('flutter', args, config.projectPath);
    } on ProcessException catch (error) {
      throw SetupException(
        'Could not run flutter (${error.message}). '
        'Install Flutter and make sure it is on PATH.',
      );
    }
    if (result.exitCode != 0) {
      throw SetupException(
        'flutter create failed (exit ${result.exitCode}).\n${result.stderr}',
      );
    }

    final updated = config.copyWith(
      platformTargets: <PlatformTarget>{
        ...config.platformTargets,
        ...additional,
      },
    );
    final report = SetupChangeReport(
      written: additional.map((target) => target.name).toList(),
      notes: <String>['Ran: flutter ${args.join(' ')}'],
    );

    final touchesMobile =
        additional.contains(PlatformTarget.android) ||
        additional.contains(PlatformTarget.ios);
    if (touchesMobile) {
      await StructureGenerator.ensureFlavorConfigs(updated);
      report.written.add('Android/iOS flavor config');
      report.notes.add(
        'New Android or iOS folders received the same flavor setup as create. '
        'Check applicationId and bundle id against GUIDE.md.',
      );
    }

    if (updated.useFirebase &&
        (additional.contains(PlatformTarget.web) ||
            additional.contains(PlatformTarget.android) ||
            additional.contains(PlatformTarget.ios))) {
      await FirebaseSharedSupport.apply(
        updated,
        report,
        firebaseServiceImport: "import '../../../firebase_options.dart';",
      );
      if (updated.useFirebase && additional.contains(PlatformTarget.web)) {
        report.notes.add(
          'Web added with Firebase enabled: check GUIDE.md Firebase section for '
          'Web app registration and firebase_options.dart / firebase-messaging-sw.js.',
        );
      }
    }

    await GuideRefresher.refresh(updated);
    report.written.add('GUIDE.md');
    report.guideUpdatedFor = 'additional platforms';
    return report;
  }

  static Future<ProcessResult> _runFlutter(
    String executable,
    List<String> arguments,
    String workingDirectory,
  ) {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );
  }
}
