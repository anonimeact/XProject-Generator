import 'dart:io';

import 'package:path/path.dart' as path;

import '../core/configs/project_config.dart';

/// Appends sensitive / local-only paths to the generated project's `.gitignore`.
class ProjectGitignore {
  static const _marker = '# XProject — sensitive & local';

  /// Lines appended to `.gitignore` (excluding [marker] line).
  static List<String> sensitivePaths(ProjectConfig config) {
    final paths = <String>[
      '.env',
      '.env.*',
      '.env.development',
      '.env.staging',
      '.env.production',
      if (config.useSecretKey) 'lib/core/config/secretkey.dart',
      if (config.targetsAndroid) ...[
        '*.jks',
        '*.keystore',
        'key.properties',
      ],
      if (config.targetsIos) 'AuthKey_*.p8',
      if (config.hasCiDeploy) ...[
        'fastlane/report.xml',
        'fastlane/test_output',
        'fastlane/.env',
      ],
    ];
    return paths;
  }

  static Future<void> append(ProjectConfig config) async {
    final gitignore = File(path.join(config.projectPath, '.gitignore'));
    if (!gitignore.existsSync()) return;

    var content = await gitignore.readAsString();
    final required = sensitivePaths(config);

    if (!content.contains(_marker)) {
      final buffer = StringBuffer();
      buffer.writeln();
      buffer.writeln(_marker);
      for (final line in required) {
        buffer.writeln(line);
      }

      if (!content.endsWith('\n')) content += '\n';
      content += buffer.toString();
      await gitignore.writeAsString(content);
      return;
    }

    final missing = required.where((line) {
      return !RegExp(
        '^${RegExp.escape(line)}\$',
        multiLine: true,
      ).hasMatch(content);
    }).toList();
    if (missing.isEmpty) return;

    final markerIndex = content.indexOf(_marker);
    final lineEnd = content.indexOf('\n', markerIndex);
    final insertAt = lineEnd == -1 ? content.length : lineEnd + 1;
    final block = '${missing.join('\n')}\n';
    content = content.replaceRange(insertAt, insertAt, block);
    await gitignore.writeAsString(content);
  }
}
