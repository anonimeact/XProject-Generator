import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;

/// Reads `version:` from this package's [pubspec.yaml].
///
/// Resolves via [Isolate.resolvePackageUri] so it works for `dart run`, path/global
/// activation, and compiled snapshots (not only when [Platform.script] sits near pubspec).
Future<String> readPackageVersion() async {
  final fromPackage = await _versionFromResolvedPackageRoot();
  if (fromPackage != null) return fromPackage;

  final scriptPath = Platform.script.toFilePath();
  var dir = Directory(path.dirname(scriptPath));

  while (true) {
    final version = await _readVersionFile(
      File(path.join(dir.path, 'pubspec.yaml')),
    );
    if (version != null) return version;

    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  return 'unknown';
}

Future<String?> _versionFromResolvedPackageRoot() async {
  final Uri? entryUri;
  try {
    entryUri = await Isolate.resolvePackageUri(
      Uri.parse('package:xproject_generator/xproject_generator.dart'),
    );
  } on UnsupportedError {
    // e.g. `flutter test`; fall back to walking up from Platform.script.
    return null;
  }
  if (entryUri == null) return null;

  final packageRoot = File.fromUri(entryUri).parent.parent;
  return _readVersionFile(
    File(path.join(packageRoot.path, 'pubspec.yaml')),
  );
}

Future<String?> _readVersionFile(File pubspec) async {
  if (!pubspec.existsSync()) return null;

  final lines = await pubspec.readAsLines();
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('version:')) {
      return trimmed.split(':').last.trim();
    }
  }
  return null;
}
