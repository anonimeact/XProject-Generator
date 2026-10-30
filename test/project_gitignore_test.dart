import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/project_gitignore.dart';

void main() {
  test('sensitivePaths includes env and signing files', () {
    final paths = ProjectGitignore.sensitivePaths(
      ProjectConfig(
        appName: 'app',
        displayName: 'App',
        androidPackage: 'com.example.app',
        iosBundleId: 'com.example.app',
        stateManagement: StateManagement.getx,
        useFirebase: false,
        useSecretKey: true,
      ),
    );

    expect(paths, contains('.env.development'));
    expect(paths, contains('lib/core/config/secretkey.dart'));
    expect(paths, contains('key.properties'));
  });

  test('sensitivePaths omits secretkey when secret key disabled', () {
    final paths = ProjectGitignore.sensitivePaths(
      ProjectConfig(
        appName: 'app',
        displayName: 'App',
        androidPackage: 'com.example.app',
        iosBundleId: 'com.example.app',
        stateManagement: StateManagement.getx,
        useFirebase: false,
        useSecretKey: false,
      ),
    );

    expect(paths, isNot(contains('lib/core/config/secretkey.dart')));
    expect(paths, contains('.env'));
  });

  test('sensitivePaths follows selected platforms and deploy scope', () {
    final paths = ProjectGitignore.sensitivePaths(
      ProjectConfig(
        appName: 'web',
        displayName: 'Web',
        androidPackage: 'com.example.web',
        iosBundleId: 'com.example.web',
        stateManagement: StateManagement.getx,
        useFirebase: false,
        useSecretKey: false,
        platformTargets: {PlatformTarget.web},
      ),
    );

    expect(paths, isNot(contains('key.properties')));
    expect(paths, isNot(contains('AuthKey_*.p8')));
    expect(paths, isNot(contains('fastlane/.env')));
  });
}
