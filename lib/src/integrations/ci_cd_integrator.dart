import 'dart:io';

import 'package:path/path.dart' as path;

import '../../core/configs/project_config.dart';
import '../ci_cd_generator.dart';
import '../project_gitignore.dart';
import 'guide_refresher.dart';
import 'setup_change_report.dart';

/// Writes the same CI/CD files as `xproject create` onto an existing project.
///
/// [overwrite] must be true before an existing `.gitlab-ci.yml` or
/// `.github/workflows/flutter_ci.yml` is replaced. Fastlane files and
/// `test/smoke_test.dart` are written by [CiCdGenerator] whenever deployment
/// or CI is enabled; the CLI asks before that happens if a CI file is already
/// there.
///
/// Switching provider (GitLab to GitHub, or the reverse) does not delete the
/// previous provider's file. The report says so, so the old pipeline is not
/// removed by accident.
abstract final class CiCdIntegrator {
  static List<String> existingFiles(String projectRoot) {
    const candidates = <String>[
      '.gitlab-ci.yml',
      '.github/workflows/flutter_ci.yml',
    ];
    return candidates.where((relative) {
      return File(path.join(projectRoot, relative)).existsSync();
    }).toList();
  }

  static Future<SetupChangeReport> apply(
    ProjectConfig config, {
    bool overwrite = false,
  }) async {
    if (!config.hasCiCd) {
      throw SetupException('CI/CD scope is none. Choose CI or CI + deploy.');
    }
    if (config.projectRoot == null) {
      throw SetupException(
        'CI/CD setup needs an existing project root. '
        'Run `xproject setup ci` inside the Flutter project.',
      );
    }

    final present = existingFiles(config.projectPath);
    if (present.isNotEmpty && !overwrite) {
      throw SetupException(
        'CI/CD is already present (${present.join(', ')}). '
        'Re-run and confirm overwrite to replace those files.',
      );
    }

    final report = SetupChangeReport();
    final written = await CiCdGenerator.generate(
      config,
      replaceExisting: overwrite,
    );
    await ProjectGitignore.append(config);
    report.written.addAll(written);

    final leftover = present.where((relative) => !written.contains(relative));
    if (leftover.isNotEmpty) {
      report.notes.add(
        'Previous CI files were not deleted: ${leftover.join(', ')}. '
        'Remove them if that provider is no longer used.',
      );
    }

    await GuideRefresher.refresh(config);
    report.written.add('GUIDE.md');
    report.guideUpdatedFor = 'CI/CD';
    report.notes.add(
      'Fill the CI variables described in GUIDE.md before the first pipeline. '
      'fastlane/.env.example lists deploy secrets and is not a live env file.',
    );
    return report;
  }
}
