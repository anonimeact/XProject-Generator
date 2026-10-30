import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;

/// Default launcher icon copied into every generated Flutter project.
abstract final class AppIconConfig {
  /// Logo bundled with [xproject_generator] (repo: `assets/logo_anonimeact.png`).
  static const packageRelativeLogo = 'assets/logo_anonimeact.png';

  /// Path in the generated app (registered in `pubspec.yaml` + `flutter_launcher_icons`).
  static const projectAssetPath = 'assets/icons/app_icon.png';

  /// Resolves [packageRelativeLogo] on disk for the installed [xproject_generator] package.
  static Future<File> bundledLogoFile() async {
    final entryUri = await Isolate.resolvePackageUri(
      Uri.parse('package:xproject_generator/xproject_generator.dart'),
    );
    if (entryUri == null) {
      throw StateError('Could not resolve xproject_generator package root.');
    }
    final packageRoot = File.fromUri(entryUri).parent.parent;
    final file = File(path.join(packageRoot.path, packageRelativeLogo));
    if (!file.existsSync()) {
      throw StateError(
        'Default app icon not found at ${file.path}.',
      );
    }
    return file;
  }
}
