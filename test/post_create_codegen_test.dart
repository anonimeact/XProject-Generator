import 'dart:io';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/post_create_codegen.dart';

ProjectConfig _config({String? projectRoot}) {
  return ProjectConfig(
    appName: 'demo',
    displayName: 'Demo',
    androidPackage: 'com.example.demo',
    iosBundleId: 'com.example.demo',
    stateManagement: StateManagement.bloc,
    useFirebase: false,
    useSecretKey: false,
    projectRoot: projectRoot,
  );
}

void main() {
  test('post create runs pub get then build_runner', () async {
    final root = await Directory.systemTemp.createTemp('xproject_codegen');
    addTearDown(() => root.delete(recursive: true));

    final l10nDir = Directory('${root.path}/lib/core/l10n/generated');
    await l10nDir.create(recursive: true);
    await File('${l10nDir.path}/app_localizations.dart').writeAsString('''
class AppLocalizations {
  static const delegate = _Delegate();
}
class _Delegate {}
''');

    final calls = <String>[];
    await PostCreateCodegen.run(
      _config(projectRoot: root.path),
      runner: (executable, arguments, workingDirectory) async {
        calls.add('$executable ${arguments.join(' ')} @$workingDirectory');
        return ProcessResult(0, 0, '', '');
      },
    );

    expect(calls.length, 3);
    expect(calls[0], contains('flutter pub get'));
    expect(calls[1], contains('flutter_launcher_icons'));
    expect(calls[2], contains('build_runner'));
  });

  test('post create fails when l10n output is missing after pub get', () async {
    final root = await Directory.systemTemp.createTemp('xproject_no_l10n');
    addTearDown(() => root.delete(recursive: true));

    expect(
      () => PostCreateCodegen.run(
        _config(projectRoot: root.path),
        runner: (_, __, ___) async => ProcessResult(0, 0, '', ''),
      ),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('app_localizations.dart'),
        ),
      ),
    );
  });
}
