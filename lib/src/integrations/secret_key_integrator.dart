import 'dart:io';

import 'package:path/path.dart' as path;

import '../../core/configs/project_config.dart';
import '../project_gitignore.dart';
import '../templates/common_templates.dart';
import 'guide_refresher.dart';
import 'setup_change_report.dart';

/// Switches an XProject app from plain `.env` loading to the secret-key flow.
///
/// Create asks "Use Secret Key" up front and writes `get_env.dart` plus
/// `cryptic.dart` immediately. This integrator does that same switch later.
///
/// What it does not do, on purpose:
/// - It does not generate a real `SecretKey` (that comes from
///   `secret_key_scrypt_generator`).
/// - It does not rewrite `.env.*`. Those files stay as they are. After the
///   loader switches, plaintext env files must be encrypted before a build,
///   exactly as GUIDE.md describes for a project created with secret key on.
///
/// A stub `secretkey.dart` is written only when the file is missing, so the
/// project still analyzes. The stub throws until it is replaced, and the path
/// is added to `.gitignore`.
abstract final class SecretKeyIntegrator {
  static Future<SetupChangeReport> apply(ProjectConfig config) async {
    if (config.projectRoot == null) {
      throw SetupException(
        'Secret key setup needs an existing project root. '
        'Run `xproject setup secret-key` inside the Flutter project.',
      );
    }

    final report = SetupChangeReport();
    final enabled = config.copyWith(useSecretKey: true);

    await _switchEnvLoader(enabled, report);
    await _writeCryptic(enabled, report);
    await _writeSecretKeyStub(enabled, report);
    await _enableStorageEncryption(enabled, report);

    final gitignore = File(path.join(enabled.projectPath, '.gitignore'));
    final beforeGitignore = gitignore.existsSync()
        ? await gitignore.readAsString()
        : null;
    await ProjectGitignore.append(enabled);
    if (beforeGitignore != null) {
      final afterGitignore = await gitignore.readAsString();
      if (afterGitignore != beforeGitignore) {
        report.written.add('.gitignore');
      }
    }

    if (report.changed) {
      await GuideRefresher.refresh(enabled);
      report.written.add('GUIDE.md');
      report.guideUpdatedFor = 'Secret key';
      report.notes.add(
        'Generate a real lib/core/config/secretkey.dart with '
        'secret_key_scrypt_generator and replace the stub. '
        'Encrypt .env.development, .env.staging, and .env.production '
        'before the next build. The stub throws until it is replaced, '
        'and that file is listed in .gitignore.',
      );
    } else {
      report.notes.add(
        'Secret key loading is already enabled. No files were changed.',
      );
    }

    return report;
  }

  static Future<void> _switchEnvLoader(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    const relative = 'lib/core/config/get_env.dart';
    final file = File(path.join(config.projectPath, relative));
    final encrypted = CommonTemplates.getEnv();
    if (!file.existsSync()) {
      await file.parent.create(recursive: true);
      await file.writeAsString(encrypted);
      report.written.add(relative);
      return;
    }

    final before = await file.readAsString();
    if (before.contains('SecretKey')) {
      report.skipped.add(relative);
      return;
    }

    await file.writeAsString(encrypted);
    report.written.add(relative);
    if (_normalize(before) != _normalize(CommonTemplates.getEnvSimple())) {
      report.notes.add(
        '$relative was replaced with the encrypted loader. '
        'Custom parsing in the previous file was not kept.',
      );
    }
  }

  static Future<void> _writeCryptic(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    const relative = 'lib/core/config/cryptic.dart';
    final file = File(path.join(config.projectPath, relative));
    if (file.existsSync()) {
      report.skipped.add(relative);
      return;
    }
    await file.parent.create(recursive: true);
    await file.writeAsString(CommonTemplates.cryptic());
    report.written.add(relative);
  }

  static Future<void> _writeSecretKeyStub(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    const relative = 'lib/core/config/secretkey.dart';
    final file = File(path.join(config.projectPath, relative));
    if (file.existsSync()) {
      report.skipped.add(relative);
      return;
    }
    await file.parent.create(recursive: true);
    await file.writeAsString(_secretKeyStub);
    report.written.add(relative);
  }

  static Future<void> _enableStorageEncryption(
    ProjectConfig config,
    SetupChangeReport report,
  ) async {
    const relative = 'lib/app.dart';
    final file = File(path.join(config.projectPath, relative));
    if (!file.existsSync()) {
      throw SetupException('Missing lib/app.dart.');
    }
    final before = await file.readAsString();
    final after = enableSecretKeyInApp(before);
    if (after == before) {
      report.skipped.add(relative);
      return;
    }
    await file.writeAsString(after);
    report.written.add(relative);
  }

  /// Turns storage encryption on and imports `secretkey.dart` when needed.
  ///
  /// Only the generated `isEncryptKeyAndValue` flag is changed. The rest of
  /// `app.dart` is kept, including theme, routing, and later edits.
  static String enableSecretKeyInApp(String source) {
    if (!source.contains('isEncryptKeyAndValue:')) {
      throw SetupException(
        'lib/app.dart has no StorageHelper.initialize isEncryptKeyAndValue '
        'flag. Setup only patches apps created by XProject.',
      );
    }

    var updated = source.replaceFirst(
      RegExp(r'isEncryptKeyAndValue:\s*false'),
      'isEncryptKeyAndValue: true',
    );
    const importLine = "import 'core/config/secretkey.dart';";
    if (!updated.contains(importLine)) {
      const anchor = "import 'core/config/env_config.dart';";
      if (updated.contains(anchor)) {
        updated = updated.replaceFirst(anchor, '$anchor\n$importLine');
      } else {
        updated = '$importLine\n$updated';
      }
    }
    return updated;
  }
}

String _normalize(String value) => value.replaceAll('\r\n', '\n').trimRight();

const String _secretKeyStub = '''
/// Temporary key created by `xproject setup secret-key`.
///
/// Replace this file with the output of
/// [secret_key_scrypt_generator](https://pub.dev/packages/secret_key_scrypt_generator).
/// The path is gitignored. Do not commit the real key.
class SecretKey {
  static String unixKey() {
    throw UnsupportedError(
      'Replace lib/core/config/secretkey.dart using secret_key_scrypt_generator '
      'before running the app.',
    );
  }
}
''';
