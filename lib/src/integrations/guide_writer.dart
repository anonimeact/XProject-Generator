import 'dart:io';

import 'package:path/path.dart' as path;

import '../../core/configs/project_config.dart';
import '../templates/guide_template.dart';

/// Writes English-only `GUIDE.md` and removes legacy locale files.
abstract final class GuideWriter {
  static const _legacyGuideFiles = <String>[
    'GUIDE.en.md',
    'GUIDE.id.md',
    'GUIDE.es.md',
    'GUIDE.pt.md',
    'GUIDE.zh.md',
    'GUIDE.ja.md',
    'GUIDE.ko.md',
    'GUIDE.fr.md',
    'GUIDE.de.md',
  ];

  static Future<void> writeAll(ProjectConfig config) async {
    final root = config.projectPath;
    for (final name in _legacyGuideFiles) {
      final stale = File(path.join(root, name));
      if (stale.existsSync()) {
        await stale.delete();
      }
    }
    await File(path.join(root, 'GUIDE.md')).writeAsString(
      GuideTemplate.content(config),
    );
  }
}
