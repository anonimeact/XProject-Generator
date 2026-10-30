import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/integrations/ci_cd_integrator.dart';
import 'package:xproject_generator/src/integrations/firebase_integrator.dart';
import 'package:xproject_generator/src/integrations/platform_integrator.dart';
import 'package:xproject_generator/src/integrations/project_inspector.dart';
import 'package:xproject_generator/src/integrations/secret_key_integrator.dart';

import 'helpers/xproject_app_fixture.dart';

void main() {
  late String packageRoot;
  late String cliBin;

  setUpAll(() {
    packageRoot = Directory.current.path;
    cliBin = p.join(packageRoot, 'bin', 'xproject.dart');
  });

  Future<ProcessResult> runSetupCli(
    Directory projectRoot,
    List<String> args,
  ) {
    return Process.run(
      'dart',
      ['run', cliBin, 'setup', ...args],
      workingDirectory: projectRoot.path,
    );
  }

  test('CLI setup firebase and secret-key exit 0 on xproject fixture', () async {
    final root = await writeMinimalXprojectApp();
    addTearDown(() => root.delete(recursive: true));

    final firebase = await runSetupCli(root, ['firebase']);
    expect(
      firebase.exitCode,
      0,
      reason: 'firebase stderr: ${firebase.stderr}\nstdout: ${firebase.stdout}',
    );

    final inspectedAfterFirebase = await ProjectInspector.inspect(root: root);
    expect(inspectedAfterFirebase.firebaseReady, isTrue);

    final secret = await runSetupCli(root, ['secret']);
    expect(
      secret.exitCode,
      0,
      reason: 'secret stderr: ${secret.stderr}\nstdout: ${secret.stdout}',
    );

    final inspectedAfterSecret = await ProjectInspector.inspect(root: root);
    expect(inspectedAfterSecret.secretKeyReady, isTrue);
  });

  test('CLI setup unknown subcommand exits non-zero', () async {
    final root = await writeMinimalXprojectApp();
    addTearDown(() => root.delete(recursive: true));

    final result = await runSetupCli(root, ['not-a-command']);
    expect(result.exitCode, isNonZero);
    expect(result.stdout.toString(), contains('Unknown setup command'));
  });

  test('integrator chain firebase → secret → ci → platforms on fixture', () async {
    final root = await writeMinimalXprojectApp();
    addTearDown(() => root.delete(recursive: true));

    var config = (await ProjectInspector.inspect(root: root)).config;

    await FirebaseIntegrator.apply(config.copyWith(useFirebase: true));
    config = (await ProjectInspector.inspect(root: root)).config;
    expect(config.useFirebase, isTrue);

    await SecretKeyIntegrator.apply(config.copyWith(useSecretKey: true));
    config = (await ProjectInspector.inspect(root: root)).config;
    expect(config.useSecretKey, isTrue);

    await CiCdIntegrator.apply(
      config.copyWith(
        ciCdScope: CiCdScope.ciOnly,
        ciCdProvider: CiCdProvider.github,
      ),
    );
    expect(await File(p.join(root.path, '.github/workflows/flutter_ci.yml')).exists(), isTrue);

    final platformReport = await PlatformIntegrator.apply(
      config: config,
      additional: {PlatformTarget.web},
      runner: (executable, arguments, workingDirectory) async {
        expect(executable, 'flutter');
        expect(workingDirectory, root.path);
        return ProcessResult(0, 0, '', '');
      },
    );
    expect(platformReport.written, contains('web'));

    final guide = await File(p.join(root.path, 'GUIDE.md')).readAsString();
    expect(guide, contains('Firebase | Yes |'));
    expect(guide, contains('Secret key'));
  });
}
