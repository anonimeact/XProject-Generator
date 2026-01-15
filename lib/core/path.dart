import 'dart:io';

import 'package:path/path.dart' as path;

/// XProject Generator - Path Utilities
///
/// Provides utility functions and constants for handling file and directory paths
/// within the XProject Generator system.
///
/// See README.md for more details.

Directory findProjectRoot() {
  Directory dir = Directory.current;

  while (true) {
    final pubspec = File(path.join(dir.path, 'pubspec.yaml'));
    final libDir = Directory(path.join(dir.path, 'lib'));

    if (pubspec.existsSync() && libDir.existsSync()) {
      return dir;
    }

    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw Exception(
        'Flutter project root not found. '
        'Make sure you run this command inside a Flutter project.',
      );
    }

    dir = parent;
  }
}
