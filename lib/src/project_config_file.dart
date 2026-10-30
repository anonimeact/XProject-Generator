import 'dart:io';

import 'package:path/path.dart' as path;

import '../../core/configs/project_config.dart';

/// Persists XProject wizard metadata under `.xproject/config.yaml`.
abstract final class XProjectConfigFile {
  static const relativePath = '.xproject/config.yaml';

  static File fileFor(String projectRoot) =>
      File(path.join(projectRoot, relativePath));

  static Future<void> write(ProjectConfig config) async {
    final root = config.projectRoot ?? config.projectPath;
    final file = fileFor(root);
    await file.parent.create(recursive: true);
    await file.writeAsString(_serialize(config));
  }

  static String _serialize(ProjectConfig config) {
    return '''
# XProject metadata (safe to commit). Used when regenerating GUIDE.md.
app_name: ${config.appName}
display_name: ${_yamlQuote(config.displayName)}
''';
  }

  static String _yamlQuote(String value) {
    if (RegExp(r'^[a-zA-Z0-9 _.-]+$').hasMatch(value)) return value;
    return '"${value.replaceAll('"', r'\"')}"';
  }
}
